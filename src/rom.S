	.org 0x0
.global _start
   .set noat
_start:
   ori $1,$0,0x0001        # $1 = $0 | 0x0001 = 0x0001
