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

  int pos_var_local_actual=1, num_params_actual, pos_params_actual, num_var_local,num_vars_boolean_actual;
  int fn_return=0;
  int en_exp_list = 0;

  char idAmbito[64];
  elementoTablaSimbolos * e = NULL;

  typedef struct{
    char nombre[MAX_ID+1];
    int tipo;
    int clase;
    int es_variable;
    int posicion;
  }parametros;

  parametros array_param[64];

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
  %type <atributos> idf_llamada
  %type <atributos> tipo
  %type <atributos> fn_declaration
  %type <atributos> fn_complete_name
  %type <atributos> fn_name
  %type <atributos> tipo_retorno
  %type <atributos> parametro_funcion
  %type <atributos> idpf


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
          char clave[64];
          int i;
          th = tsa->global;
          for(i=0; i<th->nElem; i++){

            strcpy(clave, th->lista[i]);
            n = buscarNodoHash(th, clave);
            if(n == NULL){
              printf("El nodo ha develto NULL\n");
              exit(-1);
            }
            e = nodo_get_ElementoTablaSimbolos(n);
            if(e == NULL){
              printf("El elemento ha develto NULL\n");
              exit(-1);
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

tipo: TOK_INT {fprintf(salida,";R:\ttipo: TOK_INT\n"); tipo_actual =ENTERO;$$.tipo=tipo_actual;}
        | TOK_BOOLEAN {fprintf(salida,";R:\ttipo: TOK_BOOLEAN\n"); tipo_actual = BOOLEANO; $$.tipo=tipo_actual;} /*REVISAR NO SE QUE VALOR ES BOOLEAN*/
        ;

clase_objeto: '{' TOK_IDENTIFICADOR '}' {fprintf(salida,";R:\tclase_objeto: '{' TOK_IDENTIFICADOR '}'\n");}
        ;

clase_vector: TOK_ARRAY tipo '['TOK_CONSTANTE_ENTERA']' {
              fprintf(salida,";R:\tclase_vector: TOK_ARRAY tipo '[' TOK_CONSTANTE_ENTERA ']'\n");
              tamanio_vector_actual = $4.valor_entero;
              clase_actual = VECTOR;
              if ((tamanio_vector_actual <1) || (tamanio_vector_actual > 64)){
                printf("****ERROR SEMANTICO: %d:%d - El tamaño del vector excede los limites permitidos(1,64)\n",line, columna-yyleng);
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
funcion: fn_declaration sentencias'}'{
        fprintf(salida,";R:\tfuncion: TOK_FUNCTION modificadores_acceso tipo_retorno TOK_IDENTIFICADOR '(' parametro_funcion ')' declaraciones_funcion sentencia\n");
        if(fn_return < 1){
          printf("****ERROR SEMANTICO: %d:%d - Funcion sin sentencia de retorno\n",line, columna-yyleng);
          fn_return = 0;
          //exit(-1);

        }
        cerrarAmbitoMain(tsa);

      }

        ;

fn_declaration: fn_complete_name '{' declaraciones_funcion {
        declararFuncion(salida, $1.lexema, num_var_local );
        //acceder a la funcion global -> rellenar el numero de variables locales

};

fn_complete_name: fn_name '(' parametros_funcion ')'{

        char nombre[64];
        sprintf(nombre, "main_%s",$1.lexema);
        int i;
        for(i = 0; i < num_params_actual; i++){
          if(array_param[i].tipo == ENTERO)
            strcat(nombre, "@1");
          else
            strcat(nombre, "@3");
        }

        if(buscarParaDeclararIdTablaSimbolosAmbitos(tsa, nombre, &e, idAmbito)==ERROR){

           elementoTablaSimbolos *elemento = nodo_crearElementoTablaSimbolos();

          if(abrirAmbitoMain(tsa, nombre, FUNCION, $1.tipo) == ERROR){

            printf("Error abrir ambito local\n");
            exit(-1);
          }

        
          elemento = nodo_crearElementoTablaSimbolos();
          for(i = 0; i < num_params_actual; i++){
            if(buscarParaDeclararIdTablaSimbolosAmbitos(tsa, array_param[i].nombre, &e, idAmbito)==ERROR){

              if(array_param[i].tipo == BOOLEANO || array_param[i].tipo ==ENTERO){
                elemento = nodo_set_ElementoTablaSimbolos(elemento,
                                          array_param[i].nombre,
                                          array_param[i].clase,
                                          PARAMETRO,
                                          array_param[i].tipo,
                                          0,
                                          0,
                                          num_params_actual,
                                          0,
                                          0,
                                          array_param[i].posicion,
                                          0,
                                          1,
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

                if(insertarTablaSimbolosAmbitos(tsa, array_param[i].nombre,  elemento) == ERROR){
                  printf("****ERROR SEMANTICO: %d:%d - Declaracion de parametro %s duplicada\n",line, columna-yyleng, array_param[i].nombre);
                  nodo_free_ElementoTablaSimbolos(elemento);
                  exit(-1);
                }

            }
            else{
              printf("PArametro no es int ni boolean\n");
              exit(-1);
            }
        }
        else{
          printf("****ERROR SEMANTICO: %d:%d - Declaracion de parametro %s duplicado\n",line, columna-yyleng, array_param[i].nombre);
          exit(-1);
        }

    }
    nodo_free_ElementoTablaSimbolos(elemento);
    strcpy($$.lexema, $1.lexema);
    $$.tipo=$1.tipo;

  }
  else{
    printf("****ERROR SEMANTICO: %d:%d - Declaracion de funcion %s duplicada\n",line, columna-yyleng, array_param[i].nombre);
    exit(-1);
  }
};

fn_name: TOK_FUNCTION modificadores_acceso tipo_retorno TOK_IDENTIFICADOR{

        num_vars_boolean_actual = 0;
        pos_var_local_actual = 1;
        num_params_actual = 0;
        pos_params_actual = 0;
        strcpy($$.lexema, $4.lexema);
        $$.tipo= $3.tipo;

};


tipo_retorno: TOK_NONE {fprintf(salida,";R:\ttipo_retorno: TOK_NONE\n");}
        | tipo {fprintf(salida,";R:\ttipo_retorno: tipo\n");}
        | clase_objeto {fprintf(salida,";R:\ttipo_retorno: clase_objeto\n");}
        ;

parametros_funcion: parametro_funcion resto_parametros_funcion {fprintf(salida,";R:\tparametros_funcion: parametro_funcion resto_parametros_funcion\n");}
        | /*vacio*/ {fprintf(salida,";R:\tparametros_funcion:\n");}
        ;

resto_parametros_funcion: ';' parametro_funcion resto_parametros_funcion {fprintf(salida,";R:\tresto_parametros_funcion: ; parametro_funcion resto_parametros_funcion\n");}
        | /*vacio*/ {fprintf(salida,";R:\tresto_parametros_funcion:\n");}
        ;

parametro_funcion: tipo idpf {
          fprintf(salida,";R:\tparametro_funcion: tipo identificador\n");
          strcpy(array_param[pos_params_actual].nombre, $2.lexema);
          array_param[pos_params_actual].tipo = tipo_actual;
          array_param[pos_params_actual].clase = clase_actual;
          array_param[pos_params_actual].posicion = pos_params_actual;
          pos_params_actual++;
          num_params_actual++;

      }
        | clase_objeto TOK_IDENTIFICADOR {fprintf(salida,";R:\tparametro_funcion: clase_objeto identificador\n");}
        ;

idpf: TOK_IDENTIFICADOR {
    strcpy($$.lexema, $1.lexema);

    // if(buscarParaDeclararIdTablaSimbolosAmbitos(tsa, $1.lexema, &e, idAmbito)==ERROR){
    //     elementoTablaSimbolos *elemento = nodo_crearElementoTablaSimbolos();
    //     elemento = nodo_set_ElementoTablaSimbolos(elemento,
    //                               $1.lexema,
    //                               clase_actual,
    //                               PARAMETRO,
    //                               $1.tipo,
    //                               0,
    //                               0,
    //                               0,
    //                               0,
    //                               0,
    //                               pos_params_actual,
    //                               0,
    //                               1,
    //                               0,
    //                               0,
    //                               0,
    //                               0,
    //                               0,
    //                               0,
    //                               0,
    //                               0,
    //                               0,
    //                               0,
    //                               0,
    //                               0,
    //                               0,
    //                               0,
    //                               0,
    //                               NULL);
    //     if(insertarTablaSimbolosAmbitos(tsa, $1.lexema,  elemento) == ERROR){
    //       printf("****ERROR SEMANTICO: %d:%d - Declaracion de variable %s duplicado\n",line, columna-yyleng, $1.lexema);
    //       nodo_free_ElementoTablaSimbolos(elemento);
    //       exit(-1);
    //     }

    // }
    // else{
    //   printf("****ERROR SEMANTICO: %d:%d - Declaracion de variable %s duplicado\n",line, columna-yyleng, $1.lexema);
    //   exit(-1);
    // }

};

declaraciones_funcion: declaraciones {fprintf(salida,";R:\tdeclaraciones_funcion: declaracion\n");}
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
                fprintf(salida,";R:\tLEXEMA1 : %s, LEXEMA2: %s\n", $1.lexema, $3.lexema);
                e = NULL;
                idAmbito[0] = '\0';
                /*Revisar*/
                if(buscarIdNoCualificado(NULL, tsa, $1.lexema, "main", &e, idAmbito) == ERROR){
                  printf("***ERROR SEMANTICO: %d:%d Acceso a variable %s no declarada\n", line, columna - yyleng, $1.lexema);
                  exit(-1);
                }

                if (e->tipo == $3.tipo){
                  if(strcmp(idAmbito, "main") != 0){
                        if(e->categoria == PARAMETRO){
                          fprintf(salida, "\tlea  eax, [ebp+4+( 4 * (%d) )]\n", num_params_actual - e->posicion_parametro);
                          fprintf(salida, "\tpush dword eax\n");

                        } else if( e->categoria == VARIABLE){
                          fprintf(salida, "\tlea  eax, [ebp - 4 * %d ]\n",e->posicion_variable_local);
                          fprintf(salida, "\tpush dword eax\n");
                        }


                        fprintf(salida, "\tpop dword eax\n");
                        fprintf(salida, "\tpop dword ebx\n");

                        if( $3.es_direccion == 1){
                          fprintf(salida, "\tmov ebx, [ebx]\n");
                        }
                        fprintf(salida, "\tmov [eax], ebx\n");

                  }else{
                      asignar(salida, $1.lexema, $3.es_direccion);
                  }


                }else{
                  printf("****ERROR SEMANTICO: %d:%d Asignacion incompatible\n", line, columna - yyleng);
                  exit(-1);
                }

            }
        | elemento_vector '=' exp {
              fprintf(salida,";R:\tasignacion: elemento_vector '=' exp\n");
              e = NULL;
              idAmbito[0] = '\0';
              if(buscarIdNoCualificado(NULL, tsa, $1.lexema, "main", &e, idAmbito) == ERROR){
                printf("***ERROR SEMANTICO: %d:%d Acceso a vector %s no declarado\n", line, columna - yyleng, $1.lexema);
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
                      printf("****ERROR SEMANTICO: %d:%d El indice en una operacion de indexacion tiene que ser de tipo entero\n", line, columna - yyleng);
                      exit(-1);
                    }
                  }
                  else{
                    printf("****ERROR SEMANTICO: %d:%d Intento de indexacion de una variable que no es de tipo vector\n", line, columna - yyleng);
                    exit(-1);
                  }
                }
                else{
                  printf("****ERROR SEMANTICO: %d:%d Acceso a vector %s no declarado\n", line, columna - yyleng, $1.lexema);
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
      printf("****ERROR SEMANTICO: %d:%d Condicional con condicion de tipo int\n", line, columna - yyleng);
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
        printf("****ERROR SEMANTICO: %d:%d Bucle con condicion de tipo int\n", line, columna - yyleng);
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
              printf("****ERROR SEMANTICO: %d:%d - Acceso a variable %s no declarada\n", line, columna - yyleng, $2.lexema);
              exit(-1);
            }
            if(e->clase == VECTOR || e->categoria == FUNCION){
              printf("***ERROR SEMANTICO: %d:%d - No se pueden leer funciones ni vectores (de esta manera)\n", line, columna-yyleng);
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
                printf("****ERROR SEMANTICO: %d:%d - Acceso a vector %s no declarado\n", line, columna - yyleng, $2.lexema);
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

retorno_funcion: TOK_RETURN exp {
                fprintf(salida,";R:\tretorno_funcion: TOK_RETURN exp\n");
                retornarFuncion(salida,$2.es_direccion); /*Revisar*/
                fn_return++;
              }
        | TOK_RETURN TOK_NONE {fprintf(salida,";R:\tretorno_funcion: TOK_RETURN TOK_NONE\n");}
        ;
exp:    exp '+' exp {

              fprintf(salida,";R:\texp: exp '+' exp \n");
              if($1.tipo !=ENTERO|| $3.tipo!=ENTERO){
                printf("****ERROR SEMANTICO: %d:%d - Operacion aritmetica con operandos boolean\n", line, columna - yyleng);
                exit(-1);
              }

              sumar(salida,$1.es_direccion,$3.es_direccion);
              $$.es_direccion=0;
              $$.tipo = $1.tipo;
            }
        | exp '-' exp {
              fprintf(salida,";R:\texp: exp '-' exp \n");
              if($1.tipo !=ENTERO|| $3.tipo!=ENTERO){
                printf("****ERROR SEMANTICO: %d:%d - Operacion aritmetica con operandos boolean\n", line, columna - yyleng);
                exit(-1);
              }

                restar(salida,$1.es_direccion,$3.es_direccion);
                $$.tipo = $1.tipo;
                $$.es_direccion=0;

            }
        | exp '/' exp {
              fprintf(salida,";R:\texp: exp '/' exp \n");
              if($1.tipo !=ENTERO|| $3.tipo!=ENTERO){
                printf("****ERROR SEMANTICO: %d:%d - Operacion aritmetica con operandos boolean\n", line, columna - yyleng);
                exit(-1);
              }
              dividir(salida,$1.es_direccion,$3.es_direccion);
              $$.tipo = $1.tipo;
              $$.es_direccion=0;
            }
        | exp '*' exp  {
              fprintf(salida,";R:\texp: exp '*' exp \n");
              if($1.tipo !=ENTERO|| $3.tipo!=ENTERO){
                printf("****ERROR SEMANTICO: %d:%d - Operacion aritmetica con operandos boolean\n", line, columna - yyleng);
                exit(-1);
              }

                multiplicar(salida,$1.es_direccion,$3.es_direccion);
                $$.tipo = $1.tipo;
                $$.es_direccion=0;
            }

        | '-' exp %prec NEG  {
              fprintf(salida,";R:\texp: '-' exp \n");
              if($2.tipo !=ENTERO){
                printf("****ERROR SEMANTICO: %d:%d - Operacion aritmetica con operandos boolean\n", line, columna - yyleng);
                exit(-1);
              }
              cambiar_signo(salida, $2.es_direccion);
              $$.tipo = $2.tipo;
              $$.es_direccion=0;

            }

        | exp TOK_AND exp  {
              fprintf(salida,";R:\texp: exp TOK_AND exp  \n");
              if($1.tipo != BOOLEANO || $3.tipo!= BOOLEANO ){
                printf("****ERROR SEMANTICO: %d:%d - Operacion logica con operandos int\n", line, columna - yyleng);
                exit(-1);
              }

              y(salida,$1.es_direccion,$3.es_direccion);
              $$.tipo = $1.tipo;
              $$.es_direccion=0;

            }
        | exp TOK_OR exp  {
              fprintf(salida,";R:\texp: exp TOK_OR exp \n");

              if($1.tipo != BOOLEANO || $3.tipo!= BOOLEANO ){
                printf("****ERROR SEMANTICO: %d:%d - Operacion logica con operandos int\n", line, columna - yyleng);
                exit(-1);
              }

              o(salida,$1.es_direccion,$3.es_direccion);
              $$.tipo = $1.tipo;
              $$.es_direccion=0;


            }
        | '!' exp {
              fprintf(salida,";R:\texp:'!' exp\n");

              if($2.tipo != BOOLEANO){
                printf("****ERROR SEMANTICO: %d:%d - Operacion logica con operandos int\n", line, columna - yyleng);
                exit(-1);
              }
              $$.es_direccion=0;
              $$.tipo = $2.tipo;
              no(salida,$2.es_direccion,etiqueta_global++);


              }
        | TOK_IDENTIFICADOR/* cambiar "identificador" por "idf_llamada_funcion"*/ {
          fprintf(salida,";R:\texp: TOK_IDENTIFICADOR\n");
          fprintf(salida, ";Identificaodr: %s\n", $1.lexema);
          if(buscarIdNoCualificado(NULL, tsa, $1.lexema, "main", &e, idAmbito) == OK){
                if(strcmp(idAmbito,"main")==0){
                  if(en_exp_list == 1){
                    fprintf(salida, "\tpush dword [_%s]\n", $1.lexema);
                  }
                  else{
                    escribir_operando(salida, $1.lexema, 1);
                  }


                }
                else{

                  if(e->categoria == PARAMETRO){
                    fprintf(salida, ";exp2 es param: %s\n", e->clave);
                    fprintf(salida, "\tlea  eax, [ebp+4+( 4 * %d )]\n", e->numero_parametros - e->posicion_parametro);

                    fprintf(salida, "\tpush dword eax\n");

                  } else if( e->categoria == VARIABLE){
                    fprintf(salida, "\tlea  eax, [ebp - 4 * %d ]\n",e->posicion_variable_local);

                    fprintf(salida, "\tpush dword eax\n");

                  }

              }


              $$.tipo = e->tipo;
              $$.es_direccion = 1;
              strcpy($$.lexema, $1.lexema);

          }
          else{
            printf("SE METE AQUI\n");
            printf("****ERROR SEMANTICO: %d:%d - Acceso a variable %s no declarada\n", line, columna - yyleng, $1.lexema);
              exit(-1);
          }
        }
        | constante  {
                fprintf(salida,";R:\texp: constante \n");

                $$.tipo = $1.tipo;
                $$.es_direccion = 0;
                $$.valor_entero = $1.valor_entero;
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
            strcpy($$.lexema, $2.lexema);
          }
        | elemento_vector  {fprintf(salida,";R:\texp: elemento_vector");}
        | idf_llamada '(' lista_expresiones ')' {
          //numero parametros formales = actuales??s
            char nombre[64];

            sprintf(nombre, "main_%s",$1.lexema);
            int i;
            for(i = 0; i < num_params_actual; i++){
              if(array_param[i].tipo == ENTERO)
                strcat(nombre, "@1");
              else
                strcat(nombre, "@3");
            }

            if(buscarParaDeclararIdTablaSimbolosAmbitos(tsa, nombre, &e, idAmbito)==ERROR)
            {
              printf("****ERROR SEMANTICO: %d:%d - Acceso a funcion %s no declarada\n", line, columna - yyleng, nombre);
              exit(-1);
            }

            if(e->categoria != FUNCION){
              printf("Llamando a la funcion la busqueda a devuelto un elemento que no es una funcion: %s\n", $1.lexema );
              exit(-1);
            }
            fprintf(salida,";R:\texp: idpf '(' lista_expresiones ')' \n");

            llamarFuncion(salida, $1.lexema, num_params_actual);



            en_exp_list = 0;

            $$.tipo = e->tipo;
            $$.es_direccion = 0;

          }
        | identificador_clase TOK_IDENTIFICADOR '(' lista_expresiones ')' {fprintf(salida,";R:\texp: identificador_clase TOK_IDENTIFICADOR '(' lista_expresiones ')' \n");}
        | identificador_clase TOK_IDENTIFICADOR  {fprintf(salida,";R:\texp: identificador_clase TOK_IDENTIFICADOR \n");}
        ;

idf_llamada: TOK_IDENTIFICADOR{


         if(en_exp_list == 1){
           printf("ERROR idf_llamada\n");
           exit(-1);
         }
         strcpy($$.lexema ,$1.lexema);
         num_params_actual = 0;
         en_exp_list = 1;
         $$.tipo = $1.tipo;
         $$.es_direccion=0;

}
;


identificador_clase: TOK_IDENTIFICADOR {fprintf(salida,";R:\tidentificador_clase: TOK_IDENTIFICADOR \n");}
        | TOK_ITSELF {fprintf(salida,";R:\tidentificador_clase: TOK_ITSELF \n");}
        ;

lista_expresiones: exp resto_lista_expresiones  {
          fprintf(salida,";R:\tlista_expresiones: exp resto_lista_expresiones\n");
          // fprintf(salida, "\tpush dword %d\n", $1.valor_entero);
          array_param[pos_params_actual].tipo = $1.tipo;
          strcpy(array_param[pos_params_actual].nombre, $1.lexema);
          array_param[pos_params_actual].es_variable = $1.es_direccion;
          array_param[pos_params_actual].posicion = pos_params_actual;
          num_params_actual++;
          pos_params_actual++;

        }
        | /*vacio*/ {fprintf(salida,";R:\tlista_expresiones:\n");}
        ;


resto_lista_expresiones: ',' exp resto_lista_expresiones {
          fprintf(salida,";R:\tresto_expresiones: ',' exp resto_lista_expresiones\n");
          // if($2.es_direccion == 1){
          //     fprintf(salida, "\tpush dword _%s\n", $2.lexema);
          // }else{
          //   fprintf(salida, "\tpush dword %s\n", $2.lexema);
          //
          // }
          array_param[pos_params_actual].tipo = $2.tipo;
          strcpy(array_param[pos_params_actual].nombre, $2.lexema);
          num_params_actual++;
          pos_params_actual++;
        }
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
                printf("****ERROR SEMANTICO: %d:%d - Comparacion con operandos boolean\n",line, columna-yyleng);
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
                printf("****ERROR SEMANTICO: %d:%d - Comparacion con operandos boolean\n",line, columna-yyleng);
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
                printf("****ERROR SEMANTICO: %d:%d - Comparacion con operandos boolean\n",line, columna-yyleng);
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
                printf("****ERROR SEMANTICO: %d:%d - Comparacion con operandos boolean\n",line, columna-yyleng);
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
                printf("****ERROR SEMANTICO: %d:%d - Comparacion con operandos boolean\n",line, columna-yyleng);
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
                printf("****ERROR SEMANTICO: %d:%d - Comparacion con operandos boolean\n",line, columna-yyleng);
                exit(-1);
              }
            }
        ;

constante: constante_logica {fprintf(salida,";R:\tconstante: constante_logica\n");
                $$.tipo = $1.tipo;
                $$.es_direccion = $1.es_direccion;
                $$.valor_entero = $1.valor_entero;
        }
        | constante_entera  {fprintf(salida,";R:\tconstante: constante_entera\n");
                $$.tipo = $1.tipo;
                $$.es_direccion = $1.es_direccion;
                $$.valor_entero = $1.valor_entero;
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
                													num_params_actual,
                													num_var_local,
                													pos_var_local_actual,
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
                      printf("****ERROR SEMANTICO: %d:%d - Declaracion de variable %s duplicado\n",line, columna-yyleng, $1.lexema);
                      exit(-1);
                    }

                  }

                }
                else{
                  nodo_free_ElementoTablaSimbolos(elemento);
                  nodo_free_ElementoTablaSimbolos(e);
                  printf("****ERROR SEMANTICO: %d:%d - Declaracion de variable %s duplicado\n",line, columna-yyleng, $1.lexema);
                  exit(-1);
                }
                if(strcmp(idAmbito,"main")!=0 ){
                  num_var_local++;
                  pos_var_local_actual++;
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
