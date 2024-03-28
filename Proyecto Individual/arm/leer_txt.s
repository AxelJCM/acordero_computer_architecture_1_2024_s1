.arch armv7-a
.fpu vfpv3
.eabi_attribute 67, "2.09"    @ Version EABI
.eabi_attribute 6, 10         @ ABI de punto flotante duro

.section .data

file_path:      .asciz "prueba.txt"
buffer:         .space 2205      @ Tamaño del buffer para contener el contenido del archivo
ejemploFloat:   .float 4.566
constante:      .float 75.0
buffer_addr:    .word 0
direccion:      .word 0x100

.align 1

.section .text

.globl _start

@------------------------------------- LECTURA DEL ARCHVO .TXT -----------------------------------
_start:
    @ Abrir el archivo
    ldr r0, =file_path
    mov r1, #2      @ O_RDONLY (Modo de lectura)
    mov r2, #0
    mov r7, #5      @ Codigo de llamada al sistema para abrir el archivo
    swi 0

    @ Verificar errores al abrir el archivo (r0 contiene el descriptor del archivo o el código de error)
    cmp r0, #-1
    beq error

    mov r9, r0 @ Almacenar el descriptor del archivo en r9
    ldr r8, =buffer  @ Puntero al búfer
    mov r10, #0 @ Contador de bytes leídos
    ldr r6, =direccion @inicializar direccion
@----------------------------------------------------------------------------------------------------

@////////////////////// NUMEROS POSITIVOS (CONVERSION Y PARSEO) //////////////////////////
@ Bucle para leer valores del archivo y convertirlos a enteros
read_loop:
    @ Leer 17 bytes del archivo
    mov r0, r9
    ldr r1, =buffer
    mov r2, #17       @ Leer 17 bytes a la vez
    mov r7, #3       @ Código de llamada al sistema para leer desde el archivo
    swi 0

    @ Comprobar si se alcanzó el final del archivo
    cmp r0, #0
    beq exit

    @ Procesar los bytes leídos
    mov r3, r2         @ Número de bytes leídos
process_bytes:
    @ Convertir cada byte leído a un entero
    ldrb r4, [r8], #1  @ Cargar el byte en r4 y avanzar el puntero al siguiente byte
    cmp r4, #'-'      @ Comprobar si el byte es un signo negativo
    beq negative
    
    sub r4, r4, #'0'  @ Convertir ASCII a entero (suponiendo que el byte representa un dígito)

    @ Comparación de SALTO DE LÍNEA
    cmp r4, #-38
    beq store_data

    @ Operación para números de 2 a 3 dígitos
    ldr r11, =10
    mul r10, r10, r11    @ Multiplicar r10 por 10 
    add r10, r10, r4    @ Almacenar temporalmente el dato en r4

    subs r3, r3, #1    @ Decrementar el contador de bytes procesados
    bne process_bytes  @ Si no hemos procesado todos los bytes, continuar el bucle

    b read_loop        @ Volver a leer más bytes del archivo

@//////////////////////////////////////////////////////////////////////////////////////////

@////////////////////// NUMEROS NEGATIVOS (CONVERSION Y PARSEO) //////////////////////////
negative:
     @ Leer 17 bytes del archivo
    mov r0, r9
    ldr r1, =buffer
    mov r2, #17       @ Leer 17 bytes a la vez
    mov r7, #3       @ Código de llamada al sistema para leer desde el archivo
    swi 0

    @ Comprobar si se alcanzó el final del archivo
    cmp r0, #0
    beq exit

    @ Procesar los bytes leídos
    mov r3, r2         @ Número de bytes leídos
process_bytes_neg:
    @ Convertir cada byte leído a un entero
    ldrb r4, [r8], #17  @ Cargar el byte en r4 y avanzar el puntero al siguiente byte

    @ Comparación de SALTO DE LÍNEA
    cmp r4, #-38
    beq store_data_neg

    sub r4, r4, #'0'  @ Convertir ASCII a entero (suponiendo que el byte representa un dígito)

    ldr r11, =10
    mul r10, r10, r11      @ Multiplicar r10 por 10 
    add r10, r10, r4    @ Almacenar temporalmente el dato en r4

    subs r3, r3, #17    @ Decrementar el contador de bytes procesados
    bne process_bytes_neg  @ Si no hemos procesado todos los bytes, continuar el bucle

    b negative         @ Volver a leer más bytes del archivo
@////////////////////////////////////////////////////////////////////////////////////////

@------------------- GUARDADO EN MEMORIA DATOS ORIGINALES --------------------
store_data:
    STRB R10, [R6], #17
    mov r10, #0 @DEBUG i r
    b read_loop

store_data_neg:    
    neg r10,r10 
    STRB R10, [R6], #17 
    mov r10, #0 @DEBUG i r
    b read_loop
@-----------------------------------------------------------------------------


@------------------- SALIDA DEL PROGRAMA -------------------------------------
exit:
    @ Cerrar el archivo
    mov r0, r9
    mov r7, #6        @ Código de llamada al sistema para cerrar el archivo
    swi 0

    mov r7, #1        @ Código de llamada al sistema para salir del programa
    swi 0
@------------------------------------------------------------------------------

@--------------------  MANEJO DE ERRORES -------------------------------------
error:
    @ Manejo de errores al abrir el archivo
    mov r0, #1        @ Descriptor de archivo para stderr
    ldr r1, =error_msg
    ldr r2, =error_msg_len
    mov r7, #4        @ Código de llamada al sistema para escribir en la consola
    svc 0
    b exit
@------------------------------------------------------------------------------

error_msg:      .asciz "Error al abrir el archivo.\n"
error_msg_len = . - error_msg
