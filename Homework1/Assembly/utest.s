la $t0, A
la $t1, B
la $t2, C
lw $a0, 0($t0)
lw $a1, 0($t1)
add $a0, $a0, $a1
sw $a0, 0($t2)
lw $a2, 0($t2)
beq $a0, $a2, check
addi $a0, $a0, -1
check: addi $a0, $a0, 1
nand $s0, $a0, $a1
la $sp, STACK
lw $sp, 0($sp)
la $s2, SUBROUTINE
jalr $s2, $ra
halt

SUBROUTINE:addi $a0, $a0, 1
jalr $ra, $zero


A: .word 42
B: .word 37
C: .word 0
STACK: .word 0x1000
