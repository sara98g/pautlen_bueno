;D:	main
;D:	{
;D:	int
;R:	modificadores_acceso:
;R:	tipo: TOK_INT
;R:	clase_escalar: tipo
;R:	clase: clase_escalar
;D:	x
;R:	identificador: TOK_IDENTIFICADOR;D:	,
;D:	resultado
;R:	identificador: TOK_IDENTIFICADOR;D:	;
;R:	identificadores: identificador
;R:	identificadores: identificador ','identificadores
;R:	declaracion: modificadores_acceso clase identificadores ';'
;D:	function
;R:	declaraciones: declaracion

; --- Funcion escribir_subseccion_data---
segment .data
	ErrorDiv0 db "Error division por cero", 0
	ErrorIndex db "Indice fuera de rango", 0

; --- Funcion escribir_cabecera .bss---
segment .bss
	 __esp resd 1

; ---Funcion declarar_variable---
	_x resd 1

; ---Funcion declarar_variable---
	_resultado resd 1

; --- Funcion segmento codigo---
segment .text
	global main
	extern scan_int, print_int, print_boolean, scan_boolean
	extern print_blank, print_endofline, print_string
;D:	int
;R:	modificadores_acceso:
;R:	tipo: TOK_INT
;R:	tipo_retorno: tipo
;D:	fibonacci
;D:	(
;D:	int
;R:	tipo: TOK_INT
;D:	num1
;R:	parametro_funcion: tipo identificador
;D:	)
;R:	resto_parametros_funcion:
;R:	parametros_funcion: parametro_funcion resto_parametros_funcion
;D:	{
;D:	int
;R:	modificadores_acceso:
;R:	tipo: TOK_INT
;R:	clase_escalar: tipo
;R:	clase: clase_escalar
;D:	res1
;R:	identificador: TOK_IDENTIFICADOR;D:	,
;D:	res2
;R:	identificador: TOK_IDENTIFICADOR;D:	;
;R:	identificadores: identificador
;R:	identificadores: identificador ','identificadores
;R:	declaracion: modificadores_acceso clase identificadores ';'
;D:	if
;R:	declaraciones: declaracion
;R:	declaraciones_funcion: declaracion

; ---Funcion declararFuncion---
_fibonacci:
	push ebp
	mov ebp ,esp
	sub esp ,4 * 4
;D:	(
;D:	(
;D:	num1
;D:	==
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: num1
;exp2 es param: num1
	lea  eax, [ebp+4+( 4 * 1 )]
	push dword eax
;D:	0
;R:	constante_entera: TOK_CONSTANTE_ENTERA

; ---Funcion escribir_operando---
	push dword 0
;R:	constante: constante_entera
;R:	exp: constante 
;D:	)
;R:	comparacion: exp TOK_IGUAL exp 

;---Funcion igual---
	pop dword ecx
	pop dword eax
	mov dword eax, [eax]
	cmp eax, ecx
	jz near true_0
	mov dword eax, 0
	push dword eax
	jmp near continua_0
	true_0:
		mov dword eax, 1
		push dword eax
	continua_0:
;R:	exp:'(' comparacion ')' 
;D:	)
;D:	{
;R:	if_exp: TOK_IF '(' exp 

; ---Funcion ifthen_inicio---
	pop eax
	cmp eax, 0
	je near fin_si1
;D:	return
;D:	0
;R:	constante_entera: TOK_CONSTANTE_ENTERA

; ---Funcion escribir_operando---
	push dword 0
;R:	constante: constante_entera
;R:	exp: constante 
;D:	;
;R:	retorno_funcion: TOK_RETURN exp

; ---Funcion retornarFuncion---
	pop dword eax
	mov esp ,ebp
	pop dword ebp
	ret
;R:	sentencia_simple: retorno_funcion
;R:	sentencia: sentencia_simple ';'
;D:	}
;R:	sentencias: sentencia
;D:	if
;R:	condicional: TOK_IF '(' exp ')' '{' sentencias '}' 

; ---Funcion ifthen_fin---
fin_si1:
;R:	bloque: condicional
;R:	sentencia: bloque
;D:	(
;D:	(
;D:	num1
;D:	==
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: num1
;exp2 es param: num1
	lea  eax, [ebp+4+( 4 * 1 )]
	push dword eax
;D:	1
;R:	constante_entera: TOK_CONSTANTE_ENTERA

; ---Funcion escribir_operando---
	push dword 1
;R:	constante: constante_entera
;R:	exp: constante 
;D:	)
;R:	comparacion: exp TOK_IGUAL exp 

;---Funcion igual---
	pop dword ecx
	pop dword eax
	mov dword eax, [eax]
	cmp eax, ecx
	jz near true_2
	mov dword eax, 0
	push dword eax
	jmp near continua_2
	true_2:
		mov dword eax, 1
		push dword eax
	continua_2:
;R:	exp:'(' comparacion ')' 
;D:	)
;D:	{
;R:	if_exp: TOK_IF '(' exp 

; ---Funcion ifthen_inicio---
	pop eax
	cmp eax, 0
	je near fin_si3
;D:	return
;D:	1
;R:	constante_entera: TOK_CONSTANTE_ENTERA

; ---Funcion escribir_operando---
	push dword 1
;R:	constante: constante_entera
;R:	exp: constante 
;D:	;
;R:	retorno_funcion: TOK_RETURN exp

; ---Funcion retornarFuncion---
	pop dword eax
	mov esp ,ebp
	pop dword ebp
	ret
;R:	sentencia_simple: retorno_funcion
;R:	sentencia: sentencia_simple ';'
;D:	}
;R:	sentencias: sentencia
;D:	res1
;R:	condicional: TOK_IF '(' exp ')' '{' sentencias '}' 

; ---Funcion ifthen_fin---
fin_si3:
;R:	bloque: condicional
;R:	sentencia: bloque
;D:	=
;D:	fibonacci
;D:	(
;D:	num1
;D:	-
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: num1
;exp2 es param: num1
	lea  eax, [ebp+4+( 4 * 1 )]
	push dword eax
;D:	1
;R:	constante_entera: TOK_CONSTANTE_ENTERA

; ---Funcion escribir_operando---
	push dword 1
;R:	constante: constante_entera
;R:	exp: constante 
;D:	)
;R:	exp: exp '-' exp 

;---Funcion resta---
	pop dword eax
	pop dword ecx
	mov dword ecx, [ecx]
	sub ecx, eax
	push dword ecx
;R:	resto_lista_expresiones:
;R:	lista_expresiones: exp resto_lista_expresiones
;R:	exp: idpf '(' lista_expresiones ')' 

; ---Funcion llamarFuncion---
	call _fibonacci
	add esp, 4 * 1
	push dword eax
;D:	;
;R:	asignacion: TOK_IDENTIFICADOR '=' exp
;R:	LEXEMA1 : res1, LEXEMA2: fibonacci
	lea  eax, [ebp - 4 * 1 ]
	push dword eax
	pop dword eax
	pop dword ebx
	mov [eax], ebx
;R:	sentencia_simple: asignacion
;R:	sentencia: sentencia_simple ';'
;D:	res2
;D:	=
;D:	fibonacci
;D:	(
;D:	num1
;D:	-
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: num1
;exp2 es param: num1
	lea  eax, [ebp+4+( 4 * 1 )]
	push dword eax
;D:	2
;R:	constante_entera: TOK_CONSTANTE_ENTERA

; ---Funcion escribir_operando---
	push dword 2
;R:	constante: constante_entera
;R:	exp: constante 
;D:	)
;R:	exp: exp '-' exp 

;---Funcion resta---
	pop dword eax
	pop dword ecx
	mov dword ecx, [ecx]
	sub ecx, eax
	push dword ecx
;R:	resto_lista_expresiones:
;R:	lista_expresiones: exp resto_lista_expresiones
;R:	exp: idpf '(' lista_expresiones ')' 

; ---Funcion llamarFuncion---
	call _fibonacci
	add esp, 4 * 1
	push dword eax
;D:	;
;R:	asignacion: TOK_IDENTIFICADOR '=' exp
;R:	LEXEMA1 : res2, LEXEMA2: fibonacci
	lea  eax, [ebp - 4 * 2 ]
	push dword eax
	pop dword eax
	pop dword ebx
	mov [eax], ebx
;R:	sentencia_simple: asignacion
;R:	sentencia: sentencia_simple ';'
;D:	return
;D:	res1
;D:	+
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: res1
	lea  eax, [ebp - 4 * 1 ]
	push dword eax
;D:	res2
;D:	;
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: res2
	lea  eax, [ebp - 4 * 2 ]
	push dword eax
;R:	exp: exp '+' exp 

;---Funcion suma---
	pop dword eax
	pop dword ecx
	mov dword ecx, [ecx]
	mov dword eax, [eax]
	add eax, ecx
	push dword eax
;R:	retorno_funcion: TOK_RETURN exp

; ---Funcion retornarFuncion---
	pop dword eax
	mov esp ,ebp
	pop dword ebp
	ret
;R:	sentencia_simple: retorno_funcion
;R:	sentencia: sentencia_simple ';'
;D:	}
;R:	sentencias: sentencia
;R:	sentencias: sentencia sentencias
;R:	sentencias: sentencia sentencias
;R:	sentencias: sentencia sentencias
;R:	sentencias: sentencia sentencias
;R:	funcion: TOK_FUNCTION modificadores_acceso tipo_retorno TOK_IDENTIFICADOR '(' parametro_funcion ')' declaraciones_funcion sentencia
;D:	scanf
;R:	funciones:
;R:	funciones: funcion funciones

;---Funcion escribir_inicio_main---
main:
	mov dword [__esp], esp
;D:	x
;D:	;
;R:	lectura: TOK_SCANF TOK_IDENTIFICADOR  

;---Funcion leer---
	push dword _x
	call scan_int
	add esp, 4
;R:	sentencia_simple: lectura
;R:	sentencia: sentencia_simple ';'
;D:	resultado
;D:	=
;D:	fibonacci
;D:	(
;D:	x
;D:	)
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: x
	push dword [_x]
;R:	resto_lista_expresiones:
;R:	lista_expresiones: exp resto_lista_expresiones
;R:	exp: idpf '(' lista_expresiones ')' 

; ---Funcion llamarFuncion---
	call _fibonacci
	add esp, 4 * 1
	push dword eax
;D:	;
;R:	asignacion: TOK_IDENTIFICADOR '=' exp
;R:	LEXEMA1 : resultado, LEXEMA2: fibonacci

; ---Funcion asignar---
	pop dword eax
	mov dword [_resultado], eax
;R:	sentencia_simple: asignacion
;R:	sentencia: sentencia_simple ';'
;D:	printf
;D:	resultado
;D:	;
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: resultado

; ---Funcion escribir_operando---
	push dword _resultado
;R:	escritura: TOK_PRINTF exp

;---Funcion escribir---
	pop dword eax
	mov dword eax, [eax]
	push dword eax
	call print_int
	add esp, 4
	call print_endofline
;R:	sentencia_simple: escritura
;R:	sentencia: sentencia_simple ';'
;D:	}
;R:	sentencias: sentencia
;R:	sentencias: sentencia sentencias
;R:	sentencias: sentencia sentencias
;R:	programa: TOK_MAIN '{' declaraciones funciones sentencias '}'

; ---Funcion fin---
	jmp near fin
	mensaje_1:
		push dword ErrorIndex
		call print_string
		add esp, 4
	jmp near fin
	fin_error_division:
		push dword ErrorDiv0
		call print_string
		add esp, 4
	fin:
		mov dword esp, [__esp]
		call print_endofline
		ret
