# 
# z85decode.asm (incomplete)  
# 
# 
# This MIPS program reads lines of Base 85-encoded (Z85 variant by ZeroMQ) text from standard 
# input, and outputs the decoded bytes to standard output. 
# 
# INSERT YOUR CODE AT THE POINT INDICATED BELOW. 
# 
# Data segment 
# 
.data 
# Decoder lookup table  
decoder: .byte 
	0x00, 0x44, 0x00, 0x54, 0x53, 0x52, 0x48, 0x00, 0x4B, 0x4C, 0x46, 0x41, 0x00, 
	0x3F, 0x3E, 0x45, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 
	0x40, 0x00, 0x49, 0x42, 0x4A, 0x47, 0x51, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 
	0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32, 
	0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x4D, 0x00, 
	0x4E, 0x43, 0x00, 0x00, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 
	0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 
	0x20, 0x21, 0x22, 0x23, 0x4F, 0x00, 0x50, 0x00, 0x00 
	
alphabet: .ascii 
"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%$#" 

# Space to read a line into. 
inbuffer: .space 1000 
first: .byte 0 
second: .byte 0 
third: .byte 0 
fourth: .byte 0 
chars: .space 4 
 
# 
# Text segment 
# 
.text 

# Program entry. 
main: 

# The first byte we're expecting is byte 0 of a group of 5. 
loop: la $t9, char0 

# Read a string from standard input. 
li $v0, 8 
la $a0, inbuffer 
li $a1, 1000 
syscall 

# Is this an empty line? 
# We will use an empty line to indicate the end of the Base 85 data. That is two new line characters. 
lb $t0, inbuffer 

# First character newline means there was no text on this line, so end the program. 
beq $t0, 10, alldone 

# Walk along the string. Start at the beginning.  
la $t8, inbuffer 

# Go back to where we left off last time (byte 0, 1, 2, 3 or 4).  
jr $t9 

# Get four characters at a time. 
# Getting byte 0 
char0: 
lbu $s0, 0($t8) 
add $t8, $t8, 1 
beq $s0, 10, linedone 

# Now up to byte 1.  
la $t9, char1 
char1: 
lbu $s1, 0($t8) 
add $t8, $t8, 1 
beq $s1, 10, linedone 

# Now up to byte 2.  
la $t9, char2 
char2: 
lbu $s2, 0($t8) 
add $t8, $t8, 1 
beq $s2, 10, linedone 

# Now up to byte 3. 
la $t9, char3 
char3: 
lbu $s3, 0($t8) 
add $t8, $t8, 1 
beq $s3, 10, linedone 

# Now up to byte 4. 
la $t9, char4 
char4: 
lbu $s4, 0($t8) 
add $t8, $t8, 1 
beq $s4, 10, linedone 

# Now all bytes in this block are read. 
# Four Z85 characters are now in $s0, $s1, $s2, $s3 and $s4.  

bytesdone: 

# 
# DO NOT DELETE THIS LINE. 
#####

# # 
# PUT YOUR ANSWER HERE. 
# Your answer should not modify $t8 or $t9, as they are used by  
# the above code. 

# Get the decoder table address
la $t0, decoder

# Converting the chars to their Z85 values
# Char 0
addi $t1, $s0, -32
add $t1, $t1, $t0
lbu $t1, 0($t1)

# Char 1
addi $t2, $s1, -32
add $t2, $t2, $t0
lbu $t2, 0($t2)

# Char 2
addi $t3, $s2, -32
add $t3, $t3, $t0
lbu $t3, 0($t3)

# Char 3
addi $t4, $s3, -32
add $t4, $t4, $t0
lbu $t4, 0($t4)

# Char 4
addi $t5, $s4, -32
add $t5, $t5, $t0
lbu $t5, 0($t5)

# Building the 32 bit number

# num = char0, get 85 ready to multiply with
move $t6, $t1
li $t7, 85

# num = num*85 + char1
mul $t6, $t6, $t7
add $t6, $t6, $t2

# num = num*85 + char2
mul $t6, $t6, $t7
add $t6, $t6, $t3

# num = num*85 + char3
mul $t6, $t6, $t7
add $t6, $t6, $t4

# num = num*85 + char4
mul $t6, $t6, $t7
add $t6, $t6, $t5

# Extracting the bytes and printing them

# byte 0
srl $a0, $t6, 24
andi $a0, $a0, 0xFF
li $v0, 11
syscall

# byte 1
srl $a0, $t6, 16
andi $a0, $a0, 0xFF
li $v0, 11
syscall

# byte 2
srl $a0, $t6, 8
andi $a0, $a0, 0xFF
li $v0, 11
syscall

# byte 3
srl $a0, $t6, 0
andi $a0, $a0, 0xFF
li $v0, 11
syscall



#####
# 

endgroup: 
# Go back to do next bunch of five bytes. We are now expecting byte 0 of 5. 
j char0 

linedone: 
# Line is finished; go get another one.  
j loop 

alldone:  
# Exit. 
li $v0, 10 
syscall