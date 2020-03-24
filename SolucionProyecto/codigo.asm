

INCLUDE Irvine32.inc
.data
	TAM_BUFER = 5000

.data
	txterror BYTE "Hubo un error en la lectura del archivo, verifique la ubicacion o nombre del archivo",0ah,0
	texto1 BYTE "¡Bienvenido!, este programa en ensamblador es para Arquitectura de Computadores (3007863) del semestre 2019-2",0ah,0
	texto2 BYTE "hecho en el 2020 por Alejandro Bedoya Taborda 1152226157 y Cristian Camilo Henao Rojas 1017259477", 0ah, 0
	texto3 BYTE "Aqui va la descripcion", 0ah, 0
	nombreDeArchivo BYTE "DATOS.CSV",0
	manejador DWORD ?
	bufer BYTE TAM_BUFER DUP(?)
	arreglo BYTE TAM_BUFER DUP(0 )
	bytesleidos DWORD ?
	aux DWORD ?
	pos DWORD 0
	hola DWORD 0
	numero DWORD 0
	decima BYTE "0.0", 0
	tamDec = ($ - decima)
	car BYTE "a", 0
	tamBufer = ($ - car)
	diez DWORD 10
	
.code
main PROC
	mov eax, yellow					;Seccion de impresion de mensajes por pantalla
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
	mov esi,47						;Desde aqui voy a recorrer caracter por caracter
	mov ecx,bytesLeidos				;Cuantos caracteres hay

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
			finit
			fld numero
			call WriteFloat
			call Crlf
			mov numero, 0
		salto:
			inc esi
		loop ident
	jmp fin
	archivo_error:					;Se muestra un mensaje si sucede algun error	
		mov eax, black + (12 * 16)
		call SetTextColor
		mov edx, OFFSET txterror
		call WriteString
		mov eax, white + (black * 16)
		call SetTextColor
	fin:
		
		
	exit
main ENDP
Num1 PROC
	mov hola,esi					;Guardamos la posicion actual de esi en hola		
	mov esi,0
	mov car[esi],al					;Guardamos el caracter en car
	mov esi, hola					;Recuperamos esi
	mov eax, numero					
	mul diez						;Multiplicamos por 10 el numero que llevamos hasta ahora
	mov numero, eax					
	mov edx,OFFSET car				;Preparamos los registros para parsear
	mov pos,ecx						;Guardamos la posicion actual de ecx en pos
	mov ecx,tamBufer
	call ParseDecimal32				;Parseamos a decimal el caracter actual
	add numero,eax					;Sumamos el caracter parseado al numero actual
	mov ecx,pos						;Recuperamos la posicion de ecx para poder seguir con la iteracion de ident
	ret
Num1 ENDP
Punto1 PROC
	movzx eax,bufer[esi]			;guardo en eax el caracter numero esi
	mov hola,esi					;Guardamos la posicion actual de esi en hola		
	mov esi,0
	mov car[esi],al					;Guardamos el caracter en car
	mov esi,hola
	mov edx,OFFSET car				;Preparamos los registros para parsear
	mov pos,ecx						;Guardamos la posicion actual de ecx en pos
	mov ecx,tamBufer
	call ParseDecimal32				;Parseamos a decimal el caracter actual
	mov ecx,pos
	mov pos,eax
	finit
	fild pos
	fild diez
	fdiv
	fild numero
	fadd
	fstp numero
	ret
Punto1 ENDP
END main
