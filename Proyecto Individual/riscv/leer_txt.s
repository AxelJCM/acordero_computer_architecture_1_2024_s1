.global _start
.text
_start:

    # Abrir el archivo en modo lectura
    la a0, filename     # Dirección del nombre de archivo
    li a1, 0
    li a2, 0            # Modo: lectura
    li a7, 1024         # Número de llamada al sistema para openat (específico de RISC-V)
    ecall

    # Verificar si el archivo se abrió correctamente
    bltz a0, _exit       # Si a0 < 0, el archivo no se abrió correctamente

    # Guardar el descriptor de archivo
    mv t0, a0
    
_read:   
    # Leer datos del archivo
    mv a0, t0
    addi sp, sp, -56    # Descriptor de archivo para el archivo de entrada
    mv a1, sp           # Dirección del búfer de lectura
    li a2, 17           # Tamaño máximo de lectura, ajustar el tamaño según sea necesario
    li a7, 63           # Número de llamada al sistema para read (específico de RISC-V)
    ecall
    
    bltz a0, _close       # Si a0 < 0, el archivo no se abrió correctamente
    
    # Trabajo con los datos leídos
    lw t4, 0(sp)
    
    # Establecer el desplazamiento del archivo al principio del archivo
    mv a0, t0           # Descriptor de archivo para el archivo de entrada
    li a1, 0            # Valor de desplazamiento (0 bytes desde el principio)
    li a2, 10            # Valor de whence (SEEK_SET)
    li a7, 62           # Número de llamada al sistema para lseek (específico de RISC-V)
    ecall
    
    
    # Volver a leer desde el archivo
    j _read
    
_close:
    # Cerrar el archivo
    mv a0, t0           # Descriptor de archivo para el archivo de entrada
    li a7, 57           # Número de llamada al sistema para close (específico de RISC-V)
    ecall

_exit:
    # Terminar el programa
    li a0, 0            # Código de salida
    li a7, 93           # Número de llamada al sistema para salir (específico de RISC-V)
    ecall

.data
filename: .string "audio.txt"   # Nombre del archivo de audio de entrada

