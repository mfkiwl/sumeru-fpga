.global _start
_start:
    csrrwi zero,0x100,1
    csrrwi zero,0x103,1
    li x1, -5
    li x2, 3
    li x4, -15
    mul x3,x1,x2
    beq x3,x4,vtrue

vfalse:
    csrrwi zero,0x103,1
    j vfalse

vtrue:
    csrrwi zero,0x103,0
    j vtrue