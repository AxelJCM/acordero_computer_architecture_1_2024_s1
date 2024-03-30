.section .data

file_path:          .asciz "prueba.txt"
output_path:        .asciz "output.txt"
input_buffer:       .space 100        @ Buffer para leer datos del archivo de entrada
output_buffer:      .space 100        @ Buffer para escribir datos en el archivo de salida

.balign 1

.section .text

.globl _start

@------------------------------------- LECTURA DEL ARCHIVO .TXT -----------------------------------
_start:
    @ Abrir el archivo de entrada
    mov r7, #5                @ Código de llamada al sistema para abrir el archivo
    ldr r0, =file_path        @ Archivo que se va a abrir
    mov r1, #2                @ O_RDONLY (Modo de lectura)
    swi 0

    @ Verificar errores al abrir el archivo de entrada (r0 contiene el descriptor del archivo o el código de error)
    cmp r0, #-1
    beq error

    mov r9, r0                @ Almacenar el descriptor del archivo en r9
    ldr r8, =input_buffer     @ Puntero al búfer
    mov r6, #0                @ Contador de bytes leídos

    @ Abrir el archivo de salida
    mov r7, #8                @ Código de llamada al sistema para crear el archivo de salida
    ldr r0, =output_path      @ Archivo que se va a abrir
    mov r1, #0777             @ Permisos de archivo (rw-r--r--)
    swi 0

    @ Verificar errores al abrir el archivo de salida
    cmp r0, #-1
    beq error_output

    mov r10, r0               @ Almacenar el descriptor del archivo de salida en r11
    ldr r4, =output_buffer    @ Puntero al búfer de salida
    mov r6, #0                @ Contador de bytes leídos

read_loop:
    @ Leer una línea del archivo de entrada
    mov r7, #3                @ Código de llamada al sistema para leer desde el archivo
    mov r0, r9                @ Descriptor de archivo
    ldr r1, =input_buffer     @ Puntero al buffer
    mov r2, #5                @ Tamaño máximo de línea (incluyendo el caracter de nueva línea)
    swi 0

    @ Comprobar si se alcanzó el final del archivo
    cmp r0, #0
    beq exit

    @ Procesar la línea leída
    mov r3, r2                @ Tamaño de la línea leída
    bl process_line

    b read_loop

@------------------- PROCESAR UNA LÍNEA -------------------------------------------------
process_line:
    @Procesar el dato que se va escribir
    
    @ Escribir los datos procesados en el archivo de salida
    mov r7, #4                @ Código de llamada al sistema para escribir en el archivo
    mov r0, r10               @ Descriptor de archivo de salida
    mov r1, r8                @ Store the value in the buffer
    mov r2, r3                @ Tamaño de los datos a escribir (asumiendo que se escriben enteros)
    swi 0

    bx lr                     @ Retornar

@------------------- SALIDA DEL PROGRAMA ----------------------------------------------
exit:
    @ Cerrar el archivo de entrada
    mov r0, r9
    mov r7, #6                @ Código de llamada al sistema para cerrar el archivo
    swi 0

    @ Cerrar el archivo de salida
    mov r0, r10
    mov r7, #6                @ Código de llamada al sistema para cerrar el archivo
    swi 0

    mov r7, #1                @ Código de llamada al sistema para salir del programa
    swi 0

@--------------------  MANEJO DE ERRORES -----------------------------------------------
error:
    @ Manejo de errores al abrir el archivo de entrada
    mov r0, #1                @ Descriptor de archivo para stderr
    ldr r1, =error_msg
    ldr r2, =error_msg_len
    mov r7, #4                @ Código de llamada al sistema para escribir en la consola
    svc 0
    b exit

error_output:
    @ Manejo de errores al abrir el archivo de salida
    mov r0, #1                @ Descriptor de archivo para stderr
    ldr r1, =error_output_msg
    ldr r2, =error_output_msg_len
    mov r7, #4                @ Código de llamada al sistema para escribir en la consola
    svc 0
    b exit
@----------------------------------------------------------------------------------------

error_msg:              .asciz "Error al abrir el archivo de entrada.\n"
error_msg_len =         . - error_msg

error_output_msg:       .asciz "Error al abrir el archivo de salida.\n"
error_output_msg_len =  . - error_output_msg
