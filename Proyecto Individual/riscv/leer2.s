.section .data

file_path:      .asciz "prueba.txt"
buffer:         .space 2205      # Buffer size to contain the file content
ejemploFloat:   .float 4.566
constante:      .float 75.0
buffer_addr:    .word 0
direccion:      .word 0x100

.align 1

.section .text

.globl _start

#------------------------------------- FILE READING -----------------------------------
_start:
    # Open the file
    la a0, file_path
    li a1, 0        # O_RDONLY (Read mode)
    li a7, 1025     # Open system call number
    ecall

    # Check for errors in file opening (a0 contains the file descriptor or error code)
    li t0, -1
    bne a0, t0, error

    mv a1, a0       # Store file descriptor in a1
    la a0, buffer   # Buffer pointer
    li a2, 2205     # Buffer size
    li a7, 63       # Read system call number
    ecall

    mv t1, a1       # Move file descriptor to t1
    la t2, buffer   # Load buffer address to t2
    li t3, 0        # Bytes read counter
    la t5, direccion

#---------------------------------- NUMBERS (CONVERSION AND PARSING) -------------------
read_loop:
    # Check if end of file reached
    li t6, 0
    beq t0, t6, exit

    # Load byte into t4
    lbu t4, 0(t2)

    # Check if the next byte is a negative sign
    li t6, '-'
    beq t4, t6, negative
    
    # Check for newline
    li t6, '\n'
    beq t4, t6, store_data

    # Convert ASCII to integer
    li t7, 10
    mul t8, t8, t7
    add t8, t8, t4

    # Increment bytes read counter
    addi t3, t3, 1

    # Move to next byte in buffer
    addi t2, t2, 1
    j read_loop

#------------------------------------- NEGATIVE NUMBERS ---------------------------------
negative:
    # Move to next byte
    addi t2, t2, 1

    # Load byte into t4
    lbu t4, 0(t2)

    # Check for newline
    li t6, '\n'
    beq t4, t6, store_data_neg

    # Convert ASCII to integer
    li t7, 10
    mul t8, t8, t7
    add t8, t8, t4

    # Make negative
    neg t8, t8

    # Increment bytes read counter
    addi t3, t3, 1

    # Move to next byte in buffer
    addi t2, t2, 1
    j negative

#---------------------------------- STORE ORIGINAL DATA IN MEMORY ---------------------
store_data:
    sb t8, 0(t5)
    li t8, 0
    j read_loop

store_data_neg:
    sb t8, 0(t5)
    li t8, 0
    j read_loop

#------------------------------------ PROGRAM EXIT -------------------------------------
exit:
    # Close the file
    mv a0, t1
    li a7, 57       # Close system call number
    ecall

    li a7, 93       # Exit system call number
    ecall

#---------------------------------- ERROR HANDLING -------------------------------------
error:
    # Error handling when opening the file
    li a0, 1         # File descriptor for stderr
    la a1, error_msg
    la a2, error_msg_len
    li a7, 64        # Write to console system call number
    ecall
    j exit

.section .rodata

error_msg:      .asciz "Error al abrir el archivo.\n"
error_msg_len = . - error_msg