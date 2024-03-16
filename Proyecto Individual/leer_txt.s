.data
filename: .string "audio.txt"   # Name of the input audio file
buffer: .space 1024   # Buffer to store data read from the file, adjust size as needed

.text
main:
    # Open the file in read mode
    la a0, filename     # Address of the filename
    li a1, 0            # Mode: read
    li a7, 1024         # System call number for openat (RISC-V specific)
    ecall

    # Check if the file was opened successfully
    bltz a0, exit       # If a0 < 0, the file failed to open

    # Save the file descriptor
    mv t0, a0

    # Set file offset to the beginning of the file
    mv a0, t0           # File descriptor for input file
    li a1, 0            # Offset value (0 bytes from the beginning)
    li a2, 0            # Whence value (SEEK_SET)
    li a7, 62           # System call number for lseek (RISC-V specific)
    ecall

read_loop:
    # Read data from the file
    mv a0, t0           # File descriptor for input file
    la a1, buffer       # Address of the read buffer
    li a2, 512          # Maximum read size, adjust size as needed
    li a7, 63           # System call number for read (RISC-V specific)
    ecall

    # Check if data was read successfully
    bltz a0, close_file_and_exit  # If a0 < 0, there was an error reading the file

    # If EOF reached, exit the read loop
    beqz a0, close_file_and_exit

    # Move file offset to the current position
    mv a0, t0           # Move the content of register t0 into register a0
    li a1, 0            # Offset value (0 bytes from the current position)
    li a2, 1            # Whence value (SEEK_CUR)
    li a7, 62           # System call number for lseek (RISC-V specific)
    ecall

    # Otherwise, continue reading
    j read_loop

close_file_and_exit:
    # Close the file
    mv a0, t0           # File descriptor for input file
    li a7, 57           # System call number for close (RISC-V specific)
    ecall

exit:
    # Terminate the program
    li a0, 0            # Exit code
    li a7, 93           # System call number for exit (RISC-V specific)
    ecall