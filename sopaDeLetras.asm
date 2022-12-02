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
respuesta db 16,0,78 DUP('$')

randomNumber db ?
;TODO:
;Agregar variables para otros mensajes y captura de datos ingresados por el usuario


.code
.start
mov cx,0000h


;EL OBJETIVO DE ESTA ETIQUETA ES PRESENTAR LOS MENSAJES INICIALES AL USUARIO
;Y DARLE LA BIENVENIDA AL JUEGO, ESTA SOLO CARGA E IMPRIME LOS MENSAJES RESPECTIVOS
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
    call limpiarPantalla
    mov ah,09h
    lea dx,msgErrorCategoria
    int 21h
    ;Salto de linea        
    lea dx, salto        
    int 21h
    int 21h
    jmp iniciarJuego    ;Volvemos a pedir ingreso
    


 
 
 
;En estas rutinas, el 0 representa la primera opcion, el 1 la segunda    
generarNumeroAleatorioFutbol:
   call generarNumeroAleatorio
   jz generarSopaMundial1
   jnz generarSopaMundial2  
   
generarNumeroAleatorioDeportes: 
   call generarNumeroAleatorio
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
    ;LIMPIEZA DE LA CONSOLA
    call limpiarPantalla
    ;----------------------  


   
    jmp ingresoRespuesta




iniciarCategoriaDeportes: 
    ;LIMPIEZA DE LA CONSOLA
    call limpiarPantalla
    ;----------------------
    jmp ingresoRespuesta    ;Crear otra rutina para el ingreso de deportes???


;TODO: Permitir que se ingrese una cadena de caracteres, no un solo caracter
ingresoRespuesta:
    ;INPUT
    mov ah,09h
    lea dx,msgRespuesta
    int 21h    
    mov ah,0ah
    lea dx,respuesta
    
    int 21h 
    
    ;Prompt
    
    mov ah,09h
    lea dx,salto
    int 21h
    mov dx,offset respuesta+2
    int 21h
    
;SALIR DEL PROGRAMA
salir:
    mov ah,00h
    int 21h    
 
 
 
 
 
 
;PROCEDIMIENTO PARA LIMPIAR LA PANTALLA DE LA CONSOLA   
;OJO: NO PERMITIR QUE EL PROGRAMA LLEGUE A ESTOS PROCESOS FUERA DE LAS LLAMADAS A ELLOS
ret
limpiarPantalla PROC
    mov ax, 3
    int 10h
 ret
limpiarPantalla ENDP



;PROCEDIMIENTO PARA GENERAR UN NUMERO ALEATORIO ENTRE 0 Y 1
;EL PROPOSITO DE ESTE ES SELECCIONAR UNA DE LAS 2 SOPAS DE LETRAS AL AZAR
;0 -> PRIMERA OPCION
;1 -> SEGUNDA OPCION
;OBTIENE EL NUMERO ALEATORIO EN FUNCION DE LOS CLOCK TICKS DEL SISTEMA
ret
generarNumeroAleatorio PROC
   MOV AH, 00h  ; interrupts to get system time        
   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
   mov  ax, dx
   xor  dx, dx
   mov  cx, 2    
   div  cx       ; dx contiene el numero aleatorio entre 0 y 1
   cmp dx,0
   mov randomNumber,dl
 ret
generarNumeroAleatorio ENDP







       



k ticks since midnight      
   mov  ax, dx
   xor  dx, dx
   mov  cx, 2    
   div  cx       ; dx contiene el numero aleatorio entre 0 y 1
   cmp dx,0
   mov randomNumber,dl
 ret
generarNumeroAleatorio ENDP          


       



