name "Sopa de letras"
include "emu8086.inc" 
org 100h
.model small
.data
seleccionCategoria db ?
linea db ?
msgInicio db '-----Bienvenido al juego: Sopa de letras----- $'
msgSeleccion1 db 'Selecciona el numero de una categoria para generar la sopa de letras: $'
msgSeleccion2 db '1. Equipos clasificados al mundial de futbol 2022 $'
msgSeleccion3 db '2. Disciplinas deportivas $'
msgSeleccion4 db 'Ingresa una opcion: $'

msgErrorCategoria db 'Ha ingresado una opcion no valida, por favor intente ingresar una opcion nuevamente. '

salto DB 13,10,"$" ;INSTRUCCION DE SALTO DE LINEA
msgRespuesta db "Ingresa una palabra encontrada o 0 para salir: $"
msgPierde db "Fin del juego, mejor suerte para la proxima :($"
msgGana db "Felicidades! Has encontrado todas las palabras!$"
contador db ?                                                
;VARIABLES QUE ALMACENARAN LAS PALABRAS QUE VAYA ENCONTRANDO EL USUARIO
palabra1 db ?
palabra2 db ?
palabra3 db ?
palabra4 db ?
palabra5 db ? 



respuesta db 16,0,78 DUP('$')

randomNumber db ?
;TODO:
;Agregar variables para otros mensajes y captura de datos ingresados por el usuario

;------------------------------------------------------------
;------DECLARACION DE MATRICES PARA LAS SOPAS DE LETRAS------
;------------------------------------------------------------

;MATRIZ DE EQUIPOS 1
equipos1      db  "I N G L A T E R R A C",13,10
              db  "E G D E C U A D O R U",13,10
              db  "K G L W X R A D L G G",13,10
              db  "M Y M H A V Q Z Q Y Z",13,10
              db  "S Q C H M Z J R Z T T",13,10
              db  "Y N T W U N Q A T A R",13,10
              db  "S E N E G A L X O C O",13,10
              db  "N B H O L A N D A R X",13,10
              db  "P K M S K F S E P Y W",13,10
              db  "C C O E T V W X P O Y",13,10
              db  "U W Z G C D X J Z F I$",13,10
              
equipos2      db  "K J R A Q Z V Q U O W",13,10
              db  "J U K Z I O A T L A O",13,10
              db  "N T J X P R L U P R O",13,10
              db  "B K R C O G A L J G R",13,10
              db  "W X N S R R B N V E F",13,10
              db  "O C L X T E E P A N D",13,10
              db  "Z A N N U V L N Z T K",13,10
              db  "K N Y R G J G Y A I H",13,10
              db  "W A X K A Q I F T N N",13,10
              db  "I D K E L J C I S A F",13,10
              db  "L A C R S E A A U S J$",13,10 
              

;MATRIZ DE DEPORTES 1    
deportes1      db  "A B F Y G C S D H T I",13,10
               db  "X A V U U H S Q U C L",13,10
               db  "N S U Y T Z I T B E S",13,10
               db  "A Q D U E B F Q J D K",13,10
               db  "T U R K C U O Y M G E",13,10
               db  "A E W B T X U L M H S",13,10
               db  "C T Z I X E E F Y R I",13,10
               db  "I B M H I N N N E R M",13,10
               db  "O O P V O L E I B O L",13,10
               db  "N L T T X S C Y S U W",13,10
               db  "E Q O Y S D G V Q D M$",13,10

;MATRIZ DE DEPORTES 2          
deportes2      db  "I L X O D Z J A K Z Y",13,10
               db  "J K A Q G E Z X A P O",13,10
               db  "X W Z C Z O G T R X N",13,10
               db  "W D I T I G N C A O Y",13,10
               db  "X I W K G C A R T K R",13,10
               db  "C W P H X K L C E H W",13,10
               db  "D R U G B Y H I C J U",13,10
               db  "G D K L T Z O G S A E",13,10
               db  "M M K V S I V Z A M Q",13,10
               db  "G S A T L E T I S M O",13,10
               db  "A J E D R E Z L X Y Z$",13,10              
              

;VARIABLES DE COLORES PARA IR PINTANDO LA SOPA DE LETRAS
verde db  010100000b
rojo db  011000000b
amarillo db  011100000b
cian db  010110000b
rosado db  011010000b              

;VARIABLES PARA VALIDAR PALABRAS              
palabraI db  20 dup("$")
palabraMayuscula db  20 dup("$")    ;Para guardar palabras convertidas a mayusculas
vacio db  100 dup(" "),"$"  

;VARIABLES CON LAS PALABRAS QUE DEBE HALLAR EL USUARIO
;posicionEquipos1 db ...... TODO
listaEquipos1 db "INGLATERRA","ECUADOR","QATAR","SENEGAL","HOLANDA",0
;posicionEquipos2 db .....TODO
listaEquipos2 db "CANADA","PORTUGAL","IRAN","BELGICA","ARGENTINA",0

;TODO:
;-----------AGREGAR LAS OTRAS LISTAS DE PALABRAS CON DISCIPLINAS DEPORTIVAS----------------            
;posicionDeportes1 db ...... TODO
listaDeportes1 db "FUTBOL","NATACION","BASQUETBOL","TENIS","VOLEIBOL",0
;posicionDeportes2 db .....TODO
listaDeportes2 db "KARATE","CICLISMO","RUGBY","ATLETISMO","AJEDREZ",0
              
.code
;RUTINA PARA POSICIONAR EL CURSOR Y HACER SALTO DE LINEA
mostrar macro var         
    mov ax, 0h
    GOTOXY 0, linea 
    inc linea   
    mov ah, 09h
    lea dx, var
    int 21h   
endm 

;RUTINA PARA PEDIR EL INGRESO DE LA PALABRA POR TECLADO
pedirPalabra macro listaPosiciones,listaPalabras      
    LOCAL pedirPalabra1,pedirPalabra2,esMayuscula,esMinuscula,comprobarPalabra,iguales1,iguales2,iguales3,iguales4,iguales5,noIguales,limpiar,limpiarn
    

pedirPalabra1: 
    mostrar palabra
    mov ah, 1
    xor si, si
    jmp pedirPalabra2

;Rutina para verificar si el caracter es mayuscula, minuscula, enter o 0
pedirPalabra2:
    int 21h                                      
    cmp al, 48
    jz rindo
    cmp al, 13
    jz comprobarPalabra
    mov palabraI[si], al
    cmp al, 91
    jnb esMinuscula
    jb esMayuscula

;RUTINA PARA GUARDAR LAS PALABRAS ESCRITAS EN MAYUSCULA     
esMayuscula: 
    mov palabraMayuscula[si], al                          
    inc si
    jmp pedirPalabra2

;RUTINA PARA GUARDAR LAS PALABRAS ESCRITAS EN MINUSCULAS CONVERTIDAS A MAYUSCULAS    
esMinuscula:
    sub al, 32
    mov palabraMayuscula[si], al                          
    inc si
    jmp pedirPalabra2 

;RUTINA PARA COMPROBAR SI LA PALABRA INGRESADA ES IGUAL A ALGUNA DE LAS 5 PALABRAS EN LA SOPA DE LETRAS
comprobarPalabra:                                
    xor si, si
    mov bh, 0
    mov bl, listaPosiciones[0]
    lea si, listaPalabras[bx]
    lea di, palabraMayuscula 
    mov ah, 0
    mov al, listaPosiciones[1]
    sub al, bl
    mov cx, ax
    repe cmpsb 
    je iguales1
    xor si, si
    mov bh, 0
    mov bl, listaPosiciones[1]
    lea si, listaPalabras[bx]
    lea di, palabraMayuscula 
    mov ah, 0
    mov al, listaPosiciones[2]
    sub al, bl
    mov cx, ax
    repe cmpsb 
    je iguales2 
    xor si, si
    mov bh, 0
    mov bl, listaPosiciones[2]
    lea si, listaPalabras[bx]
    lea di, palabraMayuscula 
    mov ah, 0
    mov al, listaPosiciones[3]
    sub al, bl
    mov cx, ax
    repe cmpsb 
    je iguales3
    xor si, si
    mov bh, 0
    mov bl, listaPosiciones[3]
    lea si, listaPalabras[bx]
    lea di, palabraMayuscula 
    mov ah, 0
    mov al, listaPosiciones[4]
    sub al, bl
    mov cx, ax
    repe cmpsb 
    je iguales4
    xor si, si
    mov bh, 0
    mov bl, listaPosiciones[4]
    lea si, listaPalabras[bx]
    lea di, palabraMayuscula 
    mov ah, 0
    mov al, listaPosiciones[5]
    sub al, bl
    mov cx, ax
    repe cmpsb 
    je iguales5
    jne limpiarn

;RUTINA PARA COMPROBAR SI LA PALABRA INGRESADA CORRESPONDE A LA PRIMERA PALABRA DE LA LISTA 
iguales1:
    cmp palabra1, 1
    jz limpiar
    inc palabra1
    inc contador
    jnz limpiar
;RUTINA PARA COMPROBAR SI LA PALABRA INGRESADA CORRESPONDE A LA SEGUNDA PALABRA DE LA LISTA    
iguales2:
    cmp palabra2, 1
    jz limpiar
    inc palabra2
    inc contador
    jnz limpiar
;RUTINA PARA COMPROBAR SI LA PALABRA INGRESADA CORRESPONDE A LA TERCERA PALABRA DE LA LISTA    
iguales3:          
    cmp palabra3, 1
    jz limpiar
    inc palabra3
    inc contador
    jmp limpiar
;RUTINA PARA COMPROBAR SI LA PALABRA INGRESADA CORRESPONDE A LA CUARTA PALABRA DE LA LISTA    
iguales4:
    cmp palabra4, 1
    jz limpiar
    inc palabra4
    inc contador
    jmp limpiar
;RUTINA PARA COMPROBAR SI LA PALABRA INGRESADA CORRESPONDE A LA QUINTA PALABRA DE LA LISTA    
iguales5:
    cmp palabra5, 1
    jz limpiar
    inc palabra5
    inc contador
    jmp limpiar
    
limpiarn:  
    mov di, offset palabraMayuscula
    mov cx, 19
    repe movsb
    mov di, offset palabraI
    mov cx, 19
    repe movsb 
    dec linea
    mostrar vacio
    dec linea
    jmp pedirPalabra1    
    
limpiar: 
    mov di, offset palabraMayuscula
    mov cx, 19
    repe movsb
    mov di, offset palabraI
    mov cx, 19
    repe movsb 
    dec linea
    mostrar vacio   
endm 


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




       





       



