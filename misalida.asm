;D:	main
;D:	{
;D:	int
;R:	modificadores_acceso:
;R:	tipo: TOK_INT
;R:	clase_escalar: tipo
;R:	clase: clase_escalar
;D:	y
;R:	identificador: TOK_IDENTIFICADOR;D:	;
;R:	identificadores: identificador
;R:	declaracion: modificadores_acceso clase identificadores ';'
;D:	int
;R:	modificadores_acceso:
;R:	tipo: TOK_INT
;R:	clase_escalar: tipo
;R:	clase: clase_escalar
;D:	p
;R:	identificador: TOK_IDENTIFICADOR;D:	;
;R:	identificadores: identificador
;R:	declaracion: modificadores_acceso clase identificadores ';'
;D:	int
;R:	modificadores_acceso:
;R:	tipo: TOK_INT
;R:	clase_escalar: tipo
;R:	clase: clase_escalar
;D:	t
;R:	identificador: TOK_IDENTIFICADOR;D:	;
;R:	identificadores: identificador
;R:	declaracion: modificadores_acceso clase identificadores ';'
;D:	int
;R:	modificadores_acceso:
;R:	tipo: TOK_INT
;R:	clase_escalar: tipo
;R:	clase: clase_escalar
;D:	q
;R:	identificador: TOK_IDENTIFICADOR;D:	;
;R:	identificadores: identificador
;R:	declaracion: modificadores_acceso clase identificadores ';'
;D:	function
;R:	declaraciones: declaracion
;R:	declaraciones: declaracion declaraciones
;R:	declaraciones: declaracion declaraciones
;R:	declaraciones: declaracion declaraciones

; --- Funcion escribir_subseccion_data---
segment .data
	ErrorDiv0 db "Error division por cero", 0
	ErrorIndex db "Indice fuera de rango", 0

; --- Funcion escribir_cabecera .bss---
segment .bss
	 __esp resd 1

; ---Funcion declarar_variable---
	_y resd 1

; ---Funcion declarar_variable---
	_p resd 1

; ---Funcion declarar_variable---
	_t resd 1

; ---Funcion declarar_variable---
	_q resd 1

; --- Funcion segmento codigo---
segment .text
	global main
	extern scan_int, print_int, print_boolean, scan_boolean
	extern print_blank, print_endofline, print_string
;D:	int
;R:	modificadores_acceso:
;R:	tipo: TOK_INT
;R:	tipo_retorno: tipo
;D:	suma
;D:	(
;D:	int
;R:	tipo: TOK_INT
;D:	x
;R:	parametro_funcion: tipo identificador
;D:	,
;D:	int
;R:	tipo: TOK_INT
;D:	z
;R:	parametro_funcion: tipo identificador
;D:	)
;R:	resto_parametros_funcion:
;R:	resto_parametros_funcion: ; parametro_funcion resto_parametros_funcion
;R:	parametros_funcion: parametro_funcion resto_parametros_funcion
;D:	{
;D:	int
;R:	modificadores_acceso:
;R:	tipo: TOK_INT
;R:	clase_escalar: tipo
;R:	clase: clase_escalar
;D:	w
;R:	identificador: TOK_IDENTIFICADOR;D:	;
;R:	identificadores: identificador
;R:	declaracion: modificadores_acceso clase identificadores ';'
;D:	w
;R:	declaraciones: declaracion
;R:	declaraciones_funcion: declaracion

;---Funcion declarar_funcion---
_suma:
	push ebp
	mov ebp ,esp
	sub esp ,4 * 5
;D:	=
;D:	x
;D:	+
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: x
;exp2 es param: x
	lea  eax, [ebp+4+( 4 * 3 )]
	push dword eax
;D:	z
;D:	;
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: z
;exp2 es param: z
	lea  eax, [ebp+4+( 4 * 2 )]
	push dword eax
;R:	exp: exp '+' exp 

;---Funcion suma---
	pop dword eax
	pop dword ecx
	mov dword ecx, [ecx]
	mov dword eax, [eax]
	add eax, ecx
	push dword eax
;R:	asignacion: TOK_IDENTIFICADOR '=' exp
;R:	LEXEMA1 : w, LEXEMA2: x
	lea  eax, [ebp - 4 * 1 ]
	push dword eax
	pop dword eax
	pop dword ebx
	mov [eax], ebx
;R:	sentencia_simple: asignacion
;R:	sentencia: sentencia_simple ';'
;D:	return
;D:	w
;D:	;
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: w
	lea  eax, [ebp - 4 * 1 ]
	push dword eax
;R:	retorno_funcion: TOK_RETURN exp

;---Funcion retornar_funcion---
	pop dword eax
	mov eax, [eax]
	mov esp ,ebp
	pop dword ebp
	ret
;R:	sentencia_simple: retorno_funcion
;R:	sentencia: sentencia_simple ';'
;D:	}
;R:	sentencias: sentencia
;R:	sentencias: sentencia sentencias
;R:	funcion: TOK_FUNCTION modificadores_acceso tipo_retorno TOK_IDENTIFICADOR '(' parametro_funcion ')' declaraciones_funcion sentencia
;D:	function
;D:	int
;R:	modificadores_acceso:
;R:	tipo: TOK_INT
;R:	tipo_retorno: tipo
;D:	resta
;D:	(
;D:	int
;R:	tipo: TOK_INT
;D:	c
;R:	parametro_funcion: tipo identificador
;D:	,
;D:	int
;R:	tipo: TOK_INT
;D:	a
;R:	parametro_funcion: tipo identificador
;D:	)
;R:	resto_parametros_funcion:
;R:	resto_parametros_funcion: ; parametro_funcion resto_parametros_funcion
;R:	parametros_funcion: parametro_funcion resto_parametros_funcion
;D:	{
;D:	int
;R:	modificadores_acceso:
;R:	tipo: TOK_INT
;R:	clase_escalar: tipo
;R:	clase: clase_escalar
;D:	w
;R:	identificador: TOK_IDENTIFICADOR;D:	;
;R:	identificadores: identificador
;R:	declaracion: modificadores_acceso clase identificadores ';'
;D:	w
;R:	declaraciones: declaracion
;R:	declaraciones_funcion: declaracion

;---Funcion declarar_funcion---
_resta:
	push ebp
	mov ebp ,esp
	sub esp ,4 * 6
;D:	=
;D:	c
;D:	-
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: c
;exp2 es param: c
	lea  eax, [ebp+4+( 4 * 3 )]
	push dword eax
;D:	a
;D:	;
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: a
;exp2 es param: a
	lea  eax, [ebp+4+( 4 * 2 )]
	push dword eax
;R:	exp: exp '-' exp 

;---Funcion resta---
	pop dword eax
	pop dword ecx
	mov dword ecx, [ecx]
	mov dword eax, [eax]
	sub ecx, eax
	push dword ecx
;R:	asignacion: TOK_IDENTIFICADOR '=' exp
;R:	LEXEMA1 : w, LEXEMA2: c
	lea  eax, [ebp - 4 * 1 ]
	push dword eax
	pop dword eax
	pop dword ebx
	mov [eax], ebx
;R:	sentencia_simple: asignacion
;R:	sentencia: sentencia_simple ';'
;D:	return
;D:	w
;D:	;
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: w
	lea  eax, [ebp - 4 * 1 ]
	push dword eax
;R:	retorno_funcion: TOK_RETURN exp

;---Funcion retornar_funcion---
	pop dword eax
	mov eax, [eax]
	mov esp ,ebp
	pop dword ebp
	ret
;R:	sentencia_simple: retorno_funcion
;R:	sentencia: sentencia_simple ';'
;D:	}
;R:	sentencias: sentencia
;R:	sentencias: sentencia sentencias
;R:	funcion: TOK_FUNCTION modificadores_acceso tipo_retorno TOK_IDENTIFICADOR '(' parametro_funcion ')' declaraciones_funcion sentencia
;D:	scanf
;R:	funciones:
;R:	funciones: funcion funciones
;R:	funciones: funcion funciones

;---Funcion escribir_inicio_main---
main:
	mov dword [__esp], esp
;D:	y
;D:	;
;R:	lectura: TOK_SCANF TOK_IDENTIFICADOR  

;---Funcion leer---
	push dword _y
	call scan_int
	add esp, 4
;R:	sentencia_simple: lectura
;R:	sentencia: sentencia_simple ';'
;D:	scanf
;D:	p
;D:	;
;R:	lectura: TOK_SCANF TOK_IDENTIFICADOR  

;---Funcion leer---
	push dword _p
	call scan_int
	add esp, 4
;R:	sentencia_simple: lectura
;R:	sentencia: sentencia_simple ';'
;D:	t
;D:	=
;D:	suma
;D:	(
;D:	y
;D:	,
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: y
	push dword [_y]
;D:	p
;D:	)
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: p
	push dword [_p]
;R:	resto_lista_expresiones:
;R:	resto_expresiones: ',' exp resto_lista_expresiones
	push dword _p
;R:	lista_expresiones: exp resto_lista_expresiones
;R:	exp: idpf '(' lista_expresiones ')' 
	call _suma
	add esp, 4 * 2
	push dword eax
;D:	;
;R:	asignacion: TOK_IDENTIFICADOR '=' exp
;R:	LEXEMA1 : t, LEXEMA2: suma

; ---Funcion asignar---
	pop dword eax
	mov dword [_t], eax
;R:	sentencia_simple: asignacion
;R:	sentencia: sentencia_simple ';'
;D:	q
;D:	=
;D:	resta
;D:	(
;D:	y
;D:	,
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: y
	push dword [_y]
;D:	p
;D:	)
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: p
	push dword [_p]
;R:	resto_lista_expresiones:
;R:	resto_expresiones: ',' exp resto_lista_expresiones
	push dword _p
;R:	lista_expresiones: exp resto_lista_expresiones
;R:	exp: idpf '(' lista_expresiones ')' 
	call _resta
	add esp, 4 * 2
	push dword eax
;D:	;
;R:	asignacion: TOK_IDENTIFICADOR '=' exp
;R:	LEXEMA1 : q, LEXEMA2: resta

; ---Funcion asignar---
	pop dword eax
	mov dword [_q], eax
;R:	sentencia_simple: asignacion
;R:	sentencia: sentencia_simple ';'
;D:	printf
;D:	t
;D:	;
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: t

; ---Funcion escribir_operando---
	push dword _t
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
;D:	printf
;D:	q
;D:	;
;R:	exp: TOK_IDENTIFICADOR
;Identificaodr: q

; ---Funcion escribir_operando---
	push dword _q
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
;R:	sentencias: sentencia sentencias
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
