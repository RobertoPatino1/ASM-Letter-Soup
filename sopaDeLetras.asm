name "Sopa de letras"
.model small
.data
seleccionCategoria db ?
msgInicio db '-----Bienvenido al juego: Sopa de letras----- $'
msgSeleccion1 db 'Selecciona el numero de una categoria para generar la sopa de letras: $'
msgSeleccion2 db '1. Equipos clasificados al mundial de futbol 2022 $'
msgSeleccion3 db '2. Disciplinas deportivas $'
msgSeleccion4 db 'Ingresa una opcion: $'

msgErrorCategoria db 'Ha ingresado una opcion no valida, por favor intente ingresar una opcion nuevamente. '

salto DB 13,10,"$" ;INSTRUCCION DE SALTO DE LINEA
msgContinuar db 'Deseas continuar jugando? (1=Si/0=No) $'
msgRespuesta db 'Ingresa tu respuesta: $'
respuesta   db  26        ;MAX NUMBER OF CHARACTERS ALLOWED (25).
            db  ?         ;NUMBER OF CHARACTERS ENTERED BY USER.
            db  26 dup(0) ;CHARACTERS ENTERED BY USER.

randomNumber db ?
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
    jmp ingresoCategoria


ingresoCategoria:   ;Rutina que permite al usuario seleccionar una categoria para generar la sopa de letras
    ;Mensaje de seleccion 4
    lea dx,msgSeleccion4
    int 21h
    ;Capturando datos ingresados por el usuario
    mov ah, 01h         ;funcion para captura de dato
    int 21h             ;interrupcion para captura de dato (ASCCI), se almacena en al
    sub al, 30h         ;convertir codigo ASCII capturado al valor ingresado por el usuario
    mov seleccionCategoria, al
    ;Salto de linea
    mov ah,09h        
    lea dx, salto        
    int 21h    
    jmp validarIngresoCategoria
    
    

validarIngresoCategoria:    ;Rutina que valida que el numero ingresado para la categoria sea valido
    cmp seleccionCategoria,1
    jz generarNumeroAleatorioFutbol  ;Se selecciono Equipos de Futbol
    
    cmp seleccionCategoria,2
    jz generarNumeroAleatorioDeportes ;Se selecciono Deportes
    
    jnz ingresoCategoriaErroneo ;Se ingreso una opcion no valida
    
      
ingresoCategoriaErroneo:    ;Rutina para manejar un ingreso de categoria invalido
    ;Mensaje de inicio
    mov ah,09h
    lea dx,msgErrorCategoria
    int 21h
    ;Salto de linea        
    lea dx, salto        
    int 21h
    int 21h
    jmp ingresoCategoria    ;Volvemos a pedir ingreso
    


 
 
 
;En estas rutinas, el 0 representa la primera opcion, el 1 la segunda    
generarNumeroAleatorioFutbol: 
   MOV AH, 00h  ; interrupts to get system time        
   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
   mov  ax, dx
   xor  dx, dx
   mov  cx, 2    
   div  cx       ; dx contiene el numero aleatorio entre 0 y 1
   cmp dx,0
   mov randomNumber,dl
   jz generarSopaMundial1
   jnz generarSopaMundial2  
   
generarNumeroAleatorioDeportes: 
   MOV AH, 00h  ; interrupts to get system time        
   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
   mov  ax, dx
   xor  dx, dx
   mov  cx, 2    
   div  cx       ; dx contiene el numero aleatorio entre 0 y 1
   cmp dx,0
   jz generarSopaDeportes1
   jnz generarSopaDeportes2 




 
generarSopaMundial1:
    ;Se genera la primera matriz con los equipos del mundial
    
    jmp iniciarCategoriaMundial


generarSopaMundial2: 
    ;Se genera la segunda matriz con los equipos del mundial
    
    jmp iniciarCategoriaMundial


generarSopaDeportes1:
    ;Se genera la primera matriz con los deportes
    
    jmp iniciarCategoriaDeportes

generarSopaDeportes2:
    ;Se genera la segunda matriz con los deportes
    
    jmp iniciarCategoriaDeportes
 
              
              
              
;TODO: Agregar validaciones extras para ver si el usuario ingresa una palabra correcta            
iniciarCategoriaMundial:
         jmp ingresoRespuesta




iniciarCategoriaDeportes:



;TODO: Permitir que se ingrese una cadena de caracteres, no un solo caracter
ingresoRespuesta:
    mov ah,09h
    lea dx,msgRespuesta
    int 21h
    ;CAPTURE STRING FROM KEYBOARD.                                    
    mov ah, 0Ah ;SERVICE TO CAPTURE STRING FROM KEYBOARD.
    mov dx, offset respuesta
    int 21h
    ;Salto de linea
    mov ah,09h        
    lea dx, salto        
    int 21h

;MOSTRANDO LA RESPUESTA POR PANTALLA
    
;CHANGE CHR(13) BY '$'.
    mov si, offset respuesta + 1 ;NUMBER OF CHARACTERS ENTERED.
    mov cl, [ si ] ;MOVE LENGTH TO CL.
    mov ch, 0      ;CLEAR CH TO USE CX. 
    inc cx ;TO REACH CHR(13).
    add si, cx ;NOW SI POINTS TO CHR(13).
    mov al, '$'
    mov [ si ], al ;REPLACE CHR(13) BY '$'.            

;DISPLAY STRING.                   
    mov ah, 09h ;SERVICE TO DISPLAY STRING.
    mov dx, offset respuesta + 2 ;MUST END WITH '$'.
    int 21h

    mov ah, 4ch
    int 21h      

       

    