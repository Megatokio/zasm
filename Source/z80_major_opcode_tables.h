/*	Copyright  (c)	Günter Woigk 2014 - 2015
					mailto:kio@little-bat.de

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	Permission to use, copy, modify, distribute, and sell this software and
	its documentation for any purpose is hereby granted without fee, provided
	that the above copyright notice appear in all copies and that both that
	copyright notice and this permission notice appear in supporting
	documentation, and that the name of the copyright holder not be used
	in advertising or publicity pertaining to distribution of the software
	without specific, written prior permission.  The copyright holder makes no
	representations about the suitability of this software for any purpose.
	It is provided "as is" without express or implied warranty.

	THE COPYRIGHT HOLDER DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
	INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
	EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY SPECIAL, INDIRECT OR
	CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
	DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
	TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
	PERFORMANCE OF THIS SOFTWARE.
*/


#ifdef O

// opcodes:

O(NOP,"nop"),	O(LD,"ld"),		O(INC,"inc"),
O(DEC,"dec"),	O(RLCA,"rlca"),	O(EX,"ex"),		O(RRCA,"rrca"),
O(DJNZ,"djnz"),	O(RLA,"rla"),	O(JR,"jr"),		O(RRA,"rra"),
O(DAA,"daa"),	O(CPL,"cpl"),	O(HALT,"halt"),	O(SCF,"scf"),
O(CCF,"ccf"),	O(IN,"in"),		O(OUT,"out"),	O(NEG,"neg"),
O(RETN,"retn"),	O(IM,"im"),		O(RETI,"reti"),	O(RRD,"rrd"),
O(RLD,"rld"),	O(CALL,"call"),	O(PUSH,"push"),	O(RST,"rst"),
O(EXX,"exx"),	O(DI,"di"),		O(EI,"ei"),
O(RET,"ret"),	O(POP,"pop"),	O(JP,"jp"),

O(ADD,"add"),	O(ADC,"adc"),	O(SUB,"sub"),	O(SBC,"sbc"),
O(AND,"and"),	O(XOR,"xor"),	O(OR,"or"),		O(CP,"cp"),
O(RLC,"rlc"),	O(RRC,"rrc"),	O(RL,"rl"),		O(RR,"rr"),
O(SLA,"sla"),	O(SRA,"sra"),	O(SLL,"sll"),	O(SRL,"srl"),
O(LDI,"ldi"),	O(CPI,"cpi"),	O(INI,"ini"),	O(OUTI,"outi"),
O(LDD,"ldd"),	O(CPD,"cpd"),	O(IND,"ind"),	O(OUTD,"outd"),
O(LDIR,"ldir"),	O(CPIR,"cpir"),	O(INIR,"inir"),	O(OTIR,"otir"),
O(LDDR,"lddr"),	O(CPDR,"cpdr"),	O(INDR,"indr"),	O(OTDR,"otdr"),
O(BIT,"bit"),	O(RES,"res"),	O(SET,"set"),

#undef O
#endif


#ifdef A

// arguments:

A(AF2,"af'"),	// must come before AF

A(BC,"bc"),	A(DE,"de"),	A(HL,"hl"),	A(SP,"sp"),
A(IX,"ix"),	A(IY,"iy"),	A(AF,"af"),	A(PC,"pc"),
A(XH,"xh"),	A(XL,"xl"),	A(YH,"yh"),	A(YL,"yl"),
A(XH,"ixh"),A(XL,"ixl"),A(YH,"iyh"),A(YL,"iyl"),
A(Z,"z"),	A(NZ,"nz"),	A(NC,"nc"),	A(PO,"po"),
A(PE,"pe"),	A(M,"m"),	A(P,"p"),
A(B,"b"),	A(C,"c"),	A(D,"d"),	A(E,"e"),
A(H,"h"),	A(L,"l"),	A(A,"a"),	A(XHL,"(hl)"),
A(F,"f"),	A(R,"r"),	A(I,"i"),

A(N,"n"),	A(N,"nn"),	A(XN,"(n)"), A(XN,"(nn)"), A(N,"dis"), A(N,"offs"),

A(XBC,"(bc)"), A(XDE,"(de)"),	A(XSP,"(sp)"),	A(XC,"(c)"),

A(XIX,"(ix+n)"), A(XIX,"(ix+offs)"), A(XIX,"(ix+dis)"),
A(XIY,"(iy+n)"), A(XIY,"(iy+offs)"), A(XIY,"(iy+dis)"),

A(N0,"0"),		A(N1,"1"),		A(N2,"2"),		A(N3,"3"),
A(N4,"4"),		A(N5,"5"),		A(N6,"6"),		A(N7,"7"),
				A(N1,"8"),		A(N2,"16"),		A(N3,"24"),
A(N4,"32"),		A(N5,"40"),		A(N6,"48"),		A(N7,"56"),
A(N0,"$00"),	A(N1,"$08"),	A(N2,"$10"),	A(N3,"$18"),
A(N4,"$20"),	A(N5,"$28"),	A(N6,"$30"),	A(N7,"$38"),
A(N0,"0x00"),	A(N1,"0x08"),	A(N2,"0x10"),	A(N3,"0x18"),
A(N4,"0x20"),	A(N5,"0x28"),	A(N6,"0x30"),	A(N7,"0x38"),
A(N0,"00h"),	A(N1,"08h"),	A(N2,"10h"),	A(N3,"18h"),
A(N4,"20h"),	A(N5,"28h"),	A(N6,"30h"),	A(N7,"38h"),

#undef A
#endif











