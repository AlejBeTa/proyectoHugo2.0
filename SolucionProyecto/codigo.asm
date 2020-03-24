

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
	unDig BYTE "coma", 0
	car BYTE "a", 0
	doDig BYTE "numero", 0
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
	mov esi,37						;Desde aqui voy a recorrer caracter por caracter
	mov ecx,bytesLeidos				;Cuantos caracteres hay

	ident:
		movzx eax,bufer[esi]		;guardo en eax el caracter numero esi
		cmp eax,44					;la coma es el caracter 44 en la tabla ASCII
		jz coma
		cmp eax,10
		jz coma
		call IsDigit				;Verifica si el caracter numero esi es un digito
		jz digito
		jmp salto					;Si es algo diferente, no pasa nada
		digito:
			call Num1		
			jmp salto
		coma:
			mov eax,numero
			call WriteInt
			call Crlf
			mov numero, 0
		salto:

			inc esi
		loop ident
	mov edx,OFFSET doDig			;Aqui inicia la impresion del ultimo texto
	call WriteString
	call Crlf
	mov eax, pos
	call WriteInt
	call Crlf
	mov edx,OFFSET unDig
	call WriteString
	call Crlf
	mov eax, hola
	call WriteInt
	call Crlf						;Aqui se acaba la impresion
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
	mov hola,esi
	mov esi,0
	mov car[esi],al
	mov esi, hola
	mov eax, numero			
	mul diez
	mov numero, eax
	mov edx,OFFSET car
	mov pos,ecx
	mov ecx,tamBufer
	call ParseDecimal32
	add numero,eax
	mov ecx,pos	
	ret
Num1 ENDP
END main
