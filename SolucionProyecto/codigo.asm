

INCLUDE Irvine32.inc
.data
	TAM_BUFER = 5000

.data
	;Variables de texto
	txterror BYTE "Hubo un error en la lectura del archivo, verifique la ubicacion o nombre del archivo",0ah,0
	texto1 BYTE "Bienvenido, este programa en ensamblador es para Arquitectura de Computadores (3007863) del semestre 2019-2",0ah,0
	texto2 BYTE "hecho en el 2020 por Alejandro Bedoya Taborda 1152226157 y Cristian Camilo Henao Rojas 1017259477", 0ah, 0
	texto3 BYTE "Aqui va la descripcion", 0ah, 0
	textomediaSA BYTE "Media de la sangre arterial: ", 0
	textodesesSA BYTE "Desviacion estandar de la sangre arterial: ", 0
	textomediaSV BYTE "Media de la sangre venosa: ", 0
	textodesesSV BYTE "Desviacion estandar de la sangre venosa: ", 0
	textocorper BYTE "Correlacion de Pearson: ", 0
	nombreDeArchivo BYTE "DATOS.CSV",0
	manejador DWORD ?
	bufer BYTE TAM_BUFER DUP(?)
	bytesleidos DWORD ?
	;Fin variables de texto

	;Variables para uso de calculo general
	sangreArterial REAL4 30 DUP(?)  ;Los datos de cada fila, serán almacenados acá
    sangreVenosa REAL4 30 DUP(?)
	numf REAL4 ?					;Variable para agregar los datos a la pila
	tamLista1 DWORD 30
	tamlista2 DWORD 30.0
	aux DWORD ?
	pos DWORD 0
	auxz DWORD 0
	numero DWORD 0
	mediaSA DWORD 0
	stdSA DWORD 0
	mediaSV DWORD 0
	stdSV DWORD 0
	corpear DWORD 0
	udt BYTE DWORD, 0				;Variable que irá del 1 - 3
	posSA DWORD 0
	posSV DWORD 0
	;Fin variable de uso general

	;Variable de uso para parseo
	decima BYTE "0.0", 0
	tamDec = ($ - decima)
	car BYTE "a", 0
	tamBufer = ($ - car)
	diez DWORD 10
	uno DWORD 1
	;Fin de variables de uso para parseo

.code
main PROC

	;Seccion de impresion de mensajes por pantalla
	mov eax, yellow					
	call SetTextColor
	mov edx, OFFSET texto1			
	call WriteString
	mov eax, 9						;Azul brillante
	call SetTextColor
	mov edx, OFFSET texto2
	call WriteString
	mov eax, 12						;Color rojo brillante
	call SetTextColor
	mov edx, OFFSET texto3
	call WriteString
	mov eax, white + (black * 16)
	call SetTextColor				;Se termina la seccion de impresion de mensajes
	mov edx, OFFSET nombreDeArchivo
	call OpenInputFile				;Se abre el archivo
	cmp eax, INVALID_HANDLE_VALUE	;Se maneja los errores que ocurran al abrir el archivo
	je archivo_error				;Muestra mensaje de error
	mov manejador, eax				;Guarda el manejador del archivo
	mov edx,OFFSET bufer			;Se guarda la direccion de la variable bufer
	mov ecx,TAM_BUFER				;Tamaño de bufer
	call ReadFromFile				;Se lee el archivo abierto
	jc archivo_error				;ocurrió un error
	mov bytesLeidos,eax				;cuenta los bytes que se leyeron
	mov eax, OFFSET bufer			;Se guarda la posicion en donde esta bufer para imprimir el doc
	add eax, 3						;Empieza en 3 porque los 3 primeros caracteres son caracteres raros
	mov edx,eax		
	call WriteString				;Se imprime el doc
	;Fin seccion de impresion de mensajes por pantalla

	;Parseo de datos
	mov esi,47						;Desde aqui voy a recorrer caracter por caracter
	mov ecx,bytesLeidos				;Cuantos caracteres hay
	mov udt, 0						;Iniciamos el clasificador
	mov edi, 0
	ident:							;Este ciclo es para parsear los numeros del documento	
		movzx eax,bufer[esi]		;guardo en eax el caracter numero esi
		cmp eax,44					;la coma es el caracter 44 en la tabla ASCII
		jz coma
		cmp eax,10					;Compara el caracter con un salto de linea
		jz coma
		cmp eax,46					;Compara el caracter con un punto
		jz punto
		call IsDigit				;Verifica si el caracter numero esi es un digito
		jz digito
		jmp salto					;Si es algo diferente, no pasa nada
		digito:
			call Num1		
			jmp salto
		punto:
			inc esi
			call Punto1
			jmp salto
		coma:
			inc udt
			cmp udt, 1				;Decidir donde estará agregado el valor
			jz NP
			cmp udt, 2
			jz SA
			call venosa
			
			jmp salto
		NP:
			mov numero, 0
			mov numf,0
			jmp salto
		SA:
			call arterial
		salto:
			inc esi
		loop ident
	;Fin de parseo

	jmp media_SA

	archivo_error:					;Se muestra un mensaje si sucede algun error	
		call ArchivoError
		jmp fin

; <--- Lectura y extracción de datos completado --->
; <--- Ahora haremos los calculos pedidos --->
	media_SA:
		finit
		mov esi, 0 
		mov ecx, tamLista1
		fldz
		L2:
			fld sangreArterial[esi]
			fadd
			add esi, TYPE REAL4
		loop L2
		fld tamLista2
		fdiv
		mov edx,OFFSET textomediaSa
		call Crlf
		call WriteString
		call writeFloat
		call Crlf
		fstp mediaSA

; Desviación estandar de la sangre Arterial:
	std_SA:
		finit 
		mov numero, 0
		mov esi, 0
		mov ecx, tamLista1
		suma:
			fld sangreArterial[esi]
			add esi, TYPE REAL4
			fld mediaSA
			fsub 
			fst aux
			fld aux
			fmul
			fld numero
			fadd
			fstp numero

		loop suma
		fld numero
		fld tamLista2
		fdiv
		fsqrt
		mov edx,OFFSET textodesesSa
		call Crlf
		call WriteString
		call writeFloat
		call Crlf
		
; Media de la sangre venosa
	media_SV:
		finit
		mov esi, 0 
		mov ecx, tamLista1
		fldz
		suma3:
			fld sangreVenosa[esi]
			fadd
			add esi, TYPE REAL4
		loop suma3
		fld tamLista2
		fdiv
		mov edx,OFFSET textomediaSV
		call Crlf
		call WriteString
		call writeFloat
		call Crlf
		fstp mediaSV

; Desviación estandar de la sangre Venosa:
	std_SV:
		finit 
		mov numero, 0
		mov esi, 0
		mov ecx, tamLista1
		suma4:
			fld sangreVenosa[esi]
			add esi, TYPE REAL4
			fld mediaSV
			fsub 
			fst aux
			fld aux
			fmul
			fld numero
			fadd
			fstp numero

		loop suma4
		fld numero
		fld tamLista2
		fdiv
		fsqrt
		mov edx,OFFSET textodesesSv
		call Crlf
		call WriteString
		call writeFloat
		call Crlf
		fstp stdSV

	;Correlacion de Pearson metodo de puntuaciones directas

		mov esi,0
		mov ecx,30
		mov numero,0
		corr1:						;Aqui se calcula la sumatoria de la multiplicacion de los dos parametros
			finit
			fld sangreVenosa[esi]
			fld sangreArterial[esi]
			fmul
			fld numero
			fadd
			fstp numero
			add esi, TYPE REAL4
		loop corr1					
		finit
		fld  numero
		fild  tamLista1				
		fdiv						;Se divide el calculo por el numero de elementos
		fstp numero					;Aqui se termina el calculo y el valor queda en la variable numero

		mov esi,0
		mov ecx,30
		mov aux,0

		corr2:						;Aqui se inicia el calculo de la suma de los cuadrados del parametro Y
			finit
			fld sangreArterial[esi]	;Nuestro parametro Y es la sangre arterial
			fld sangreArterial[esi]
			fmul
			fld aux
			fadd
			fstp aux
			add esi, TYPE REAL4
		loop corr2					;Aqui termina el calculo y la variable aux guarda el resultado				
		finit
		fld  aux
		fild  tamLista1				
		fdiv						;Se divide el calculo por el numero de elementos
		fstp aux					;Aqui se termina el calculo y el valor queda en la variable aux

		mov esi,0
		mov ecx,30
		mov auxz,0

		corr3:						;Aqui se inicia el calculo de la suma de los cuadrados del parametro X
			finit
			fld sangreVenosa[esi]	;Nuestro parametro X es la sangre venosa
			fld sangreVenosa[esi]
			fmul
			fld auxz
			fadd
			fstp auxz
			add esi, TYPE REAL4
		loop corr3					;Aqui termina el calculo y la variable auxz guarda el resultado
		finit
		fld  auxz
		fild  tamLista1				
		fdiv						;Se divide el calculo por el numero de elementos
		fstp auxz					;Aqui se termina el calculo y el valor queda en la variable auxz
		
		;Se calcula Sy
		finit
		fld aux
		fld mediaSA
		fld mediaSA
		fmul
		fsub
		fsqrt
		fstp aux
		;Fin de Sy y queda en aux

		;Se calcula Sx
		finit
		fld auxz
		fld mediaSV
		fld mediaSV
		fmul
		fsub
		fsqrt
		fstp auxz
		;Fin de Sx y queda en auxz

		;Se calcula el numerador
		finit
		fld numero
		fld mediaSA
		fld mediaSV
		fmul
		fsub
		fstp numero
		;Fin del numerador, se guarda en numero

		;Calculo del denominador y resultado final
		finit
		fld numero
		fld aux
		fld auxz
		fmul
		fdiv
		call Crlf
		call WaitMsg
		call Crlf
		mov edx,OFFSET textocorper
		call Crlf
		call WriteString
		call writeFloat
		call Crlf
		fstp corpear
		;Fin del calculo de la correlacion, queda guardada en la variable corpear

		call Crlf
		call WaitMsg
		call Crlf
	fin:	
	exit
main ENDP

ArchivoError PROC
	mov eax, black + (12 * 16)
	call SetTextColor
	mov edx, OFFSET txterror
	call WriteString
	mov eax, white + (black * 16)
	call SetTextColor
ArchivoError ENDP

Num1 PROC
	mov auxz,esi					;Guardamos la posicion actual de esi en auxz		
	mov esi,0
	mov car[esi],al					;Guardamos el caracter en car
	mov esi, auxz					;Recuperamos esi
	mov eax, numero					
	mul diez						;Multiplicamos por 10 el numero que llevamos hasta ahora
	mov numero, eax					
	mov edx,OFFSET car				;Preparamos los registros para parsear
	mov pos,ecx						;Guardamos la posicion actual de ecx en pos
	mov ecx,tamBufer
	call ParseDecimal32				;Parseamos a decimal el caracter actual
	add numero,eax					;Sumamos el caracter parseado al numero actual
	finit
	fild numero
	fild uno
	fdiv							;Convertimos el numero que tenemos en la variable numero a un decimal
	fstp numf						;Guardamos ese numero decimal en numf
	mov ecx,pos						;Recuperamos la posicion de ecx para poder seguir con la iteracion de ident
	ret
Num1 ENDP

Punto1 PROC
	movzx eax,bufer[esi]			;guardo en eax el caracter numero esi
	mov auxz,esi					;Guardamos la posicion actual de esi en auxz		
	mov esi,0
	mov car[esi],al					;Guardamos el caracter en car
	mov esi,auxz
	mov edx,OFFSET car				;Preparamos los registros para parsear
	mov pos,ecx						;Guardamos la posicion actual de ecx en pos
	mov ecx,tamBufer
	call ParseDecimal32				;Parseamos a decimal el caracter actual
	mov ecx,pos
	mov pos,eax
	finit
	fild pos
	fild diez
	fdiv							;Obtenemos el punto decimal del numero del archivo
	fild numero
	fadd							;Se lo agregamos al numero que llevamos en numf 
	
	fstp numf						;Se guarda el valor en numf
	ret
Punto1 ENDP

venosa PROC							;Llenaremos los datos de Sangre Venosa
	finit
	fld numf						; Contiene el número que deseamos almacenas
	mov edi, posSV					; tomamos la posición anterior
	fstp sangreVenosa[edi]
	add posSV,TYPE REAL4	
	mov udt, 0	
	mov edi,0
	fld numf
	mov numero,0
	mov numf, 0
	ret
venosa ENDP


arterial PROC						; Llenaremos los datos de Sangre Arterial
	finit
	fld numf						;contiene el número que deseamos almacenar
	mov edi, posSA					; tomamos la posición anterior		
	fstp sangreArterial[edi]		; damos por entendido que UDT = 3.
	add posSA, TYPE REAL4
	mov edi, 0
	fld numf
	mov numero,0
	mov numf, 0
	ret
arterial ENDP

END main
