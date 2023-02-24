
# x = (c/2 ^ (b | 16d)) * 4b

# y = ((d/64 + 5a) / a/2) - (a/32 % c)


.data

counter: .word 0


.text

evalX:
    sll $t0 $a3 4    # Evaluates the "16d" part
    or $t1 $a1 $t0   # Evaluates the (b | 16d) part
    li $t0 2
    div $a2 $t0
    mflo $t0         # Evaluates the (c/2) part
    xor $t0 $t1 $t0  # Evaluates the (c/2 ^ (b | 16d)) part
    sll $t1 $a1 2    # Evaluates the "4b" part
    mult $t0 $t1
    mflo $v0         # Evalues the full expression for x. Stores it in v0.
    jr $ra
    nop

evalY:
    sll $t0 $a0 2    # Gets 4a
    add $t0 $t0 $a0  # Evaluates the part "5a"
    li $t1 64
    div $a3 $t1
    mflo $t1         # Evaluates the part "d/64"
    add $t0 $t0 $t1  # Evaluates the part (d/64 + 5a)
    li $t1 2
    div $a0 $t1
    mflo $t1         # Evaluates the part (a/2)
    div $t0 $t1
    mflo $t0         # Evaluates the part ((d/64 + 5a) / a/2)
    li $t1 32
    div $a0 $t1
    mflo $t1         # Evaluates the part (a/32)
    div $t1 $a2
    mfhi $t1         # Evaluates the part (a/32 % c).
    sub $v0 $t0 $t1  # Evaluates the full expression for y and stores it in v0.
    jr $ra
    nop

proc:

    # a0 -> Number of Groups
    # a1 -> Tuple of input data (starting address)
    # a2 -> Output tuple (starting address)

    move $t2 $a0		# Move the number of groups into register t2.
    move $t6 $a1        # Move the starting address of the tuple of input data to t6.
    move $t7 $a2        # Move the starting address of the output tuple to t7.
    lw $t3 counter
    li $t4 36           # 36 bytes in a "tuple" so multiply counter by 36.
    mult $t3 $t4
    mflo $t4
    addu $t4 $t4 $a1    # tupleNumberStart (stored in $t4) = (36 * counter) + inputValues address

    lw $a0 20($t4)      # a
    lw $a1 4($t4)       # b
    lw $a2 0($t4)       # c
    lw $a3 8($t4)       # d

    jal evalX
    move $t8 $v0        # Result of evalX to t8.

    jal evalY
    move $a0 $t8        # Result of evalX to a0
    move $a1 $v0        # Result of evalX to a1

    jal numb1
    move $t9 $v0

    jal numb2
    addu $v0 $t9 $v0

    move $a0 $t2
    move $a1 $t6
    move $a2 $t7        # Restore current a0, a1 and a2 values in their original registers.

    li $t6 4
    mult $t3 $t6
    mflo $t7
    addu $t7 $t7 $a2
    sb $v0 0($t7)      # Store byte in output block.

    addi $t3 $t3 1
    la $t5 counter
    sw $t3 0($t5)       # Add 1 to the counter and store it in its appropriate address.

    bne $t3 $a0 proc
    jal exit
    nop

numb1:
    and    $v0, $a0, $a1 # Output is the bit-wise and of the inputs.
    jr     $ra
    nop

numb2:
    sub    $v0, $a0, $a1 # Output is the difference of the inputs.
    jr     $ra
    nop

exit:
    li $v0 10
    syscall
    nop