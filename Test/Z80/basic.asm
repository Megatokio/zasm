#!/usr/local/bin/zasm -o original/
; .:*~*:.__.:*~*:.
; |              |
; |RiFT8 Firmware|
; |By Fell, 2012 |
; |              |
; ':*~*:.__.:*~*:'

#target 	rom			; Required for zasm
#code 		rom,0,$8000			; Required for zasm

; *** Hardware config constants ***
uart_base	equ $00			; UART base address
uart_mr		equ uart_base		; UART mode registers MR1 and MR2
uart_sr_csr	equ uart_base+1		; R: Status register; W: Clock select register
uart_cr		equ uart_base+2		; R: BRG Test; W: Command register
uart_data	equ uart_base+3		; R: Rx holding register; W: Tx holding register

ram_base	equ $8000		; RAM base (ROM 0-32kB, RAM 32kB-64kB)
ram_size	equ $8000		; RAM size (32kB)
ram_top		equ ram_base+ram_size-1	; Address of last byte of RAM

; *** Memory map: OS scratch space (Bottom of RAM) ***
rand16_seed	equ ram_base	; Location of Rand16's seed (2 bytes)
int_buffer	equ rand16_seed+2	; Int->string buffer
string_buffer	equ int_buffer+10	; Location of string buffer for GetString (256 bytes max including terminator)
scratch_base	equ string_buffer+256	; General 1Kb scratch variable space.   NOTE: SAFE TO USE AS TEMP VARS FROM USERSPACE PROGS
prog_base	equ scratch_base+1024	; Location of the start of userspace

; *** Sys constants ***
uart_disabletx	equ 00001000b		; Command reg command to disable tx
uart_resettx	equ 00110000b		; CR command to reset tx
uart_enabletx	equ 00000100b		; CR command to enable tx
uart_disablerx	equ 00000010b		; Command reg command to disable rx
uart_resetrx	equ 00100000b		; CR command to reset rx
uart_enablerx	equ 00000001b		; CR command to enable rx
uart_setmr1	equ 00010000b		; CR command to reset MR pointer to mr1
uart_txemptybit	equ 3			; SR bit that signifies tx empty
uart_rxrdybit	equ 0			; SR bit that signifies rx ready

		org $0000

		di			; Disable interrupts

		ld a,uart_disablerx	; Disable UART rx + tx
		out (uart_cr),a
		ld a,uart_disabletx
		out (uart_cr),a
		ld a,uart_resettx	; Reset tx + rx
		out (uart_cr),a
		ld a,uart_resetrx
		out (uart_cr),a		
		ld a,uart_setmr1	; Reset MR pointer (causes the MR pointer to point to MR1)
		out (uart_cr),a		  
		ld a,00010011b		; Config UART mr1 (on this address after reset) for no RTS gubbins on rx, 8 bits per char, no parity
		out (uart_mr),a		; NB: When written to, the register addressed by uart_mr switches to mr2
		ld a,00000111b		; Config UART mr2 for normal mode, no tx RTS, no tx CTS, stop bit length of 1
		out (uart_mr),a
		ld a,11001100b		; Set UART for 38.4k both ways
		out (uart_sr_csr),a
	
		ld a,uart_enabletx	; Enable UART tx & rx
		out (uart_cr),a	
		ld a,uart_enablerx
		out (uart_cr),a	
		
		ld sp,ram_top-1 	; init stack pointer -- now we can call subroutines :)
		ld hl,3473
		call SeedRand16
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; *** BRAINDEAD BASIC INTERPRETER ***
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Limits:
;	- Max 255 lines			}- 16384 bytes for user prog
;	- Max line length 64 chars	}
;	- Line numbers must be 1-255
;	- Max 8 nested levels of gosub
;	- 52 x 1 char identified (A-Z, a-z), variables (all 16 bit unsigned int)
;	- 52 x "$ and 1 char" identified ($A-$Z, $a-$z) string variables, max 32 bytes each (total 3328 bytes -- SO WASTEFUL)
;
; Legal statements (note -- they are case sensitive):
; TODO: Replace this shit with a grammar or example prog :P
; (N and M are line numbers; Z is a direct 16 bit unsigned int; A, B and C are var identifiers)
;	for A={expression} to {expression}
;	next A
; 	goto N
;	gosub N
;	return
;	input A	
;	input "You can print a prompt with input as well: ",A
; 	print A
;	print "Use a ~ for a newline!"
;	print "You can do compound print statements like this.. ";A$;" is ";B;" years old!~"
;	A={expression|numeral}
;		(expression: any combination of var identifiers, numerals, *, /, +, -, ?. Note that ? is a random number!)
;	seed {expression}
;	end
;	if {expression}{condition}{expression} then N [else M]
;		(condition: ==, <>, <, <=, >, >=)
; TODO:
;	- decide how to store strings :)
;	- input A$, print A$
; NICE TO HAVE:
;	peek, poke, sys
; OPTIMISATIONS:
;	(memory) lose the 12 extra bytes in basprogvars
;	(memory) should we really be reserving 1.5k+ string buffer? ;)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

basicprompt	equ '>'			; Command processor prompt character
baslinelength	equ 64			; Line length / stride for stepping through baslines

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory layout
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bascurrline	equ prog_base		; Current line number (1 byte)
basprogvars	equ bascurrline+1	; Program UInt16 variables (58*2 bytes not 51*2 bytes due to ASCII chars 91-96 - TODO - optimise away these 12 wasted bytes!)
basprogstrvars	equ basprogvars+58*2	; Program string variables (58*32 bytes not 52*32 bytes due to ASCII chars 91-96 - TODO - optimise away these 192 wasted bytes!!!!!)
basforlppoints	equ basprogstrvars+58*32; FOR loop beginning line nums (58 bytes)
basformaxiters	equ basforlppoints+58*2	; FOR loop max iters (58*2 bytes)
basgosubstack	equ basformaxiters+58*2	; Stack of return line nums for GOSUB (8 bytes)
basgosubstackp	equ basgosubstack+8	; Index into GOSUB returns stack (1 byte)
baslines	equ basgosubstackp+1	; Here starts the user's prog lines :) (16384 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Line editor / command processor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Entrypoint
basic:		call ClearScreen
		jp basic_new
basic_cmd_loop:	ld a,basicprompt
		call PrintChar
		call GetString
		call NewLine
		ld hl,string_buffer
		ld de,basList
		call StrCmp
		jp c,basic_list
		ld de,basNew
		call StrCmp
		jp c,basic_new	
		ld de,basRun
		call StrCmp
		jp c,basic_run				
		jp basic_addline

; Add/edit/delete a listing line
basic_addline:	ld hl,string_buffer
		call AToUInt8
		cp 0
		jp z,basic_cmd_loop
		ld e,a			; Backup line num
		ld a,(hl)		; Jump over any space
		cp 32
		jp nz,basic_al_nosp
		inc hl			; Now a contains uint8 line number and hl=start of the actual line (after line number)
basic_al_nosp:	ld a,e			; Restore line num
		ld bc,hl		; Backup address of start of actual line
		ld h,0
		ld l,a
		push hl			; Push line num
		add hl,hl		; Multiply by 64 (Shift left x 6) - NOTE: THIS NEEDS TO CHANGE IF BASLINELENGTH DOES!!!
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		ld de,baslines
		add hl,de		; hl = target address to copy to; bc = start address to copy from
		ld de,hl		; de = dest
		ld hl,bc		; hl = source
		ld bc,baslinelength-1	; bc = count
		ldir
		ld a,0
		ld (de),a		; Ensure a terminated string
		ld bc,basMsgLineAdd1
		call PrintString
		pop hl			; Pop line number
		call PrintUInt16
		ld bc,basMsgLineAdd2
		call PrintLine
		jp basic_cmd_loop
		
; LIST command
basic_list:	ld hl,0
		ld bc,baslines
basic_list_lp:	ld a,(bc)
		cp 0
		jp z,basic_list_dp	; Skip printing if line is empty
		call PrintUInt16
		ld a,' '
		call PrintChar
		call PrintString
		call NewLine
basic_list_dp:	push hl
		ld hl,bc
		ld bc,baslinelength
		add hl,bc
		ld bc,hl
		pop hl
		inc hl
		ld a,l
		cp 255
		jp z,basic_cmd_loop
		jp basic_list_lp
		
; NEW command
basic_new:	ld hl,baslines
		ld de,baslines+1
		ld bc,baslinelength*256
		ld (hl),0
		ldir
		jp basic_cmd_loop
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main interpreter (RUN command)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

basic_run:	ld a,0			; Reset PC
		ld (bascurrline),a
		ld (basgosubstackp),a	; Reset SP
		ld hl,basStmtEnd	; Insert an END at last instruction
		ld de,baslines+baslinelength*255	
		ld bc,4
		ldir
; Execute a line		
basic_run_loop:	call bas_next_line	; hl now points to start of current line
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;ld bc,basMsgCurLine	; Show debug info
		;call PrintLine
		;push hl
		;ld a,(bascurrline)
		;ld h,0
		;ld l,a
		;call PrintUInt16
		;ld a,' '
		;call PrintChar	
		;pop hl
		;ld bc,hl
		;call PrintLine
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		ld de,basStmtGoto	; GOTO
		call StrStarts
		jp c,bas_stmt_goto
		ld de,basStmtGosub	; GOSUB
		call StrStarts
		jp c,bas_stmt_gosub
		ld de,basStmtReturn	; RETURN
		call StrStarts
		jp c,bas_stmt_return
		ld de,basStmtFor	; FOR
		call StrStarts
		jp c,bas_stmt_for
		ld de,basStmtNext	; NEXT
		call StrStarts
		jp c,bas_stmt_next
		ld de,basStmtRem	; REM
		call StrStarts
		jp c,bas_step_and_cont
		ld de,basStmtCls	; CLS
		call StrStarts
		jp c,bas_stmt_cls
		ld de,basStmtPrint	; PRINT
		call StrStarts
		jp c,bas_stmt_print
		ld de,basStmtInput	; INPUT
		call StrStarts
		jp c,bas_stmt_input
		ld de,basStmtEnd	; END
		call StrStarts
		jp c,basic_cmd_loop
		ld de,basStmtIf		; IF
		call StrStarts
		jp c,basic_stmt_if
		ld de,basStmtSeed	; SEED
		call StrStarts
		jp c,basic_stmt_seed
		ld de,basStmtInkey	; INKEY
		call StrStarts
		jp c,basic_stmt_inkey
		inc hl			; Assignment
		ld a,'='
		cp (hl)
		jp z,bas_stmt_ass
		dec hl
bas_syn_err:	ld bc,basMsgSynErr	; Syntax error!
		call PrintLine
		push hl
		ld a,(bascurrline)
		ld h,0
		ld l,a
		call PrintUInt16
		pop hl
		ld a,' '
		call PrintChar		
		ld bc,hl
		call PrintLine
		jp basic_cmd_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Using bascurrline, set hl to that line or the next non-empty line
bas_next_line:	ld bc,baslinelength
		ld a,(bascurrline)
		ld h,0
		ld l,a
		add hl,hl		; Multiply by 64 (Shift left x 6) - NOTE: THIS NEEDS TO CHANGE IF BASLINELENGTH DOES!!!
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		ld de,baslines
		add hl,de		; hl = address of current statement
bas_next_lp:	ld a,(hl)
		cp 0
		jp nz,bas_stmt_fnd
		add hl,bc		; Hmm let's step to next line
		ld a,(bascurrline)	; Also inc PC!
		inc a
		ld (bascurrline),a
		jp bas_next_lp
bas_stmt_fnd:	ret
	
; Step prog counter and run the next line
bas_step_and_cont:	
		ld a,(bascurrline)
		inc a
		ld (bascurrline),a
		jp basic_run_loop

; Get a prog var from memory
; Expects: c=var name
; Returns: de=var value
bas_get_var:	push hl
		push bc
		ld b,0			; bc=var name
		ld hl,bc		; hl=var name
		ld de,65		; de=65
		and a			; Clear carry flag to prevent sbc off-by-1!
		sbc hl,de		; hl=var name-65 (account for ASCII) ie var index
		ld bc,hl		; bc=var index
		ld hl,basprogvars	; hl=basprogvars base address
		add hl,bc
		add hl,bc
		ld de,(hl)
		pop bc
		pop hl
		ret
		
; Set a prog var
; Expects: c=var name; de=var value		
bas_set_var:	ld b,0			; bc=var name
		ld hl,bc		; hl=var name
		push de
		ld de,65		; de=65
		and a			; Clear carry flag to prevent sbc off-by-1!
		sbc hl,de		; hl=var name-65 (account for ASCII) ie var index
		ld bc,hl		; bc=offset
		ld hl,basprogvars	; hl=basprogvars
		add hl,bc
		add hl,bc
		pop de
		ld (hl),de
		ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle statements
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; INKEY
basic_stmt_inkey:
		ld bc,6
		add hl,bc		; Step past "inkey "
		ld c,(hl)		; c=var name
		call ScanChar
		ld d,0
		ld e,a			; de=pressed key
		call bas_set_var
		jp bas_step_and_cont
		
; SEED
basic_stmt_seed:
		ld bc,5
		add hl,bc		; Step past "seed "
		call Parse		; de=result of parse
		ld (rand16_seed),de	; set the seed!
		jp bas_step_and_cont

; FOR
bas_stmt_for:	ld bc,4
		add hl,bc		; skip "for "
		ld c,(hl)		; c=var name
		inc hl			; skip the var name
		inc hl			; skip the "="
		call Parse		; get start value in de, hl now points to first space after the value
		push hl			; backup input pointer
		call bas_set_var	; set the start value; leaves bc with offset
		pop hl			; restore input pointer
		ld de,4
		add hl,de		; skip the " to "
		call Parse		; get the stop value in de
		ld hl,basformaxiters	; hl=address of for max iters array
		add hl,bc		; hl=correct address in loop array for this var
		add hl,bc		; hl=correct address in loop array for this var
		ld (hl),de		; store the max iter!
		ld hl,basforlppoints	; hl=address of for loop array
		add hl,bc		; hl=correct address in loop array for this var (offset in bc is still correct)
		ld a,(bascurrline)	; a=current line num
		inc a			; a=current line+1 (ie correct loop point)		
		ld (hl),a		; stick it in the array
		jp bas_step_and_cont

; NEXT
bas_stmt_next:	ld bc,5
		add hl,bc		; step over "next "
		ld c,(hl)		; grab the var name
		call bas_get_var	; de=var value
		inc de			; var value++
		call bas_set_var	; update stored value - bc keeps offset
		ld hl,basformaxiters	; hl=address of for max iters array
		add hl,bc
		add hl,bc		; hl=correct address in loop array for this var
		push bc			; back up the offset
		ld bc,(hl)		; bc=stop value
		
		;;;;;;;;;;;;;;;;;;;;
		ld a,e			; Equality check on bc and de
		cp c			; e==c?
		jp nz,bas_stmt_next_keepgoing	; not yet, keep going
		ld a,d			
		cp b			; d==b?
		jp nz,bas_stmt_next_keepgoing	; not yet, keep going
		pop bc			; pop the offset (we don't need it, just clean the stack)
		jp bas_step_and_cont	; YES!! We've reached the end!!!
		;;;;;;;;;;;;;;;;;;;;
		
bas_stmt_next_keepgoing:
		pop bc			; bc=offset
		ld hl,basforlppoints
		add hl,bc		; hl=correct position in basforlppoints
		ld a,(hl)		; get target line number
		ld (bascurrline),a	; set it as current line
		jp basic_run_loop	; and go!
		
; GOSUB
bas_stmt_gosub:	ld bc,6
		add hl,bc		; hl points to target line num
		call AToUInt8		; a=target line num
		push af			; backup target line num
		ld a,(basgosubstackp)	; a=gosubstackpointer
		ld hl,basgosubstack	; hl=address of gosub stack
		ld b,0
		ld c,a			; bc=offset into stack
		add hl,bc		; hl=correct address in stack to write to
		inc a			; inc stack pointer
		ld (basgosubstackp),a	; write it back
		ld a,(bascurrline)	; d=current line num
		inc a			; d=current line+1 (ie correct return value)
		ld (hl),a		; stick it in the stack
		pop af			; restore a=target line number
		ld (bascurrline),a	; set line num to the target...
		jp basic_run_loop	; And go!!

; RETURN
bas_stmt_return:ld hl,basgosubstack	; hl=address of gosub stack
		ld a,(basgosubstackp)	; a=gosubstackpointer
		dec a			; step a back down (it currently points to next free slot)
		ld (basgosubstackp),a	; write stack pointer back
		ld hl,basgosubstack	; hl=address of gosub stack
		ld b,0
		ld c,a			; bc=offset into stack
		add hl,bc		; hl=correct address in stack to write to
		ld a,(hl)		; a=return line num
		ld (bascurrline),a	; set it.....
		jp basic_run_loop	; And go!!

; IF {expr} :)
basic_stmt_if:	ld bc,3
		add hl,bc		; Step over the "if "
		call Parse		; ok, LHS expression value is now in de and hl is advanced to the oper
		ld bc,de		; bc=LHS expression value
		ld de,gr_or_eq		; Try 2-char conditions first... >=
		call StrStarts
		jp c,bas_if_gt_or_eq
		ld de,ls_or_eq		; <=
		call StrStarts
		jp c,bas_if_lt_or_eq
		ld de,equal		; ==
		call StrStarts
		jp c,bas_if_equal
		ld de,not_equal		; <>
		call StrStarts
		jp c,bas_if_neq
		ld a,(hl)		; OK, try single char conditions... grab the oper
		cp '>'			; >
		jp z,bas_if_gthan
		cp '<'			; <
		jp z,bas_if_lthan
		jp bas_syn_err		; Didn't find a recognised one!
bas_if_lthan:	inc hl
		call Parse		; de=RHS
bas_if_lt_chk:	and a
		push hl
		ld hl,bc
		sbc hl,de
		pop hl
		jp c,bas_if_pass
		jp bas_if_fail
bas_if_gthan:	inc hl		
		call Parse		; de=RHS
		ld a,e			; Like gthan_or_eq but with not-equal check first...
		cp c
		jp nz,bas_if_gt_eq_ck	; Different -- do next check
		ld a,d
		cp b
		jp nz,bas_if_gt_eq_ck	; Different -- do next check
		jp bas_if_fail	; Same! Continue
bas_if_lt_or_eq:inc hl
		inc hl
		call Parse		; de=RHS
		ld a,e			; Equality check first
		cp c
		jp nz,bas_if_lt_chk	; Different -- do next check
		ld a,d
		cp b
		jp nz,bas_if_lt_chk	; Different -- do next check
		jp bas_if_pass		; Same! Pass :)
bas_if_gt_or_eq:inc hl
		inc hl
		call Parse		; de=RHS
bas_if_gt_eq_ck:and a
		push hl
		ld hl,bc
		sbc hl,de
		pop hl
		jp nc,bas_if_pass
		jp bas_if_fail
bas_if_equal:	inc hl
		inc hl
		call Parse		; de=RHS
		ld a,e			; compare e and c
		cp c
		jp nz,bas_if_fail	; different -- fail!
		ld a,d			; compare d and b
		cp b
		jp nz,bas_if_fail	; different -- fail!
		jp bas_if_pass		; must be same -- pass!
bas_if_neq:	inc hl
		inc hl
		call Parse		; de=RHS
		ld a,e			; compare e and c
		cp c
		jp nz,bas_if_pass	; different -- pass!
		ld a,d			; compare d and b
		cp b
		jp nz,bas_if_pass	; different -- pass!
		jp bas_if_fail		; must be identical -- fail!
bas_if_pass:	ld bc,6
		add hl,bc		; Skip past " then "
		call AToUInt8
		ld (bascurrline),a
		jp basic_run_loop
bas_if_fail:	ld bc,6
		add hl,bc		; Skip past " then "
		call AToUInt8		; Eat the then-case line number
		inc hl			; Step over a potential space " "
		ld de,basStmtElse
		call StrStarts		; Check we have "else"
		jp nc,bas_step_and_cont	; Nope -- just continue
		ld bc,5			; Step over "else "
		add hl,bc
		call AToUInt8		; Get else-case line number
		ld (bascurrline),a	; And set it
		jp basic_run_loop	; And go!!

; CLS
bas_stmt_cls:	call ClearScreen
		jp bas_step_and_cont
			
; PRINT
bas_stmt_print:	ld bc,6
		add hl,bc		; Skip "print "
bas_stmt_print_subseq_tok:
		ld a,(hl)		; Grab first char
		cp '"'			; Is it "?
		jp z,bas_stmt_print_str	; Yep -- printing a direct string, go do that!
		ld c,a			; Must be a variable. Copy the var name into c.
		inc hl			; Advance one step...
		ld a,(hl)		; ...and grab that char...
		cp '$'			; ...to check for a string var!
		jp z,bas_stmt_print_strvar	; Yep -- go print a string var.
		call bas_get_var	; OK, not a string var; get de=variable value
		push hl			; Backup string pointer
		ld hl,de		; hl=var value
		call PrintUInt16	; Print it
		pop hl			; Restore it
		jp bas_stmt_print_next_token
bas_stmt_print_strvar:
		inc hl
		; TODO: Print the string var. c already has its name.
		jp bas_stmt_print_next_token
bas_stmt_print_str:
		inc hl			; Step past the "
bas_stmt_ps_lp:ld a,(hl)
		cp '"'			; Check for closing "
		jp z,bas_stmt_ps_lp_dn	; We're done
		cp '~'			; Check for newline symbol
		jp nz,bas_stmt_ps_no_newline	; No newline
		call NewLine		; Newline!
		jp bas_stmt_ps_no_char
bas_stmt_ps_no_newline:
		call PrintChar
bas_stmt_ps_no_char:
		inc hl
		jp bas_stmt_ps_lp
bas_stmt_ps_lp_dn:
		inc hl
bas_stmt_print_next_token:
		ld a,(hl)
		cp ';'
		jp nz,bas_step_and_cont
		inc hl
		jp bas_stmt_print_subseq_tok
		
; INPUT (an int var)
bas_stmt_input:	ld bc,6			; step over "input "
		add hl,bc
		ld a,(hl)
		cp '"'			; check for a prompt
		jp nz,bas_ip_no_pt
		inc hl			; Step past the "
bas_ip_pt_lp:	ld a,(hl)
		cp '"'			; Check for closing "
		jp z,bas_ip_pt_lp_dn	; We're done
		cp '~'			; Check for newline symbol
		jp nz,bas_ip_no_nl	; No newline
		call NewLine		; Newline!
		jp bas_ip_nochar
bas_ip_no_nl:	call PrintChar
bas_ip_nochar:	inc hl
		jp bas_ip_pt_lp		
bas_ip_pt_lp_dn:inc hl			; step past "
		inc hl			; step past ,
bas_ip_no_pt:	ld c,(hl)		; get var name in c
		inc hl			; check for string var ($)
		ld a,(hl)
		cp '$'
		jp z,bas_stmt_instr	
		push bc			; to backup var name
		call GetString
		ld de,string_buffer
		call AToUInt16
		ld de,hl
		pop bc			; to restore var name
		call bas_set_var
		jp bas_step_and_cont
bas_stmt_instr:	push bc			; Input a string! First backup var name
		call GetString
		pop bc			; restore var name....
		; TODO: STORE THIS SHIT SOMEWHERE WITH A LITTLE LDIR
		jp bas_step_and_cont
		
; ASSIGNMENT
bas_stmt_ass:	dec hl			; Step back to var identifier
		ld c,(hl)		; Store var ident in c
		inc hl			; Step over var ident
		inc hl			; Step over = sign
		call Parse		; Invoke the cocking expression parser! Returns the result in de :))))
		call bas_set_var
		jp bas_step_and_cont

; GOTO		
bas_stmt_goto:	ld bc,5
		add hl,bc		; Skip past goto token and space
		call AToUInt8
		ld (bascurrline),a
		jp basic_run_loop
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Holy 16-bit unsigned int recursive descent expression parser, batman!!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Expects: hl=input pointer
; Returns: de=value; hl=updated input pointer	
Parse:		push bc			; backup bc
		call ParseFactors	; de=terminal value (num1)
Parse_lp:	ld a,(hl)		; Grab the oper
		cp '-'			; check for -
		jp z,Parse_sub		; found!
		cp '+'			; check for +
		jp z,Parse_add		; found!
		pop bc			; restore bc
		ret			; Not found -- return leaving result in de
Parse_sub:	inc hl			; do a sub... start with step!
		ld bc,de		; bc = num1
		push bc			; backup num1, we're about to trash it
		call ParseFactors	; de = num2
		pop bc			; restore bc=num1
		push hl			; backup input pointer, about to kill it
		ld hl,bc		; hl = num1
		and a			; Clear carry flag to prevent sbc off-by-1!
		sbc hl,de		; hl = num1 - num2 \o/
		ld de,hl		; update num1
		pop hl			; restore input pointer
		jp Parse_lp		; loop da shizz
Parse_add:	inc hl			; do an add... first step it!
		ld bc,de		; bc = num1
		push bc			; backup num1
		call ParseFactors	; de = num2
		pop bc			; restore bc=num1
		push hl			; backup input pointer, about to kill it
		ld hl,bc		; hl = num1
		add hl,de		; hl = num1 - num2 \o/
		ld de,hl		; update num1
		pop hl			; restore input pointer
		jp Parse_lp		; loop da shizz		

; Expects: hl=input pointer
; Returns: de=value; hl=updated input pointer		
ParseFactors:	call ParseTerminal	; de=terminal value (num1 in c)
ParseFact_lp:	ld a,(hl)		; char a = *hl;
		cp '/'			; check for /
		jp z,ParseFact_div	; found!
		cp '*'			; check for *
		jp z,ParseFact_mul	; found!
		ret			; Not found -- return (note we leave our retval in de)
ParseFact_mul:	inc hl			; step!
		ld bc,de		; bc = num1
		call ParseTerminal	; de = num2
		push hl			; backup input pointer, Mult16 will kill it
		call Mul16		; hl = bc*de
		ld de,hl		; update num1
		pop hl			; restore input pointer
		jp ParseFact_lp		; looooop
ParseFact_div:	inc hl			; step
		ld bc,de		; bc = num1
		call ParseTerminal	; de = num2
		push hl			; backup input pointer, Mult16 will kill it
		call Div16		; bc = bc/de
		ld de,bc		; update num1
		pop hl			; restore input pointer
		jp ParseFact_lp		; sloop
		
; Expects: hl=input pointer
; Returns: de=value; hl=updated input pointer
ParseTerminal:	push bc			; Gonna trash bc whatever we do so back it up
		ld a,(hl)		; First let's peek at this badger to check for a numeral (in which case it's a direct value) or a letter (in which case it's a var)
		cp 58
		jr nc,ParseTerm_notanum	; (Legit numeric chars are only 48-57!)
		ld de,hl
		call AToUInt16		; convert value into a UInt16 and store it (incrementing hl)
		ld bc,de		; backup current address after the num...
		ld de,hl		; set output value in de
		ld hl,bc		; restore current address
		pop bc			; restore bc
		ret
ParseTerm_notanum:
		cp '?'			; is it a call to random?!
		jp nz,ParseTerm_var	; no....
		push hl			; yes!!!! backup whatever the hell this is
		call Rand16		; call rand16 :))) hl=random num
		ld de,hl		; de=random num
		pop hl			; restore whatever hl was
		jp ParseTerm_done	; ok sorted :)
ParseTerm_var:	ld c,a			; c=var name
		call bas_get_var	; returns the value in de
ParseTerm_done:	pop bc			; restore bc
		inc hl			; manually inc hl to step over the var name
		ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Strings n things
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ls_or_eq:	defm "<="
		defb 0

gr_or_eq:	defm ">="
		defb 0

equal:		defm "=="
		defb 0

not_equal:	defm "<>"
		defb 0
		
basNew:		defm "new"
		defb 0
				
basList:	defm "list"
		defb 0
				
basRun:		defm "run"
		defb 0
		
basStmtRem:	defm "rem"
		defb 0

basStmtCls:	defm "cls"
		defb 0

basStmtInput:	defm "input "
		defb 0

basStmtEnd:	defm "end"
		defb 0
		
basStmtGoto:	defm "goto "
		defb 0
		
basStmtIf:	defm "if "
		defb 0

basStmtElse:	defm "else"
		defb 0
		
basStmtGosub:	defm "gosub "
		defb 0
		
basStmtReturn:	defm "return"
		defb 0

basStmtFor:	defm "for "
		defb 0
		
basStmtNext:	defm "next"
		defb 0
		
basStmtPrint:	defm "print "
		defb 0

basStmtSeed:	defm "seed "
		defb 0
		
basStmtInkey:	defm "inkey "
		defb 0
		
basMsgLineAdd1:	defm "Line "
		defb 0
		
basMsgLineAdd2: defm " added/edited"
		defb 0
		
basMsgLines:	defm " lines."
		defb 0
		
basMsgCurLine:	defm "DEBUG: Line about to execute:"
		defb 0
		
basMsgSynErr:	defm "Syntax error near:"
		defb 0
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; API FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
; *** API: ClearScreen ***
; Expects: nothing
ClearScreen:	ld a,12
		call PrintChar
		ret

; *** API: SandRand8 ***
; Seeds the PRNG
; Expects: hl - seed
SeedRand16:	ld (rand16_seed),hl
		ret	
		
; *** API: Rand16 ***
; Expects: Nothing
; Returns: Pseudorandom num in HL, period 65536
Rand16:		push de
		ld de,(rand16_seed)
		ld a,d
		ld h,e
		ld l,253
		or a
		sbc hl,de
		sbc a,0
		sbc hl,de
		ld d,0
		sbc a,d
		ld e,a
		sbc hl,de
		jr nc,Rand16_done
		inc hl
Rand16_done:
		ld (rand16_seed),hl
		pop de
		ret
		
; *** API: PrintChar ***
; Expects: a - ASCII char to print
PrintChar:	ex af,af'		; Save a			
PrintChar_wait_txempty:	
		in a,(uart_sr_csr)	; Wait for SR TxEmpty bit
		bit uart_txemptybit,a
		jr z,PrintChar_wait_txempty
		ex af,af'		; Load a
		out (uart_data),a	; Send it
		ret

; *** API: PrintLine ***
; Expects: bc - base address of zero-terminated string
PrintLine:	call PrintString
		call NewLine
		ret

; *** API: PrintString ***
; Expects: bc - base address of zero-terminated string
PrintString:	push bc
PrintString_wait_txrdy:	
		in a,(uart_sr_csr)	; Wait for SR TxEmpty bit
		bit uart_txemptybit,a
		jp z,PrintString_wait_txrdy
		ld a,(bc)		; Get current byte
		cp 0			; Check for 0
		jp z,PrintString_end
		out (uart_data),a	; Send it
		inc bc
		jp PrintString_wait_txrdy
PrintString_end:
		pop bc
		ret
		

; *** API: PrintUInt16 ***
; Input: HL = number to print
PrintUInt16:	push bc
		push de
		push hl
		ld de,int_buffer
		call Num2Dec16		
		ld a,0			; Add zero terminator
		ld (de),a			
		ld bc,int_buffer		
PrintUInt16Step:
		ld a,(bc)
		cp '0'
		jp nz,PrintUInt16Done
		inc bc
		jp PrintUInt16Step
PrintUInt16Done:
		call PrintString
		pop hl
		pop de
		pop bc
		ret
		
Num2Dec16:	ld bc,-10000
		call Num2Dec16_Num1
		ld bc,-1000
		call Num2Dec16_Num1
		ld bc,-100
		call Num2Dec16_Num1
		ld c,-10
		call Num2Dec16_Num1
		ld c,-1

Num2Dec16_Num1:	ld a,'0'-1
Num2Dec16_Num2:	inc a
		add hl,bc
		jr c,Num2Dec16_Num2
		sbc hl,bc
		ld (de),a
		inc de
		ret	

; *** API: AToUInt16 ***
; Expects: de - pointer to a zero-terminated string
; Returns: hl - UInt16
AToUInt16:	ld hl,0			; Clear hl
AToUInt16_loop:	ld a,(de)		; Get current char
		cp 48			; Stop on non-numeric chars of any kind; legit chars are 48-57!
		jr c,AToUInt16_end
		cp 58
		jr nc,AToUInt16_end
		sub 48			; Sub 48 to make ASCII char a decimal digit
		ld b,0
		ld c,a	 		; bc = new_digit
		
		push de
		ld de,hl
		add hl,de
		add hl,de
		add hl,de
		add hl,de
		add hl,de
		add hl,de
		add hl,de
		add hl,de
		add hl,de
		pop de
		add hl,bc		; hl = 10*old_number+new_digit
		inc de
		jr AToUInt16_loop
AToUInt16_end:	ret
		
; *** API: AToUInt8 ***
; Expects: hl - pointer to a zero-terminated string
; Returns: 8 bit unsigned integer in a
AToUInt8:	push bc
		ld c,0			; Clear c
AToUInt8_loop:	ld a,(hl)
		cp 0			; End-of-string?
		jr z,AToUInt8_end
		cp ' '			; MARK: Allow a space to terminate also!
		jr z,AToUInt8_end
		sub '0'			; (Sub 48)
		jr c,AToUInt8_end 	; Less than 0
		cp 10
		jr nc,AToUInt8_end 	; Greater than 9
		ld b,a	 		; b = new_digit
		ld a,c			; a = old_number
		sla a
		sla a			; a = 4*old_number
		add a,c			; a = 5*old_number
		sla a			; a = 10*old_number
		add a,b			; a = 10*old_number+new_digit
		ld c,a
		inc hl
		jr AToUInt8_loop
AToUInt8_end:	ld a,c
		pop bc
		ret
		
; *** API: GetString ***
; Expects: Nothing
; Returns: Received string in the string buffer at string_buffer
GetString:	push bc
		push hl
		ld l,255
		ld bc, string_buffer
GetString_loop:	in a,(uart_sr_csr)	; Wait for SR RxRdy
		bit uart_rxrdybit,a
		jr z,GetString_loop
		in a,(uart_data)	; Get char
		cp 10			; Check for 10 (maybe a serial client sent 13,10 as a newline)
		jp z,GetString_loop	; Meh, we ignore them
		cp 13			; Check for Enter pressed?
		jp z,GetString_done	; Done if so
		cp 8			; Check for backspace pressed...
		jp z,GetString_backspace		
		cp 127			; Check for delete pressed, treat it the same...
		jp z,GetString_backspace
		ld (bc),a		; Otherwise, store char
		call PrintChar		; Echo it too
		inc bc			; Inc address
		dec l			; Check buffer space left
		jp z,GetString_done	; Buffer out? Accept
		jp GetString_loop
GetString_done:	ld a,0
		ld (bc),a
		pop hl
		pop bc
		ret

GetString_backspace:
		ld h,a
		ld a,l
		cp 255
		jp z,GetString_loop	; Don't let them back up past 0!
		ld a,h
		
		call PrintChar		; Still print the backspace so display steps back
		dec bc			; But decrement the buffer address... 
		inc l			; ...and inc avail buffer space
		jp GetString_loop	; Go about your business..
		
; *** API: NewLine ***
; Expects: nothing
NewLine:	ex af,af'
		push bc
		ld bc,ascii_newline
		call PrintString
		pop bc
		ex af,af'
		ret

ascii_newline:	defb 10, 13, 0
	
; *** API: StrCmp ***
; Expects: hl and de to point to the strings to compare
; Returns: carry set if they're the same, unset otherwise
StrCmp:		push hl
		push de
		
StrCmp_lp:	ld a,(de)		; fetch *s1
		cp (hl)
		jp nz,StrCmp_diff	; quit if *s1 != *s2
		or a			; check *s1 for zero
		inc de
		inc hl
		jp nz,StrCmp_lp		; loop if *s1 != 0
		
		pop de
		pop hl
		scf			; we ran out of string and they ain't been different yet! set carry flag
		ret
		
StrCmp_diff:	pop de
		pop hl
		and a			; reset carry flag
		ret
	
; *** API: StrStarts ***
; Expects: hl and de to point to the strings to compare
; Returns: carry set if hl starts with de
StrStarts:	push hl
		push de
		
StrStarts_lp:	ld a,(de)		; fetch *s1
		cp 0			; if *s1 is 0 we got to end of s1 without a difference!
		jp z,StrStarts_same
		cp (hl)
		jp nz,StrStarts_diff	; quit if *s1 != *s2
		or a			; check *s1 for zero
		inc de
		inc hl
		jp nz,StrStarts_lp	; loop if *s1 != 0
		
StrStarts_same:	pop de
		pop hl
		scf			; we ran out of string and they ain't been different yet! set carry flag
		ret
		
StrStarts_diff:	pop de
		pop hl
		and a			; reset carry flag
		ret
	
; *** API: ScanChar ***
; Expects: Nothing
; Returns: Received character in a, or 0 if none waiting
ScanChar:	in a,(uart_sr_csr)
		bit uart_rxrdybit,a
		jr z,ScanChar_none
		in a,(uart_data)
		ret
ScanChar_none:	ld a,0
		ret
		

; *** API: Mul16 ***
; Performs HL = BC * DE
; Expects: BC, DE
; Returns: HL
Mul16:		ld a,b
		ld b,16
Mul16_lp:	add hl,hl
		sla c
		rla
		jr nc,Mul16_noadd
		add hl,de
Mul16_noadd:	djnz Mul16_lp
		ret

; *** API: Div16 ***
; Performs BC = BC / DE
; Expects: BC, DE
; Returns: BC = result, HL = remainder
Div16:		ld hl,0
		ld a,b
		ld b,8
Div16_Loop1:	rla
		adc hl,hl
		sbc hl,de
		jr nc,Div16_NoAdd1
		add hl,de
Div16_NoAdd1:	djnz Div16_Loop1
		ld b,a
		ld a,c
		ld c,b
		ld b,8
Div16_Loop2:	rla
		adc hl,hl
		sbc hl,de
		jr nc,Div16_NoAdd2
		add hl,de
Div16_NoAdd2:	djnz Div16_Loop2
		rla
		cpl
		ld b,a
		ld a,c
		ld c,b
		rla
		cpl
		ld b,a
		ret
				
#end		; Required for zasm