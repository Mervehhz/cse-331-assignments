.data

fin: .asciiz "array_input.txt"
outf: .asciiz "array_output.txt"
out_text: .asciiz "Array_outp: [,"
buffer: .asciiz ""
.align 2
A: .space 1024
temp1: .space 1024
temp2: .space 1024
fout: .space 1024
each_num: .space 1024
size: .asciiz "size=,"

.text

#open a file for reading
li   $v0, 13       # system call for open file
la   $a0, fin      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor 

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor 
la   $a1, buffer   # address of buffer to which to read
li   $a2, 1024     # hardcoded buffer length
syscall            # read from file

# Close the file 
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall            # close file

move $s0, $a1
li $t0, '['
li $t1, ']'
li $t2, ' '
li $t3, ','
la $s1, A
la $s6, temp1
la $s7, temp2

for_loop_to_left_bracket:
addi $s0, $s0, 1
lb $t5, 0($s0)
bne $t0, $t5, for_loop_to_left_bracket

addi $s0, $s0, 1
li $s1, 0
li $t4, 0
#after char '[' in $s0
for_loop_to_take_numbers:
li $t6, 0
lb $t5, 0($s0) # $t5 has each char in input file after left bracket
beq $t5, $t1, end_for # if $t5 == right bracket

#first condition whether number or not, if $t5 != space
bne $t5, $t2, is_digit
beq $t5, $t2, else #if $t5 == space

is_digit:
bne $t5, $t3, add_to_array

beq $t5, $t2, else
beq $t5, $t3, else

#add to array by generating int
add_to_array:
addi $t6, $t5, -48
addi $s0, $s0, 1
lb $t5, 0($s0)
beq $t5, $t2, store
beq $t5, $t3, store
beq $t5, $t1, end_for

multi_and_add:
li $t7, 10
mul $t6, $t6, $t7
addi $t7, $t5, -48
add $t6, $t6, $t7

addi $s0, $s0, 1
lb $t5, 0($s0)
beq $t5, $t2, store # if $t5 == space
beq $t5, $t3, store #if $t5 == comma
beq $t5, $t1, end_for
j multi_and_add

store:
sw $t6, A($s1) # storing numbers in $s1
addi $s1,$s1,4
addi $t4, $t4, 1

else:
addi $s0, $s0, 1
j for_loop_to_take_numbers

end_for:
sw $t6, A($s1)
addi $t4, $t4, 1 #size of array

li $t0, 0 # i=0

li $s6, 0
li $s7, 0
li $s0, 0 # counter for length array
for1_loop:
li $t2, 1 # a=1
slt $t1, $t0, $t4 # i<size
beq $t1, 1, for2_loop
beq $t1, 0, end_for1

for2_loop:
li $t7, 0
move $t3, $t0 # j=i
add $t5, $t0, $t2 # k=i+a
slt $t1, $t2, $t4 # a<size
beq $t1, 1, for3_loop
beq $t1, 0, inc_outer_loop1_var
li $s4, 0 #counter for second length array

for3_loop:
slt $t1, $t5, $t4 # k<size
beq $t1, 1, determine_value
beq $t1, 0, inc_outer_loop2_var

determine_value:
li $t6,4
mul $t6, $t3, $t6
lw $s3, A($t6)
li $t6,4
mul $t6, $t5, $t6
lw $s5, A($t6)
beq $t7, 0, print_first_index
beq $t7, 1, compare

print_first_index:
addi $t7, $t7, 1
li $t6, 4
mul $t6, $t3, $t6
lw $s3, A($t6)
li $v0, 1
move $a0, $s3
syscall

beq $s0, 0, store_first_index_1array
bgt $t2, 1, ignore
j compare

store_first_index_1array:
sw $s3, temp1($s6)
addi $s6,$s6,4
addi $s0, $s0, 4
j compare

ignore:
beq $s4, 0, store_first_index_2array
j compare

store_first_index_2array:
sw $s3, temp2($s7)
addi $s7,$s7,4
addi $s4, $s4, 4

compare:
slt $t1, $s3, $s5
beq $t1, 1, assign
addi $t5, $t5, 1
beq $t1, 0, for3_loop

assign:
move $t3, $t5

store2:
#print other index
li $v0, 1
move $a0, $s5
syscall
addi $t5, $t5, 1
bgt $t2, 1, store_inner2

store_inner1:
sw $s5, temp1($s6)
addi $s6,$s6,4
addi $s0, $s0, 4

j for3_loop
li $s4, 0

store_inner2:
sw $s5, temp2($s7)
addi $s7,$s7,4
addi $s4, $s4, 4

li $t6, 0
slt $t1, $s0, $s4
beq $t1, 1, new_longest_array
j for3_loop

new_longest_array:
li $t1, 0
move $s0, $s4
li $s4, 0


copy_loop:
beq $t1, $s0, end_copy
lw $t8, temp2($t1)
sw $t8, temp1($t1)
addi $t1, $t1, 4
move $k1 , $s0
addi $k1, $k1, -4
j copy_loop

end_copy:

j for3_loop

inc_outer_loop2_var:
addi $t2, $t2, 1 # a++

li $t1, '\n'
li $v0, 11
move $a0, $t1
syscall

j for2_loop

inc_outer_loop1_var:
addi $t0, $t0, 1 # i++
j for1_loop

end_for1:


li $t0, 0

printx:
li $v0, 1
lw $a0, temp1($t0)
syscall
addi $t0, $t0, 4
bne $t0, $k1, printx

end_printx:

li $t1, '\n'
li $v0, 11
move $a0, $t1
syscall

li $v0, 4
la $a0, size
syscall

li $v0, 1
move $a0, $k1
syscall

#writing

li $t7, 0

text_loop:
lb $t1, out_text($t7)
li $t2, ','
beq $t1, $t2, end_text
sb $t1, fout($t7)
addi $t1, $t1, 1
addi $t7, $t7, 1
j text_loop

end_text:
#sb $t2, fout($t7)
#addi $t7, $t7, 1
#li $t2, ' '
#sb $t2, fout($t7)
#addi $t7, $t7, 1
#li $t2, '['
#sb $t2, fout($t7)
#addi $t7, $t7, 1

li $t0, 0 

int2str:
li $t4, 0
beq $t0, $k1, exit_program
lw $t1, temp1($t0) 		

int_loop:
li $t5, 0
beq $t1, $t5, end_int_loop 
li $t3, 10
div $t1, $t3
mfhi $t2  
addi $t2, $t2 ,'0'
sb $t2, each_num($t4) 
addi $t4, $t4, 1
div $t1, $t1, $t3
j int_loop

end_int_loop:
addi $t4, $t4, -1


reverse_num: 
li $t5, -1
beq $t5, $t4, end_reverse
lb $t6, each_num($t4)
sb $t6, fout($t7)
addi $t7, $t7, 1
addi $t4, $t4, -1
j reverse_num

end_reverse:

addi $t0, $t0, 4
beq $t0, $k1, exit_program
li $t6, ','
sb $t6, fout($t7)
addi $t7, $t7, 1
li $t6, ' '
sb $t6, fout($t7)
addi $t7, $t7, 1

j int2str

exit_program:
li $t5, ']'
sb $t5, fout($t7)
addi $t7, $t7, 1

li $t3, 0
la $t1, size
size_loop:
li $t2, ','
lb $t3, 0($t1)
beq $t3, $t2, end_size
sb $t3 , fout($t7)
addi $t1, $t1, 1
addi $t7, $t7, 1
j size_loop

end_size:
li $t0, 4
div $k1, $k1, $t0
addi $k1, $k1, '0'
sb $k1, fout($t7)

li $v0, 4
la $a0, fout
syscall

write_file:
 # Open (for writing) a file that does not exist
 li $v0, 13 # system call for open file
 la $a0, outf # fout file name
 li $a1, 1 # Open for writing (flags are 0: read, 1: write)
 li $a2, 0 # mode is ignored
 syscall # open a file (file descriptor returned in $v0)
 move $s6, $v0 # save the file descriptor 


# Write to file just opened
 li $v0, 15 # system call for write to file
 move $a0, $s6 # file descriptor 
 la $a1, fout # address of buffer from which to write
 li $a2, 1024 # hardcoded buffer length
 syscall # write to file 


 # Close the file 
 li $v0, 16 # system call for close file
 move $a0, $s6 # file descriptor to close
 syscall # close