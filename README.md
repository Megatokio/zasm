
## zasm - Z80, 8080 and Z180 assembler

#### Features

_zasm_ accepts source code using **8080** and **Z80 syntax** and can **convert 8080 syntax to Z80**.  
_zasm_ supports various historically used syntax variants and the syntax emitted by sdcc.

_zasm_ can generate binary files or Intel Hex or Motorola S19 files.  
_zasm_ can generate various specialized files for **Sinclair** and **Jupiter Ace** and **.tzx tape** files.  
_zasm_ can include the generated code and **accumulated cpu cycles** in the list output file.  
_zasm_ can run **automated tests** on the generated code.  

_zasm_ supports
- **character set conversion**, e.g. for the ZX80 and ZX81 and proper decoding of utf-8 in text literals. 
- multiple code segments 
- including and compiling of c source with sdcc.  
- **automatic label resolving** from libraries 
- automatic **compression** using ZX7 
- well known illegal instructions 
- multiple instructions per line using '\\' separator 

the source can start with a BOM and with a shebang '#!' in line 1.  
the source (text literals) must either to be 7-bit clean or utf-8 encoded.

#### New in version 4.4

Run automated tests on the generated code.

#### Web links

Project web page: [k1.spdns.de](https://k1.spdns.de/Develop/Projects/zasm/Distributions/).  
There you can download Binaries for OSX and Linux and some older versions for other OSes  
and there you find the [Documentation](https://k1.spdns.de/Develop/Projects/zasm/Documentation/) 
and an [online assembler](https://k1.spdns.de/cgi-bin/zasm.cgi).

