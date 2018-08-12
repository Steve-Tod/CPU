j Normal
j Interrupt
j Exit
Enable: lui $sp, 16384 # sp = 32'h40000000
addi $t1, $zero, 3 # t1 = 3
sw $t1, 8($sp) # TCON = 3'b011
sll $ra, $ra, 1 # avoid kernel mode
srl $ra, $ra, 1 
jr $ra
Normal: jal Enable
addi $s4, $zero, 16 # s4 = 16
addi $s3, $zero, 8 # s3 = 8
addi $s2, $zero, 1 # s2 = 1
addi $s1, $zero, 0 # s0 = 0
sw $zero, 8($sp) # TCON = 3'b000
lui $s5, 65535 # s5 = 32'hffff0000
sra $s6, $s5, 16 # s6 = 32'hffffffff
sw $s6, 4($sp) # TL = 32'hffffffff
addi $s5, $zero, 64110 # s5 = fffffa6e
sw $s5, 0($sp) # TH = 32'hfffffa6e
addi $s6, $zero, 3 # s6 = 3
sw $s6, 8($sp) # TCON = 3'b011
sw $zero, 12($sp) # led = 0
sw $zero, 20($sp) # digi = 0
Loop: lw $s0, 32($sp) # s0 = UART_CON
andi $s0, $s0, 8 # s0 & 5'b01000
bne $s0, $s3, Loop # if UART[4] != 1, Loop
beq $s1, $zero, Num1 # if s1 == 0: Num1
beq $s1, $s2, Num2 # if s1 == s2(1): Num2
Num1: lw $a0, 28($sp) # a0 = RXD
add $t6, $a0, $zero # t6 = a0 = RXD
addi $s1, $s1, 1 # s1 += 1
j Loop
Num2: lw $a1, 28($sp) # a1 = RXD
add $t7, $a1, $zero # t7 = a1 = RXD
GCD: sub $t4, $a1, $a0 # t4 = a1 - a0
bltz $t4, Divide # if t4 < 0(a1 < a0): Divide
add $t3, $zero, $a1 # t3 = a1
add $a1, $zero, $a0 # a1 = a0
add $a0, $zero, $t3 # a0 = t3 (swap(a0, a1))
Divide: sub $a0, $a0, $a1 # a0 = a0 - a1
sub $t4, $a1, $a0 # t4 = a1 - a0
bltz $t4, Divide # if t4 < 0(a1 < a0)): Divide
bne $a0, $zero, GCD # if a0 != 0: GCD
sw $a1, 24($sp) # TXD = a1
sw $a1, 12($sp) # led = a1
addi $s1, $zero, 0 # s1 = 0(reset to 0)
j Loop
Interrupt: lw $t8, 8($sp) # t8 = TCON
add $t9, $zero, $zero # t9 = 0
addi $t9, $t9, -7 # t9 = -7
and $t9, $t8, $t9 # t9 = TCON & 001
sw $t9, 8($sp) # TCON = {2'b00, TCON[0]}
lw $t0, 20($sp) # t0 = digi
srl $t0, $t0, 8 # t0 >> 8
addi $t1, $zero, 8 # t1 = 8
addi $t2, $zero, 4 # t2 = 4
andi $t3, $t6, 15 # t3 = t6(Num1) & 00001111
beq $t0, $t1, Decode # if t0 == t1(8): Decode light digi3
addi $t1, $zero, 4 # t1 = 4
addi $t2, $zero, 2 # t2 = 2
andi $t3, $t7, 240 # t3 = t7(Num2) & 11110000
srl $t3, $t3, 4 # t3 >> 4
beq $t0, $t1, Decode # if t0 == t1(4): Decode light digi2
addi $t1, $zero, 2 # t1 = 2
addi $t2, $zero, 1 # t2 = 1
andi $t3, $t7, 15 # t3 = t7 & 00001111
beq $t0, $t1, Decode # if t0 == t1(2): Decode light digi1
addi $t2, $zero, 8 # t2 = 8
andi $t3, $t6, 240 # t3 = t6 & 11110000
srl $t3, $t3, 4 # t3 >> 4
Decode: addi $t5, $zero, 192 # t5 = 11000000 light digi4
beq $t3, $zero, Next # if t3 == 0: Next
addi $t4, $zero, 1 # t4 = 1
addi $t5, $zero, 249 # t5 = 11111001
beq $t3, $t4, Next # if t3 == t4(1): Next
addi $t4, $zero, 2
addi $t5, $zero, 164
beq $t3, $t4, Next
addi $t4, $zero, 3
addi $t5, $zero, 176
beq $t3, $t4, Next
addi $t4, $zero, 4
addi $t5, $zero, 153
beq $t3, $t4, Next
addi $t4, $zero, 5
addi $t5, $zero, 146
beq $t3, $t4, Next
addi $t4, $zero, 6
addi $t5, $zero, 130
beq $t3, $t4, Next
addi $t4, $zero, 7
addi $t5, $zero, 248
beq $t3, $t4, Next
addi $t4, $zero, 8
addi $t5, $zero, 128
beq $t3, $t4, Next
addi $t4, $zero, 9
addi $t5, $zero, 144
beq $t3, $t4, Next
addi $t4, $zero, 10
addi $t5, $zero, 136
beq $t3, $t4, Next
addi $t4, $zero, 11
addi $t5, $zero, 131
beq $t3, $t4, Next
addi $t4, $zero, 12
addi $t5, $zero, 198
beq $t3, $t4, Next	
addi $t4, $zero, 13
addi $t5, $zero, 161
beq $t3, $t4, Next
addi $t4, $zero, 14
addi $t5, $zero, 134
beq $t3, $t4, Next
addi $t5, $zero, 142
Next: sll $t2, $t2, 8 # t2 << 8
add $t0, $t2, $t5 # t0 = t2 + t5
sw $t0, 20($sp) # digi = t0
lw $t8, 8($sp) # t8 = TCON
addi $t9, $zero, 2 # t9 = 010
or $t9, $t8, $t9 # t9 = TCON | 010
sw $t9, 8($sp) # TCON = {TCON[2], 1, TCON[0]}
jr $k0 # PC when Interrupt
Exit: sll $zero, $zero, 0