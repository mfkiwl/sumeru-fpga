.global _start
_start:
    csrrwi zero,0x100,1
    csrrwi zero,0x103,1
    li a0,0x20
    lh t0,0(zero)
    lh t1,0(zero)
    beq t0,t1,vtrue
vfalse:
    csrrwi zero,0x103,1
    j vfalse
vtrue:
    csrrwi zero,0x103,0
    jalr zero,0(a0) 

.align(8)
globals:
