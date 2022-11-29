name "Sopa de letras"
.model small
.data
seleccionCategoria db ?
msgInicio db '-----Bienvenido al juego: Sopa de letras----- $'
msgSeleccion1 db 'Selecciona el numero de una categoria para generar la sopa de letras: $'
msgSeleccion2 db '1. Equipos clasificados al mundial de futbol 2022 $'
msgSeleccion3 db '2. Disciplinas deportivas $'
msgSeleccion4 db 'Ingresa una opcion: $'
salto DB 13,10,"$" ;INSTRUCCION DE SALTO DE LINEA
msgContinuar db 'Deseas continuar jugando? (1=Si/0=No) $'


;TODO:
;Agregar variables para otros mensajes y captura de datos ingresados por el usuario


.code
.start
mov cx,0000h



iniciarJuego:
    ;Mensaje de inicio
    mov ah,09h
    lea dx,msgInicio
    int 21h
    ;Salto de linea        
    lea dx, salto        
    int 21h
    int 21h
    ;Mensaje de seleccion 1
    lea dx,msgSeleccion1
    int 21h
    ;Salto de linea        
    lea dx, salto        
    int 21h
    int 21h            
    ;Mensaje de seleccion 2
    lea dx,msgSeleccion2
    int 21h
    ;Salto de linea        
    lea dx, salto        
    int 21h            
    ;Mensaje de seleccion 3
    lea dx,msgSeleccion3
    int 21h 
    ;Salto de linea        
    lea dx, salto        
    int 21h 
    int 21h
    ;Mensaje de seleccion 4
    lea dx,msgSeleccion4
    int 21h                
    
    
    ;Capturando datos ingresados por el usuario
    mov ah, 01h         ;funcion para captura de dato
    int 21h             ;interrupcion para captura de dato (ASCCI), se almacena en al
    sub al, 30h         ;convertir codigo ASCII capturado al valor ingresado por el usuario
    mov seleccionCategoria, al     
    
