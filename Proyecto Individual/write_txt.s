.data
filename: .string "output.txt"   # Nombre del archivo de salida
message: .string "Hello, World!" # Mensaje a escribir en el archivo

.text
_start:
    # Abrir el archivo en modo escritura
    li a0, 0x2       # System call para abrir el archivo
    la a1, filename  # Dirección del nombre del archivo
    li a2, 0x1       # Modo de apertura: escritura
    li a3, 0x0       # Permisos del archivo
    li a7, 0x2f      # Código de la llamada al sistema para abrir
    ecall

    # Comprobar si hubo un error al abrir el archivo
    bltz a0, error

    # Escribir el mensaje en el archivo
    li a0, 0x1       # Descriptor de archivo: stdout
    la a1, message    # Dirección del mensaje
    li a2, 0xd       # Longitud del mensaje
    li a7, 0x40      # Código de la llamada al sistema para escribir
    ecall

    # Cerrar el archivo
    li a0, 0x3       # Descriptor de archivo: stdout
    li a7, 0x18      # Código de la llamada al sistema para cerrar
    ecall

    # Salir del programa
    li a7, 0x10      # Código de la llamada al sistema para salir
    ecall

error:
    # Manejar el error al abrir el archivo
    # Aquí puedes agregar tu propio código de manejo de errores
    # Por ejemplo, imprimir un mensaje de error y salir del programa
    li a7, 0x10      # Código de la llamada al sistema para salir
    ecall
