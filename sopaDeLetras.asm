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
msgRespuesta db "Ingresa una palabra encontrada o 0 para rendirte: $"
msgPierde db "Fin del juego, mejor suerte para la proxima!$"  ;Mensaje en caso de que el usuario se rinda
msgGana db "Felicidades! Has encontrado todas las palabras!$"   ;Mensaje en caso de que el usuario adivine todas las palabras
contador db ?                                                
;VARIABLES QUE ALMACENARAN LAS PALABRAS QUE VAYA ENCONTRANDO EL USUARIO
palabra1 db ?
palabra2 db ?
palabra3 db ?
palabra4 db ?
palabra5 db ? 

checkpoint db ? ;Variable que se usara para saber en que sopa de letras se encuentra el usuario


respuesta db 16,0,78 DUP('$')

randomNumber db ?   ;Variable que guardara el numero aleatorio para escoger una sopa de letras


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

;MATRIZ DE EQUIPOS 2             
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
               db  "O O P A S T E I N O L",13,10
               db  "N L T T X S C Y S U W",13,10
               db  "E Q O V O L E I B O L$",13,10

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
               db  "G A T L E T I S M O O",13,10
               db  "A J E D R E Z L X Y Z$",13,10              
              

;VARIABLES DE COLORES PARA IR PINTANDO LA SOPA DE LETRAS
verde db  010100000b
rojo db  011000000b
amarillo db  011100000b
cian db  010110000b
rosa db  011010000b             

;VARIABLES PARA VALIDAR PALABRAS Y PERMITIR QUE EL PROGRAMA NO SEA CASE-SENSITIVE              
palabraI db  20 dup("$")
palabraMayuscula db  20 dup("$")    
vacio db  100 dup(" "),"$"                            

;######################################################################
;VARIABLES CON LAS PALABRAS QUE DEBE HALLAR EL USUARIO Y SUS POSICIONES
;######################################################################
;EQUIPOS
posicionEquipos1 db 0,10,17,22,29,36
listaEquipos1 db "INGLATERRA","ECUADOR","QATAR","SENEGAL","HOLANDA",0
posicionEquipos2 db 0,6,14,18,25,34 ;TODO: ACTUALIZAR ESTOS VALORES
listaEquipos2 db "CANADA","PORTUGAL","IRAN","BELGICA","ARGENTINA",0

;DEPORTES           
posicionDeportes1 db 0,6,14,24,29,37
listaDeportes1 db "FUTBOL","NATACION","BASQUETBOL","TENIS","VOLEIBOL",0
posicionDeportes2 db 0,6,14,19,28,35
listaDeportes2 db "KARATE","CICLISMO","RUGBY","ATLETISMO","AJEDREZ",0
              
.code
;RUTINA PARA POSICIONAR EL CURSOR Y HACER SALTO DE LINEA
;Esta mostrara el argumento pasado como parametro por la pantalla
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
    

;Rutina que muestra el mensaje solicitando la respuesta
pedirPalabra1: 
    mostrar msgRespuesta
    mov ah, 1
    xor si, si
    jmp pedirPalabra2

;Rutina que recibe la palabra ingresada por teclado para verificar si los caracteres estan en mayuscula o minuscula
pedirPalabra2:
    int 21h                                      
    cmp al, 48
    jz derrota
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

;RUTINA PARA CONVERTIR LAS PALABRAS A MAYUSCULAS EN CASO DE SER MINUSCULAS Y GUARDARLAS COMO TAL    
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

;RUTINA PARA........................    
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


;RUTINA PARA........................    
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


;Rutina para resaltar la palabra donde se especifica la fila y columna inicial y la fila y columna final junto al color
resaltar macro filaInicial,filaFinal,columnaInicial,columnaFinal,color                
    mov ah, 06h
    mov bh, color
    mov ch, filaInicial         
    mov dh, filaFinal         
    mov cl, columnaInicial         
    mov dl, columnaFinal         
    int 10h
endm
 


.start

;Inicializacion de las variables
mov linea, 0
mov contador, 0
mov palabra1, 0
mov palabra2, 0
mov palabra3, 0
mov palabra4, 0
mov palabra5, 0
jmp iniciarJuego 





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
    mov ah, 01h         
    int 21h             
    sub al, 30h         
    mov seleccionCategoria, al
    ;Salto de linea
    mov ah,09h        
    lea dx, salto        
    int 21h    
    jmp validarIngresoCategoria
    
    
;Rutina para validar que el numero ingresado para la categoria sea un valor permitido (1 o 2)
validarIngresoCategoria:    
    cmp seleccionCategoria,1
    jz generarNumeroAleatorioFutbol  ;Se selecciono Equipos de Futbol
    
    cmp seleccionCategoria,2
    jz generarNumeroAleatorioDeportes ;Se selecciono Deportes
    
    jnz ingresoCategoriaErroneo ;Se ingreso una opcion no valida
    

;Rutina para manejar un ingreso de categoria invalido      
ingresoCategoriaErroneo:    
    ;Mensaje de inicio
    call clear_screen
    mov ah,09h
    lea dx,msgErrorCategoria
    int 21h
    ;Salto de linea        
    lea dx, salto        
    int 21h
    int 21h
    jmp iniciarJuego    ;Volvemos a pedir ingreso
    


 
 
;Rutina que llama a los procedimientos para generar un numero aleatorio entre 0 y 1 
;En estas rutinas, el 0 representa la primera opcion, el 1 la segunda    
generarNumeroAleatorioFutbol:
   call generarNumeroAleatorio
   jz generarSopaMundial1
   jnz generarSopaMundial2  
   
generarNumeroAleatorioDeportes: 
   call generarNumeroAleatorio
   jz generarSopaDeportes1
   jnz generarSopaDeportes2 



;####################################################
;##### RUTINAS RELACIONADAS A LAS MATRICES ##########
;####################################################                   

;RUTINA PARA MOSTRAR POR CONSOLA LA MATRIZ 1 CON LOS EQUIPOS DEL MUNDIAL
generarSopaMundial1:
    mov checkpoint,1    ;Primera sopa de letras
    call clear_screen
    mov linea, 0
    mostrar msgSeleccion2
    inc linea
    mostrar equipos1
    mov linea, 18
    pedirPalabra posicionEquipos1,listaEquipos1
    jmp palabraIngresadaEquipos1    


;Rutina para validar la palabra ingresada y en caso de ser alguna de las 5 resaltarla en la matriz
palabraIngresadaEquipos1:                                 
    cmp palabra1, 1
    jz resaltarInglaterra
    cmp palabra2, 1
    jz resaltarEcuador
    cmp palabra3, 1
    jz resaltarQatar
    cmp palabra4, 1
    jz resaltarSenegal
    cmp palabra5, 1
    jz resaltarHolanda
    jnz pedirSiguienteEquipos1
    
;-------------------------------------------------------
;Rutinas para resaltar de forma individual las palabras
;-------------------------------------------------------  
;Resalta Inglaterra
resaltarInglaterra:
    resaltar 2,2,0,18,rojo
    inc palabra1    ;Incrementa en 1 el valor de la variable palabra1
    jmp pedirSiguienteEquipos1

;Resalta Ecuador    
resaltarEcuador:
    resaltar 3,3,6,18,amarillo                              
    inc palabra2
    jmp pedirSiguienteEquipos1

;Resalta Qatar    
resaltarQatar:                               
    resaltar 7,7,12,20,rosa      
    inc palabra3
    jmp pedirSiguienteEquipos1

;Resalta Senegal    
resaltarSenegal:                           
    resaltar 8,8,0,12,cian     
    inc palabra4
    jmp pedirSiguienteEquipos1

;Resalta Holanda    
resaltarHolanda:                          
    resaltar 9,9,4,16,verde   
    inc palabra5
    jmp pedirSiguienteEquipos1    
 
;Rutina para pedir la palabra siguiente a ingresar  
pedirSiguienteEquipos1:                                   
    mov linea, 0
    mostrar msgSeleccion2
    inc linea
    mostrar equipos1 
    cmp contador, 5 
    jz victoria
    mov linea, 18
    pedirPalabra posicionEquipos1,listaEquipos1
    jmp palabraIngresadaEquipos1
    

;RUTINA PARA MOSTRAR POR CONSOLA LA MATRIZ 2 CON LOS EQUIPOS DEL MUNDIAL
generarSopaMundial2:
    mov checkpoint,2    ;Segunda sopa de letras         
    call clear_screen
    mov linea, 0
    mostrar msgSeleccion2
    inc linea
    mostrar equipos2
    mov linea, 18
    pedirPalabra posicionEquipos2,listaEquipos2
    jmp palabraIngresadaEquipos2 
    
;Rutina para validar la palabra ingresada y en caso de ser alguna de las 5 resaltarla en la matriz
palabraIngresadaEquipos2:                                 
    cmp palabra1, 1
    jz resaltarCanada
    cmp palabra2, 1
    jz resaltarPortugal
    cmp palabra3, 1
    jz resaltarIran
    cmp palabra4, 1
    jz resaltarBelgica
    cmp palabra5, 1
    jz resaltarArgentina
    jnz pedirSiguienteEquipos2       

;-------------------------------------------------------
;Rutinas para resaltar de forma individual las palabras
;-------------------------------------------------------  
;Resalta Canada
resaltarCanada:
    resaltar 7,12,2,2,rojo
    inc palabra1    ;Incrementa en 1 el valor de la variable palabra1
    jmp pedirSiguienteEquipos2

;Resalta Portugal    
resaltarPortugal:
    resaltar 4,11,8,8,amarillo                              
    inc palabra2
    jmp pedirSiguienteEquipos2

;Resalta Iran    
resaltarIran:                               
    resaltar 3,3,8,8,rosa           ;I          
    resaltar 4,4,10,10,rosa         ;R
    resaltar 5,5,12,12,rosa         ;A          ;ESTO SE HACE YA QUE ES UNA PALABRA EN DIAGONAL
    resaltar 6,6,14,14,rosa         ;N
    inc palabra3
    jmp pedirSiguienteEquipos2

;Resalta Belgica    
resaltarBelgica:                           
    resaltar 6,12,12,12,cian     
    inc palabra4
    jmp pedirSiguienteEquipos2

;Resalta Argentina    
resaltarArgentina:                          
    resaltar 3,11,18,18,verde   
    inc palabra5
    jmp pedirSiguienteEquipos2    
 
;Rutina para pedir la palabra siguiente  
pedirSiguienteEquipos2:                                   
    mov linea, 0
    mostrar msgSeleccion2
    inc linea
    mostrar equipos2 
    cmp contador, 5 
    jz victoria
    mov linea, 18
    pedirPalabra posicionEquipos2,listaEquipos2
    jmp palabraIngresadaEquipos2



;RUTINA PARA MOSTRAR POR CONSOLA LA MATRIZ 1 CON LOS DEPORTES

generarSopaDeportes1:
    mov checkpoint,3    ;Primera sopa de letras
    call clear_screen
    mov linea, 0
    mostrar msgSeleccion3
    inc linea
    mostrar deportes1
    mov linea, 18
    pedirPalabra posicionDeportes1,listaDeportes1 
    jmp palabraIngresadaDeportes1    


;Rutina para validar la palabra ingresada y en caso de ser alguna de las 5 resaltarla en la matriz
palabraIngresadaDeportes1:                                 
    cmp palabra1, 1
    jz resaltarFutbol
    cmp palabra2, 1
    jz resaltarNatacion
    cmp palabra3, 1
    jz resaltarBasquetbol
    cmp palabra4, 1
    jz resaltarTenis
    cmp palabra5, 1
    jz resaltarVoleibol
    jnz pedirSiguienteDeportes1
    
;-------------------------------------------------------
;Rutinas para resaltar de forma individual las palabras
;-------------------------------------------------------  
;Resalta Futbol
resaltarFutbol:
    resaltar 2,2,4,4,rojo   
    resaltar 3,3,6,6,rojo
    resaltar 4,4,8,8,rojo
    resaltar 5,5,10,10,rojo
    resaltar 6,6,12,12,rojo  
    resaltar 7,7,14,14,rojo
    inc palabra1    ;Incrementa en 1 el valor de la variable palabra1
    jmp pedirSiguienteDeportes1

;Resalta Natacion    
resaltarNatacion:
    resaltar 4,10,0,0,amarillo                             
    inc palabra2
    jmp pedirSiguienteDeportes1

;Resalta Basquetbol    
resaltarBasquetbol:      
    resaltar 2,10,2,2,rosa                              
    inc palabra3
    jmp pedirSiguienteDeportes1

;Resalta Tenis    
resaltarTenis:     
    resaltar 7,7,8,8,cian           
    resaltar 8,8,10,10,cian         
    resaltar 9,9,12,12,cian 
    resaltar 10,10,14,14,cian 
    resaltar 11,11,16,16,cian  
    inc palabra4
    jmp pedirSiguienteDeportes1

;Resalta Voleibol    
resaltarVoleibol:                          
    resaltar 12,12,6,20,verde   
    inc palabra5
    jmp pedirSiguienteDeportes1    
 
;Rutina para pedir la palabra siguiente  
pedirSiguienteDeportes1:                                   
    mov linea, 0
    mostrar msgSeleccion3
    inc linea
    mostrar deportes1 
    cmp contador, 5 
    jz victoria
    mov linea, 18
    pedirPalabra posicionDeportes1,listaDeportes1
    jmp palabraIngresadaDeportes1

;--------------------------              
;RUTINA PARA MOSTRAR POR CONSOLA LA MATRIZ 2 CON LOS DEPORTES

generarSopaDeportes2:
    mov checkpoint,4    ;Primera sopa de letras
    call clear_screen
    mov linea, 0
    mostrar msgSeleccion3
    inc linea
    mostrar deportes2
    mov linea, 18
    pedirPalabra posicionDeportes2,listaDeportes2 
    jmp palabraIngresadaDeportes2    


;Rutina para validar la palabra ingresada y en caso de ser alguna de las 5 resaltarla en la matriz
palabraIngresadaDeportes2:                                 
    cmp palabra1, 1
    jz resaltarKarate
    cmp palabra2, 1
    jz resaltarCiclismo
    cmp palabra3, 1
    jz resaltarRugby
    cmp palabra4, 1
    jz resaltarAtletismo
    cmp palabra5, 1
    jz resaltarAjedrez
    jnz pedirSiguienteDeportes2
    
;-------------------------------------------------------
;Rutinas para resaltar de forma individual las palabras
;-------------------------------------------------------  
;Resalta Karate
resaltarKarate:
    resaltar 2,7,16,16,rojo 
    inc palabra1    ;Incrementa en 1 el valor de la variable palabra1
    jmp pedirSiguienteDeportes2

;Resalta Ciclismo    
resaltarCiclismo:
    resaltar 4,4,6,6,amarillo   
    resaltar 5,5,8,8,amarillo
    resaltar 6,6,10,10,amarillo
    resaltar 7,7,12,12,amarillo
    resaltar 8,8,14,14,amarillo 
    resaltar 9,9,16,16,amarillo 
    resaltar 10,10,18,18,amarillo 
    resaltar 11,11,20,20,amarillo                             
    inc palabra2
    jmp pedirSiguienteDeportes2

;Resalta Rugby    
resaltarRugby:      
    resaltar 8,8,2,10,rosa                                
    inc palabra3
    jmp pedirSiguienteDeportes2

;Resalta Atletismo    
resaltarAtletismo:     
    resaltar 11,11,2,18,cian  
    inc palabra4
    jmp pedirSiguienteDeportes2

;Resalta Ajedrez    
resaltarAjedrez:                          
    resaltar 12,12,0,12,verde   
    inc palabra5
    jmp pedirSiguienteDeportes2    
 
;Rutina para pedir la palabra siguiente  
pedirSiguienteDeportes2:                                   
    mov linea, 0
    mostrar msgSeleccion3
    inc linea
    mostrar deportes2 
    cmp contador, 5 
    jz victoria
    mov linea, 18
    pedirPalabra posicionDeportes2,listaDeportes2
    jmp palabraIngresadaDeportes2              




        
;RUTINA PARA PRESENTAR EL MENSAJE DE VICTORIA EN CASO DE ADIVINAR LAS 5 PALABRAS
victoria:
    mov linea, 18
    mostrar msgGana
    jmp salir
    
;RUTINA PARA PRESENTAR EL MENSAJE DE DERROTA EN CASO DE QUE EL USUARIO SE RINDA Y RESALTAR TODAS LAS RESPUESTAS
derrota:
    mov linea, 18 
    mostrar salto
    mostrar msgPierde
    cmp checkpoint,1
    jz resaltarRespuestasEquipos1
    cmp checkpoint,2
    jz resaltarRespuestasEquipos2
    cmp checkpoint,3
    jz resaltarRespuestasDeportes1
    cmp checkpoint,4
    jz resaltarRespuestasDeportes2

               
;RUTINAS PARA RESALTAR TODAS LAS RESPUESTAS EN CASO DE QUE EL USUARIO SE RINDA

;Respuestas de la primera sopa de letras de equipos               
resaltarRespuestasEquipos1:
    resaltar 2,2,0,18,rojo   
    resaltar 3,3,6,18,amarillo
    resaltar 7,7,12,20,rosa
    resaltar 8,8,0,12,cian
    resaltar 9,9,4,16,verde 
    mov linea, 0
    mostrar msgSeleccion2
    inc linea
    mostrar equipos1       
    jmp salir    

;Respuestas de la segunda sopa de letras de equipos 
resaltarRespuestasEquipos2:
    resaltar 7,12,2,2,rojo
    resaltar 4,11,8,8,amarillo 
    resaltar 3,3,8,8,rosa                     
    resaltar 4,4,10,10,rosa         
    resaltar 5,5,12,12,rosa                   
    resaltar 6,6,14,14,rosa         
    resaltar 6,12,12,12,cian 
    resaltar 3,11,18,18,verde 
    mov linea, 0
    mostrar msgSeleccion2
    inc linea
    mostrar equipos2       
    jmp salir 

;Respuestas de la primera sopa de letras de deportes 
resaltarRespuestasDeportes1:    
    resaltar 2,2,4,4,rojo   
    resaltar 3,3,6,6,rojo
    resaltar 4,4,8,8,rojo
    resaltar 5,5,10,10,rojo
    resaltar 6,6,12,12,rojo  
    resaltar 7,7,14,14,rojo
    resaltar 4,10,0,0,amarillo
    resaltar 2,10,2,2,rosa
    resaltar 7,7,8,8,cian 
    resaltar 8,8,10,10,cian 
    resaltar 9,9,12,12,cian 
    resaltar 10,10,14,14,cian 
    resaltar 11,11,16,16,cian
    resaltar 12,12,6,20,verde 
    mov linea, 0
    mostrar msgSeleccion3
    inc linea
    mostrar deportes1       
    jmp salir 
 
;Respuestas de la segunda sopa de letras de equipos 
resaltarRespuestasDeportes2:
    resaltar 2,7,16,16,rojo
    resaltar 4,4,6,6,amarillo   
    resaltar 5,5,8,8,amarillo
    resaltar 6,6,10,10,amarillo
    resaltar 7,7,12,12,amarillo
    resaltar 8,8,14,14,amarillo 
    resaltar 9,9,16,16,amarillo 
    resaltar 10,10,18,18,amarillo 
    resaltar 11,11,20,20,amarillo   
    resaltar 8,8,2,10,rosa
    resaltar 11,11,2,18,cian
    resaltar 12,12,0,12,verde
    mov linea, 0
    mostrar msgSeleccion3
    inc linea
    mostrar deportes2       
    jmp salir  
    
;SALIR DEL PROGRAMA
salir:
    mov ah,00h
    int 21h    
 
 


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



DEFINE_CLEAR_SCREEN
DEFINE_SCAN_NUM    
END  


       





       




END  


       





       



