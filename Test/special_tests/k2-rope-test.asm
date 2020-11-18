#!/usr/local/bin/zasm -o original/

#target ram
#code CODE,0
#code RAM
#code ROM
#code ROP
#data DATA
#code GSINIT
#test TEST, 0xC000

#include "k2-rope-core-macros.s"
#include "k2-rope-core.s"
#include "k2-rope-core-macros.s"

