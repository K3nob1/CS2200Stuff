!=================================================================
! General conventions:
!   1) Stack grows from high addresses to low addresses, and the
!      top of the stack points to valid data
!
!   2) Register usage is as implied by assembler names and manual
!
!   3) Function Calling Convention:
!
!       Setup)
!       * Immediately upon entering a function, push the RA on the stack.
!       * Next, push all the registers used by the function on the stack.
!
!       Teardown)
!       * Load the return value in $v0.
!       * Pop any saved registers from the stack back into the registers.
!       * Pop the RA back into $ra.
!       * Return by executing jalr $ra, $zero.
!=================================================================

!vector table
vector0:    .fill 0x00000000 !0
            .fill 0x00000000 !1
            .fill 0x00000000 !2
            .fill 0x00000000
            .fill 0x00000000 !4
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000 !8
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000 !15
!end vector table

main:           la $sp, stack           ! Initialize stack pointer
                lw $sp, 0($sp)          
                
                ! Install timer interrupt handler into vector table
                la $a0, ti_inthandler
		la $a1, vector0
		sw $a0, 1($a1)		! Load and store inthandler into vector1
 
                ei                      ! Don't forget to enable interrupts...

                la $at, factorial       ! load address of factorial label into $at
                addi $a0, $zero, 10      ! $a0 = 5, the number to factorialize
                jalr $at, $ra           ! jump to factorial, set $ra to return addr
                halt                    ! when we return, just halt

factorial:      addi    $sp, $sp, -1    ! push RA
                sw      $ra, 0($sp)
                addi    $sp, $sp, -1    ! push a0
                sw      $a0, 0($sp)
                addi    $sp, $sp, -1    ! push s0
                sw      $s0, 0($sp)
                addi    $sp, $sp, -1    ! push s1
                sw      $s1, 0($sp)

                beq     $a0, $zero, base_zero
                addi    $s1, $zero, 1
                beq     $a0, $s1, base_one
                beq     $zero, $zero, recurse
                
    base_zero:  addi    $v0, $zero, 1   ! 0! = 1
                beq     $zero, $zero, done

    base_one:   addi    $v0, $zero, 1   ! 1! = 1
                beq     $zero, $zero, done

    recurse:    add     $s1, $a0, $zero     ! save n in s1
                addi    $a0, $a0, -1        ! n! = n * (n-1)!
                la      $at, factorial
                jalr    $at, $ra

                add     $s0, $v0, $zero     ! use s0 to store (n-1)!
                add     $v0, $zero, $zero   ! use v0 as sum register
        mul:    beq     $s1, $zero, done    ! use s1 as counter (from n to 0)
                add     $v0, $v0, $s0
                addi    $s1, $s1, -1
                beq     $zero, $zero, mul

    done:       lw      $s1, 0($sp)     ! pop s1
                addi    $sp, $sp, 1
                lw      $s0, 0($sp)     ! pop s0
                addi    $sp, $sp, 1
                lw      $a0, 0($sp)     ! pop a0
                addi    $sp, $sp, 1
                lw      $ra, 0($sp)     ! pop RA
                addi    $sp, $sp, 1
                jalr    $ra, $zero

ti_inthandler:


		addi $sp, $sp, -1	! Push $k0
		sw $k0, 0($sp)

		ei			! enable interrupt

		! Saving Processor Regs
		addi $sp, $sp, -2	! store at and v0
		sw $at, 1($sp)
		sw $v0, 0($sp)

		addi $sp, $sp, -5	! Store the arg/temp regs
		sw $a0, 4($sp)
		sw $a1, 3($sp)		
		sw $a2, 2($sp)
		sw $a3, 1($sp)
		sw $a4, 0($sp)

		addi $sp, $sp, -4	! Store the saved regs
		sw $s0, 3($sp)
		sw $s1, 2($sp)	
		sw $s2, 1($sp)
		sw $s3, 0($sp)

		addi $sp, $sp, -2	! Store fp and ra
		sw $fp, 1($sp)
		sw $ra, 0($sp)

		!Executing code
		la $a0, seconds 	! Load seconds
		lw $a1, 0($a0)	
		lw $a2, 0($a1)

		addi $a2, $a2, 1
		addi $a3, $zero, 60
		beq $a2, $a3, incrmin	! If limit is reached branch to incrementing hours
		sw $a2, 0($a1)

		! Restore registers
fin:		addi $sp, $sp, 13
		lw $ra, 13($sp)
		lw $fp, 12($sp)
		lw $s3, 11($sp)
		lw $s2, 10($sp)
		lw $s1, 9($sp)
		lw $s0, 8($sp)
		lw $a4, 7($sp)
		lw $a3, 6($sp)
		lw $a2, 5($sp)
		lw $a1, 4($sp)
		lw $a0, 3($sp)
		lw $v0, 2($sp)
		lw $at, 1($sp)

		di		! Disable and restore $k0
		lw $k0, 0($sp) 
		addi $sp, $sp, 1

		reti		! Return from interrupt

incrmin:	sw $zero, 0($a1)	! First set seconds back to zero
		lw $a4, 1($a0)		! Reusing a0 to get minutes
		lw $a2, 0($a4)
		addi $a2, $a2, 1
		beq $a2, $a3, incrhours ! If limit is reached branch to incrementing hours
		sw $a2, 0($a4)		! Else store the number you got
		beq $zero, $zero, fin


incrhours:	sw $zero, 0($a4)	! Set minutes back to zero
		lw $a4, 2($a0)
		lw $a2, 0($a4)
		addi $a2, $a2, 1
		sw $a2, 0($a4)
		beq $zero, $zero, fin




stack:      .fill 0xA00000
seconds:    .fill 0xFFFFFC
minutes:    .fill 0xFFFFFD
hours:      .fill 0xFFFFFE
