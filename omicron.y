%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "omicron.h"
  #include "generacion.h"
  #include "estructuras.h"

  extern int yylex();
  extern int yyleng;
  extern tablaSimbolosAmbitos *tsa;

  extern FILE* yyin;
  extern FILE* salida;
  extern int columna;
  extern int line;
  void yyerror( char *s);

  int clase_actual, tipo_actual, tamanio_vector_actual, tamanio_actual;
  int etiqueta_global = 0;

  char idAmbito[64];
  elementoTablaSimbolos * e = NULL;



%}

  %union{
        tipo_atributo atributos;
  }

  %token <atributos> TOK_IDENTIFICADOR
  %token <atributos> TOK_CONSTANTE_ENTERA

  %type <atributos> exp
  %type <atributos> elemento_vector
  %type <atributos> comparacion
  %type <atributos> constante
  %type <atributos> constante_entera
  %type <atributos> constante_logica
  %type <atributos> asignacion
  %type <atributos> lectura
  %type <atributos> escritura
  %type <atributos> condicional
  %type <atributos> while
  %type <atributos> while_exp
  %type <atributos> if_exp
  %type <atributos> if_exp_sentencias
  %type <atributos> bucle


  %token TOK_NONE
  %token TOK_CLASS
  %token TOK_INHERITS
  %token TOK_INSTANCE_OF
  %token TOK_DISCARD
  %token TOK_ITSELF
  %token TOK_FLECHA
  %token TOK_HIDDEN
  %token TOK_SECRET
  %token TOK_EXPOSED
  %token TOK_UNIQUE
  %token TOK_FUNCTION
  %token TOK_RETURN
  %token TOK_MAIN
  %token TOK_INT
  %token TOK_BOOLEAN
  %token TOK_ARRAY
  %token TOK_IF
  %token TOK_ELSE
  %token TOK_WHILE
  %token TOK_SCANF
  %token TOK_PRINTF
  %token TOK_IGUAL
  %token TOK_DISTINTO
  %token TOK_MENORIGUAL
  %token TOK_MAYORIGUAL
  %token TOK_OR
  %token TOK_AND
  %token TOK_FALSE
  %token TOK_TRUE
  %token TOK_ERROR
  %token TOK_FOR
  %token TOK_SWITCH
  %token TOK_CASE
  %token TOK_DEFAULT
  %token TOK_FLOAT
  %token TOK_MALLOC
  %token TOK_CPRINTF
  %token TOK_FREE
  %token TOK_SET
  %token TOK_OF
  %token TOK_UNION
  %token TOK_INTERSECTION
  %token TOK_ADD
  %token TOK_CLEAR
  %token TOK_SIZE
  %token TOK_CONTAINS
  %token TOK_CONSTANTE_REAL



  %left '+' '-' TOK_OR
  %left '*' '/' TOK_AND
  %right NEG '!'

  %start programa

%%

programa:  TOK_MAIN '{' declaraciones iniciar_codigo escribir_variables funciones inicio_main sentencias '}' {fprintf(salida,";R:\tprograma: TOK_MAIN '{' declaraciones funciones sentencias '}'\n"); escribir_fin(salida);} /*REVISAR CON LA TABLA DE SIMBOLOS*/
        | TOK_MAIN '{' iniciar_codigo funciones inicio_main sentencias '}' {fprintf(salida,";R:\tprograma: TOK_MAIN '{' funciones sentencias '}'\n"); escribir_fin(salida);}
        ;

iniciar_codigo: /*vacio*/
        {
        escribir_subseccion_data(salida);
        escribir_cabecera_bss(salida);

      };

escribir_variables: /*vacio*/
        {
          TablaHash *th=NULL;
        	 NodoHash *n=NULL;
           elementoTablaSimbolos *e=NULL;
          char* clave=NULL;
          int i;
          th = tsa->global;
          for(i=0; i<th->nElem; i++){

            clave = th->lista[i];
            n = buscarNodoHash(th, clave);
            if(n == NULL){
              printf("El nodo ha develto NULL\n");
            }
            e = nodo_get_ElementoTablaSimbolos(n);
            if(e == NULL){
              printf("El ELEMNTO ha develto NULL\n");
            }
            declarar_variable(salida, e->clave,  1,  e->tamanio);
          }
            escribir_segmento_codigo(salida);
        };

inicio_main: /*vacio*/
        {
                escribir_inicio_main(salida);
        };

declaraciones: declaracion declaraciones {fprintf(salida,";R:\tdeclaraciones: declaracion declaraciones\n");}
        | declaracion {fprintf(salida,";R:\tdeclaraciones: declaracion\n");}
        ;

declaracion: modificadores_acceso clase identificadores ';' {fprintf(salida,";R:\tdeclaracion: modificadores_acceso clase identificadores ';'\n");}
        | modificadores_acceso declaracion_clase ';'{fprintf(salida,";R:\tdeclaracion: modificadores_acceso declaracion_clase ';'\n");}
        ;

modificadores_acceso: TOK_HIDDEN TOK_UNIQUE {fprintf(salida,";R:\tmodificadores_acceso: TOK_HIDDEN TOK_UNIQUE\n");}
        | TOK_SECRET TOK_UNIQUE {fprintf(salida,";R:\tmodificadores_acceso: TOK_SECRET TOK_UNIQUE\n");}
        | TOK_EXPOSED TOK_UNIQUE {fprintf(salida,";R:\tmodificadores_acceso: TOK_EXPOSED TOK_UNIQUE\n");}
        | TOK_HIDDEN {fprintf(salida,";R:\tmodificadores_acceso: TOK_HIDDEN\n");}
        | TOK_SECRET {fprintf(salida,";R:\tmodificadores_acceso: TOK_SECRET\n");}
        | TOK_EXPOSED {fprintf(salida,";R:\tmodificadores_acceso: TOK_EXPOSED\n");}
        | TOK_UNIQUE {fprintf(salida,";R:\tmodificadores_acceso: TOK_UNIQUE\n");}
        | /*vacio*/ {fprintf(salida,";R:\tmodificadores_acceso:\n");}
        ;

clase: clase_escalar {fprintf(salida,";R:\tclase: clase_escalar\n"); clase_actual=ESCALAR;}
        | clase_vector {fprintf(salida,";R:\tclase: clase_vector\n");clase_actual=VECTOR;}
        | clase_objeto {fprintf(salida,";R:\tclase: clase_objeto\n");}
        ;

declaracion_clase: modificadores_clase TOK_CLASS TOK_IDENTIFICADOR TOK_INHERITS identificadores '{' declaraciones funciones '}' {fprintf(salida,";R:\tdeclaracion_clase: modificadores_clase  TOK_CLASS TOK_IDENTIFICADOR TOK_INHERITS identificadores '{' declaraciones funciones '}'\n");}
        | modificadores_clase TOK_CLASS TOK_IDENTIFICADOR '{' declaraciones funciones '}' {fprintf(salida,";R:\tdeclaracion_clase: modificadores_clase  TOK_CLASS TOK_IDENTIFICADOR '{' declaraciones funciones '}'\n");}
        ;

modificadores_clase: /*vacio*/ {
          fprintf(salida,";R:\tmodificadores_clase:\n");
        }
        ;

clase_escalar: tipo {fprintf(salida,";R:\tclase_escalar: tipo\n"); clase_actual= ESCALAR;}
        ;

tipo: TOK_INT {fprintf(salida,";R:\ttipo: TOK_INT\n"); tipo_actual =ENTERO;}
        | TOK_BOOLEAN {fprintf(salida,";R:\ttipo: TOK_BOOLEAN\n"); tipo_actual = BOOLEANO;} /*REVISAR NO SE QUE VALOR ES BOOLEAN*/
        ;

clase_objeto: '{' TOK_IDENTIFICADOR '}' {fprintf(salida,";R:\tclase_objeto: '{' TOK_IDENTIFICADOR '}'\n");}
        ;

clase_vector: TOK_ARRAY tipo '['TOK_CONSTANTE_ENTERA']' {
              fprintf(salida,";R:\tclase_vector: TOK_ARRAY tipo '[' TOK_CONSTANTE_ENTERA ']'\n");
              tamanio_vector_actual = $4.valor_entero;
              clase_actual = VECTOR;
              if ((tamanio_vector_actual <1) || (tamanio_vector_actual > 64)){
                printf("ERROR SEMANTICO: %d:%d - Tamaño vector demasiado grande\n",line, columna-yyleng);
                exit(-1);
              }

            }
        | TOK_ARRAY tipo '[' constante_entera ',' constante_entera ']' {fprintf(salida,";R:\tclase_vector: TOK_ARRAY tipo '[' constante_entera ',' constante_entera ']'\n");}
        ;
identificadores:
          identificador
            {fprintf(salida,";R:\tidentificadores: identificador\n");}
        | identificador ',' identificadores
            {fprintf(salida,";R:\tidentificadores: identificador ','identificadores\n");}
        ;

funciones: funcion funciones {fprintf(salida,";R:\tfunciones: funcion funciones\n");}
        | /*vacio*/  {fprintf(salida,";R:\tfunciones:\n");}
        ;
/*CAMBIARLO A " fn_declaration sentencias '}' "*/
funcion: TOK_FUNCTION modificadores_acceso tipo_retorno TOK_IDENTIFICADOR '(' parametros_funcion ')' '{' declaraciones_funcion sentencias'}'{
        fprintf(salida,";R:\tfuncion: TOK_FUNCTION modificadores_acceso tipo_retorno TOK_IDENTIFICADOR '(' parametro_funcion ')' declaraciones_funcion sentencia\n");}

        ;


tipo_retorno: TOK_NONE {fprintf(salida,";R:\ttipo_retorno: TOK_NONE\n");}
        | tipo {fprintf(salida,";R:\tipo_retorno: tipo\n");}
        | clase_objeto {fprintf(salida,";R:\tipo_retorno: clase_objeto\n");}
        ;

parametros_funcion: parametro_funcion resto_parametros_funcion {fprintf(salida,";R:\tparametros_funcion: parametro_funcion resto_parametros_funcion\n");}
        | /*vacio*/ {fprintf(salida,";R:\tparametros_funcion:\n");}
        ;

resto_parametros_funcion: ';' parametro_funcion resto_parametros_funcion {fprintf(salida,";R:\tresto_parametros_funcion: ; parametro_funcion resto_parametros_funcion\n");}
        | /*vacio*/ {fprintf(salida,";R:\tresto_parametros_funcion:\n");}
        ;

parametro_funcion: tipo TOK_IDENTIFICADOR {fprintf(salida,";R:\tparametro_funcion: tipo identificador\n");}
        | clase_objeto TOK_IDENTIFICADOR {fprintf(salida,";R:\tparametro_funcion: clase_objeto identificador\n");}
        ;

declaraciones_funcion: declaraciones {fprintf(salida,";R:\tdeclaraciones_funcion: declaraciones_funcion\n");}
        | /*vacio*/ {fprintf(salida,";R:\tdeclaraciones_funcion:\n");}
        ;

sentencias: sentencia {fprintf(salida,";R:\tsentencias: sentencia\n");}
        | sentencia sentencias {fprintf(salida,";R:\tsentencias: sentencia sentencias\n");}
        ;

sentencia: sentencia_simple ';'{fprintf(salida,";R:\tsentencia: sentencia_simple ';'\n");}
        | bloque {fprintf(salida,";R:\tsentencia: bloque\n");}
        ;

sentencia_simple: asignacion {fprintf(salida,";R:\tsentencia_simple: asignacion\n");}
        | lectura {fprintf(salida,";R:\tsentencia_simple: lectura\n");}
        | escritura {fprintf(salida,";R:\tsentencia_simple: escritura\n");}
        | retorno_funcion {fprintf(salida,";R:\tsentencia_simple: retorno_funcion\n");}
        | identificador_clase '.' TOK_IDENTIFICADOR '(' lista_expresiones ')' {fprintf(salida,";R:\tsentencia_simple: identificador_clase '.' TOK_IDENTIFICADOR '(' lista_expresiones ')'\n");}
        | TOK_IDENTIFICADOR '(' lista_expresiones ')' {fprintf(salida,";R:\tsentencia_simple: TOK_IDENTIFICADOR '(' lista_expresiones ')'\n");}
        | destruir_objeto {fprintf(salida,";R:\tsentencia_simple: destruir_objeto \n");}
        ;

destruir_objeto: TOK_DISCARD TOK_IDENTIFICADOR {fprintf(salida,";R:\tdestruir_objeto: TOK_DISCARD TOK_IDENTIFICADOR \n");}
        ;

bloque: condicional {
        fprintf(salida,";R:\tbloque: condicional\n");
      }
        | bucle{fprintf(salida,";R:\tbloque: bucle\n");}
        ;

asignacion: TOK_IDENTIFICADOR '=' exp {
                fprintf(salida,";R:\tasignacion: TOK_IDENTIFICADOR '=' exp\n");
                e = NULL;
                idAmbito[0] = '\0';
                if(buscarIdNoCualificado(NULL, tsa, $1.lexema, "main", &e, idAmbito) == ERROR){
                  printf("ERROR SEMANTICO: %d:%d No existe identificador %s\n", line, columna - yyleng, $1.lexema);
                  exit(-1);
                }

                if (e->tipo == $3.tipo){
                  asignar(salida, $1.lexema, $3.es_direccion);


                }else{
                  printf("ERROR SEMANTICO: %d:%d No se puede asignar dos objetos de diferentes tipos\n", line, columna - yyleng);
                  exit(-1);
                }

            }
        | elemento_vector '=' exp {
              fprintf(salida,";R:\tasignacion: elemento_vector '=' exp\n");
              e = NULL;
              idAmbito[0] = '\0';
              if(buscarIdNoCualificado(NULL, tsa, $1.lexema, "main", &e, idAmbito) == ERROR){
                printf("ERROR SEMANTICO: %d:%d No existe vector %s\n", line, columna - yyleng, $1.lexema);
                exit(-1);
              }
              fprintf(salida, "\tpop dword eax\n");
              if($3.es_direccion == 1)
                  fprintf(salida, "\tmov dword eax, [eax]\n");

              fprintf(salida, "\tpop dword edx\n");
              fprintf(salida, "\tmov dword[edx], eax\n");


            }
        | elemento_vector '=' TOK_INSTANCE_OF TOK_IDENTIFICADOR '(' lista_expresiones ')' {fprintf(salida,";R:\tasignacion: TOK_IDENTIFICADOR '=' TOK_INSTANCE_OF TOK_IDENTIFICADOR '(' lista_expresiones ')'\n");}
        | TOK_IDENTIFICADOR '=' TOK_INSTANCE_OF TOK_IDENTIFICADOR '(' lista_expresiones ')' {fprintf(salida,";R:\tTOK_IDENTIFICADOR '=' TOK_INSTANCE_OF TOK_IDENTIFICADOR '(' lista_expresiones ')'\n");}
        | identificador_clase '.' TOK_IDENTIFICADOR '=' exp {fprintf(salida,";R:\tasignacion: identificador_clase '.' TOK_IDENTIFICADOR '=' exp \n");}
        ;

elemento_vector: TOK_IDENTIFICADOR '[' exp ']' {
                fprintf(salida,";R:\telemento_vector: TOK_IDENTIFICADOR '[' exp ']'\n");
                if(buscarIdNoCualificado(NULL, tsa, $1.lexema, "main", &e, idAmbito) == OK){
                  if(e->clase == VECTOR){
                    if($3.tipo == ENTERO){
                      escribir_elemento_vector(salida, $1.lexema, tamanio_vector_actual, $3.es_direccion);


                      $$.tipo=e->tipo;
                      $$.es_direccion = 1;
                      strcpy($$.lexema,$1.lexema);
                    }
                    else{
                      printf("Error, el indice del vector no es un entero\n");
                      exit(-1);
                    }
                  }
                  else{
                    printf("Error, este id no es un vector\n");
                    exit(-1);
                  }
                }
                else{
                  printf("Error vector no declarado\n");
                  exit(-1);
                }
              }
        ;

condicional: if_exp sentencias '}' {
        fprintf(salida,";R:\tcondicional: TOK_IF '(' exp ')' '{' sentencias '}' \n");
        ifthen_fin(salida, $1.etiqueta);

        }
        |   if_exp_sentencias  TOK_ELSE '{' sentencias '}' {
          fprintf(salida,";R:\tcondicional: TOK_IF '(' exp ')' '{' sentencias '}' TOK_ELSE '{' sentencias '}' \n");
          ifthenelse_fin(salida, $1.etiqueta);

        }
        ;

if_exp : TOK_IF '(' exp ')' '{' {
    fprintf(salida,";R:\tif_exp: TOK_IF '(' exp \n");
    if($3.tipo != BOOLEANO){
      printf("ERROR SEMANTICO: %d:%d No se puede hacer if en distinto de boolean\n", line, columna - yyleng);
    }
    $$.etiqueta = etiqueta_global++;
    $$.es_direccion=$3.es_direccion;

    ifthen_inicio(salida, $3.es_direccion, $$.etiqueta);

};
if_exp_sentencias: if_exp sentencias '}'{
    $$.etiqueta = $1.etiqueta;
    $$.es_direccion = $1.es_direccion;

    ifthenelse_fin_then(salida, $1.etiqueta);
};

bucle: while_exp sentencias '}'{
      fprintf(salida,";R:\tbucle: TOK_WHILE exp '{' sentencias '}' \n");
      while_fin(salida, $1.etiqueta);
      $$.es_direccion = $1.es_direccion;
    }
    ;

while_exp: while exp ')' '{'{
      if($2.tipo != BOOLEANO){
        fprintf(stdout, "ERROR, WHILE distinto de BOOLEANOo\n" );
      }

      $$.es_direccion = $2.es_direccion;
      $$.etiqueta = $1.etiqueta;
      while_exp_pila(salida, $2.es_direccion, $$.etiqueta);
};

while: TOK_WHILE '('{
    $$.etiqueta = etiqueta_global++;
    while_inicio(salida, $$.etiqueta);
};

lectura: TOK_SCANF TOK_IDENTIFICADOR {
            fprintf(salida,";R:\tlectura: TOK_SCANF TOK_IDENTIFICADOR  \n");
            if(buscarIdNoCualificado(NULL, tsa, $2.lexema, "main", &e, idAmbito) == ERROR){
              printf("ERROR SEMANTICO: %d:%d - no se puede leer el identificador %s (no existe)\n", line, columna-yyleng, $2.lexema);
              exit(-1);
            }
            if(e->clase == VECTOR || e->categoria == FUNCION){
              printf("ERROR SEMANTICO: %d:%d - no se pueden leer funciones ni vectores\n", line, columna-yyleng);
              exit(-1);
            }


            if(e->tipo ==ENTERO)
              leer(salida, $2.lexema,ENTERO);
            else
              leer(salida, $2.lexema, BOOLEANO);


        }
        | TOK_SCANF elemento_vector {
              fprintf(salida,";R:\tlectura: TOK_SCANF elemento_vector \n");
              if(buscarIdNoCualificado(NULL, tsa, $2.lexema, "main", &e, idAmbito) == ERROR){
                printf("ERROR SEMANTICO: %d:%d - no se puede leer el identificador %s (no existe)\n", line, columna-yyleng, $2.lexema);
                exit(-1);
              }

              if(e->tipo ==ENTERO)
                leer_exp_pila(salida, $2.lexema,ENTERO);
              else
                leer_exp_pila(salida, $2.lexema, BOOLEANO);

            }
        ;

escritura: TOK_PRINTF exp  {
                fprintf(salida,";R:\tescritura: TOK_PRINTF exp\n");

                escribir(salida, $2.es_direccion, $2.tipo);
        }
        ;

retorno_funcion: TOK_RETURN exp {fprintf(salida,";R:\tretorno_funcion: TOK_RETURN exp\n");}
        | TOK_RETURN TOK_NONE {fprintf(salida,";R:\tretorno_funcion: TOK_RETURN TOK_NONE\n");}
        ;
exp:    exp '+' exp {

              fprintf(salida,";R:\texp: exp '+' exp \n");
              if($1.tipo !=ENTERO|| $3.tipo!=ENTERO){
                fprintf(stdout, "ERROR, no se pueden sumar cosas diferentes a enteros\n" );
                exit(-1);
              }

              sumar(salida,$1.es_direccion,$3.es_direccion);
              $$.es_direccion=0;
              $$.tipo = $1.tipo;
            }
        | exp '-' exp {
              fprintf(salida,";R:\texp: exp '-' exp \n");
              if($1.tipo !=ENTERO|| $3.tipo!=ENTERO){
                fprintf(stdout, "ERROR, no se pueden restar cosas diferentes aENTEROs\n" );
                exit(-1);
              }

                restar(salida,$1.es_direccion,$3.es_direccion);
                $$.tipo = $1.tipo;
                $$.es_direccion=0;

            }
        | exp '/' exp {
              fprintf(salida,";R:\texp: exp '/' exp \n");
              if($1.tipo !=ENTERO|| $3.tipo!=ENTERO){
                fprintf(stdout, "ERROR, no se pueden dividir cosas diferentes a enteros\n" );
                exit(-1);
              }
              dividir(salida,$1.es_direccion,$3.es_direccion);
              $$.tipo = $1.tipo;
              $$.es_direccion=0;
            }
        | exp '*' exp  {
              fprintf(salida,";R:\texp: exp '*' exp \n");
              if($1.tipo !=ENTERO|| $3.tipo!=ENTERO){
                fprintf(stdout, "ERROR, no se pueden multiplicar cosas diferentes a enteros\n" );
                exit(-1);
              }

                multiplicar(salida,$1.es_direccion,$3.es_direccion);
                $$.tipo = $1.tipo;
                $$.es_direccion=0;
            }

        | '-' exp %prec NEG  {
              fprintf(salida,";R:\texp: '-' exp \n");
              if($2.tipo !=ENTERO){
                fprintf(stdout, "ERROR, no se pueden cambiar_signo cosas diferentes a enteros\n" );
                exit(-1);
              }
              cambiar_signo(salida, $2.es_direccion);
              $$.tipo = $2.tipo;
              $$.es_direccion=0;

            }

        | exp TOK_AND exp  {
              fprintf(salida,";R:\texp: exp TOK_AND exp  \n");
              if($1.tipo != BOOLEANO || $3.tipo!= BOOLEANO ){
                fprintf(stdout, "ERROR, no se puede hacer AND entre cosas diferentes a booleanos\n" );
                exit(-1);
              }

              y(salida,$1.es_direccion,$3.es_direccion);
              $$.tipo = $1.tipo;
              $$.es_direccion=0;

            }
        | exp TOK_OR exp  {
              fprintf(salida,";R:\texp: exp TOK_OR exp \n");

              if($1.tipo != BOOLEANO || $3.tipo!= BOOLEANO ){
                fprintf(stdout, "ERROR, no se puede hacer OR entre cosas diferentes a booleanos\n" );
                exit(-1);
              }

              o(salida,$1.es_direccion,$3.es_direccion);
              $$.tipo = $1.tipo;
              $$.es_direccion=0;


            }
        | '!' exp {
              fprintf(salida,";R:\texp:'!' exp\n");

              if($2.tipo != BOOLEANO){
                fprintf(stdout, "ERROR, no se puede hacer NO en cosas diferentes a booleanos\n" );
                exit(-1);
              }
              $$.es_direccion=0;
              $$.tipo = $2.tipo;
              no(salida,$2.es_direccion,etiqueta_global++);


              }
        | TOK_IDENTIFICADOR/* cambiar "identificador" por "idf_llamada_funcion"*/ {
          fprintf(salida,";R:\texp: TOK_IDENTIFICADOR\n");
          if(buscarIdNoCualificado(NULL, tsa, $1.lexema, "main", &e, idAmbito) == OK){
              escribir_operando(salida, $1.lexema, 1);
              $$.tipo = e->tipo;
              $$.es_direccion = 1;
              strcpy($$.lexema, $1.lexema);

          }
          else{
              printf("ERROR SEMANTICO: %d:%d - Identificador %s no declarado\n", line, columna-yyleng, $1.lexema);
              exit(-1);
          }
        }
        | constante  {
                fprintf(salida,";R:\texp: constante \n");

                $$.tipo = $1.tipo;
                $$.es_direccion = $1.es_direccion;
        }
        | '(' exp ')'  {
          fprintf(salida,";R:\texp:'(' exp ')' \n");
          $$.es_direccion=$2.es_direccion;
          $$.tipo=$2.tipo;
        }
        | '(' comparacion ')'  {
            fprintf(salida,";R:\texp:'(' comparacion ')' \n");
            $$.tipo = $2.tipo;
            $$.es_direccion = $2.es_direccion;
          }
        | elemento_vector  {fprintf(salida,";R:\texp: elemento_vector");}
        | TOK_IDENTIFICADOR '(' lista_expresiones ')' {fprintf(salida,";R:\texp: TOK_IDENTIFICADOR '(' lista_expresiones ')' \n");}
        | identificador_clase TOK_IDENTIFICADOR '(' lista_expresiones ')' {fprintf(salida,";R:\texp: identificador_clase TOK_IDENTIFICADOR '(' lista_expresiones ')' \n");}
        | identificador_clase TOK_IDENTIFICADOR  {fprintf(salida,";R:\texp: identificador_clase TOK_IDENTIFICADOR \n");}
        ;



identificador_clase: TOK_IDENTIFICADOR {fprintf(salida,";R:\tidentificador_clase: TOK_IDENTIFICADOR \n");}
        | TOK_ITSELF {fprintf(salida,";R:\tidentificador_clase: TOK_ITSELF \n");}
        ;

lista_expresiones: exp resto_lista_expresiones  {fprintf(salida,";R:\tlista_expresiones: exp resto_lista_expresiones\n");}
        | /*vacio*/ {fprintf(salida,";R:\tlista_expresiones:\n");}
        ;

resto_lista_expresiones: ',' exp resto_lista_expresiones {fprintf(salida,";R:\tlista_expresiones: ',' exp resto_lista_expresiones\n");}
        | /*vacio*/{fprintf(salida,";R:\tresto_lista_expresiones:\n");}
        ;

comparacion: exp TOK_IGUAL exp {
              fprintf(salida,";R:\tcomparacion: exp TOK_IGUAL exp \n");

              if($1.tipo == $3.tipo){

                igual(salida, $1.es_direccion,$3.es_direccion, etiqueta_global++);
                $$.tipo = BOOLEANO;
                $$.es_direccion = 0;
              }
              else{
                printf("ERROR SEMANTICO: %d:%d - No se puede hacer la comparacion == entre objetos de diferentes tipos\n",line, columna-yyleng);
                exit(-1);
              }
        }
        | exp TOK_DISTINTO exp {
              fprintf(salida,";R:\tcomparacion: exp TOK_DISTINTO exp \n");
              if($1.tipo == $3.tipo){

                distinto(salida, $1.es_direccion,$3.es_direccion, etiqueta_global++);
                $$.tipo = BOOLEANO;
                $$.es_direccion = 0;
              }

              else{
                printf("ERROR SEMANTICO: %d:%d - No se puede hacer la comparacion != entre objetos de diferentes tipos\n",line, columna-yyleng);
                exit(-1);
              }
            }
        | exp TOK_MENORIGUAL exp {
              fprintf(salida,";R:\tcomparacion: exp TOK_MENORIGUAL exp \n");

              if($1.tipo == $3.tipo && $1.tipo==ENTERO){

                menor_igual(salida, $1.es_direccion,$3.es_direccion, etiqueta_global++);
                $$.tipo = BOOLEANO;
                $$.es_direccion = 0;
              }
              else{
                printf("ERROR SEMANTICO: %d:%d - No se puede hacer la comparacion <= entre objetos no enteros\n",line, columna-yyleng);
                exit(-1);
              }
            }
        | exp TOK_MAYORIGUAL exp{
              fprintf(salida,";R:\tcomparacion: exp TOK_MAYORIGUAL exp \n");

              if($1.tipo == $3.tipo && $1.tipo==ENTERO){

                mayor_igual(salida, $1.es_direccion,$3.es_direccion, etiqueta_global++);
                $$.tipo = BOOLEANO;
                $$.es_direccion = 0;
              }
              else{
                printf("ERROR SEMANTICO: %d:%d - No se puede hacer la comparacion >= entre objetos no enteros\n",line, columna-yyleng);
                exit(-1);
              }
            }
        | exp '<' exp {
              fprintf(salida,";R:\tcomparacion: exp < exp \n");

              if($1.tipo == $3.tipo && $1.tipo==ENTERO){

                menor(salida, $1.es_direccion,$3.es_direccion, etiqueta_global++);
                $$.tipo = BOOLEANO;
                $$.es_direccion = 0;
              }
              else{
                printf("ERROR SEMANTICO: %d:%d - No se puede hacer la comparacion < entre objetos no enteros\n",line, columna-yyleng);
                exit(-1);
              }
            }
        | exp '>' exp {
              fprintf(salida,";R:\tcomparacion: exp > exp \n");

              if($1.tipo == $3.tipo && $1.tipo==ENTERO){

                mayor(salida, $1.es_direccion,$3.es_direccion, etiqueta_global++);
                $$.tipo = BOOLEANO;
                $$.es_direccion = 0;
              }
              else{
                printf("ERROR SEMANTICO: %d:%d - No se puede hacer la comparacion > entre objetos no enteros\n",line, columna-yyleng);
                exit(-1);
              }
            }
        ;

constante: constante_logica {fprintf(salida,";R:\tconstante: constante_logica\n");
                $$.tipo = $1.tipo;
                $$.es_direccion = $1.es_direccion;
        }
        | constante_entera  {fprintf(salida,";R:\tconstante: constante_entera\n");
                $$.tipo = $1.tipo;
                $$.es_direccion = $1.es_direccion;
        }
        ;
constante_logica: TOK_TRUE {fprintf(salida,";R:\tconstante_logica: TOK_TRUE\n");
                    char valor[]={"1"};
                    $$.tipo = BOOLEANO;
                    $$.es_direccion = 0;
                    $$.valor_entero = 1;
                    escribir_operando(salida, valor, 0);

        }
        | TOK_FALSE {fprintf(salida,";R:\tconstante_logica: TOK_FALSE\n");
                    char valor[]={"0"};
                    $$.tipo = BOOLEANO;
                    $$.es_direccion = 0;
                    $$.valor_entero = 0;
                    escribir_operando(salida, valor, 0);

        }
        ;
constante_entera: TOK_CONSTANTE_ENTERA {
                fprintf(salida,";R:\tconstante_entera: TOK_CONSTANTE_ENTERA\n");
                $$.tipo =ENTERO;
                $$.es_direccion = 0;
                char valor[20];
                sprintf(valor, "%d", $1.valor_entero);
                escribir_operando(salida, valor, 0);
        }
        ;


identificador: TOK_IDENTIFICADOR
        {
                fprintf(salida, ";R:\tidentificador: TOK_IDENTIFICADOR");
                $1.tipo=tipo_actual;

                if(clase_actual == VECTOR){
                  tamanio_actual=tamanio_vector_actual;
                }

                else{
                  tamanio_actual=1;
                }

                elementoTablaSimbolos *elemento = nodo_crearElementoTablaSimbolos();
                elemento = nodo_set_ElementoTablaSimbolos(elemento,
                                          $1.lexema,
                													clase_actual,
                													VARIABLE,
                													$1.tipo,
                													0,
                													0,
                													0,
                													0,
                													0,
                													0,
                													0,
                													tamanio_actual,
                													0,
                													0,
                													0,
                													0,
                													0,
                													0,
                													0,
                													0,
                													0,
                													0,
                													0,
                													0,
                													0,
                								        	0,
                								        	0,
                													NULL);

                if(buscarParaDeclararIdTablaSimbolosAmbitos(tsa, $1.lexema, &e, idAmbito)==ERROR){
                  if($1.tipo == BOOLEANO || $1.tipo ==ENTERO){
                    if(insertarTablaSimbolosAmbitos(tsa, $1.lexema,  elemento) == ERROR){
                      nodo_free_ElementoTablaSimbolos(elemento);
                      printf("ERROR SEMANTICO: %d:%d - Identificador %s duplicado\n",line, columna-yyleng, $1.lexema);
                      exit(-1);
                    }

                  }

                }
                else{
                  nodo_free_ElementoTablaSimbolos(elemento);
                  nodo_free_ElementoTablaSimbolos(e);
                  printf("ERROR SEMANTICO: %d:%d - Identificador %s duplicado\n",line, columna-yyleng, $1.lexema);
                  exit(-1);
                }

              nodo_free_ElementoTablaSimbolos(elemento);

        }
        ;


%%


void yyerror(char * s)
{
  if(yychar != TOK_ERROR)
    printf("ERROR SINTACTICO: %d:%d\n",line, columna-yyleng);
    escribir_fin(salida);

}
