#include "estructuras.h"

/*---------------------------------------*/
/*-----------TABLA DE SIMBOLOS-----------*/
/*---------------------------------------*/


/******************************************/
/*Funciones de gestion de tablas y ambitos*/
/******************************************/

/**
* iniciarTablaSimbolosClases
*
* Reserva todos los recursos para crear una tabla de símbolos
* basada en un grafo e identificada con el nombre proporcionado como argumento
**/
tablaSimbolosClases *iniciarTablaSimbolosClases(char * nombre){
  tablaSimbolosClases *t;

  if (!nombre){
    return NULL;
  }
  t = (tablaSimbolosClases*)malloc(sizeof(tablaSimbolosClases)*MAX_TAB);

  t->grafo = grafo_ini();
  t->nombre = (char*)malloc(sizeof(char)*(strlen(nombre)+1));
  strcpy(t->nombre, nombre);

  return t;
}

/**
* iniciarTablaSimbolosAmbitos
*
* Reserva todos los recursos para crear una tsa
* que tenga dos tablas hash por cada ambito local/global
**/
tablaSimbolosAmbitos *iniciarTablaSimbolosAmbitos(){
  tablaSimbolosAmbitos *t;

  t = (tablaSimbolosAmbitos*)malloc(sizeof(tablaSimbolosAmbitos)*MAX_TAB);

  t->idAmbito = CERRADO;

  return t;
}
/**
* destruirTablaSimbolosAmbitos
*
* Libera todos los recursos de una tsa creada
*
**/
void destruirTablaSimbolosAmbitos(tablaSimbolosAmbitos *t){
	if (!t){
		return;
	}

	eliminarTablaHash(t->global);
	eliminarTablaHash(t->local);
	free(t->nombre_local);
	free(t->nombre_global);
	free(t);
	return;
}

/**
* abrirClase
*
* Realiza las tareas de añadir al grafo una nueva raíz
**/
int abrirClase(tablaSimbolosClases* t, char* id_clase){
	tablaSimbolosAmbitos *tA;

	if (!t || !id_clase){
		return ERROR;
	}
	tA = iniciarTablaSimbolosAmbitos();
	if (!tA){
		return ERROR;
	}

    if (abrirAmbitoPpalMain(tA, id_clase) == ERROR){
      destruirTablaSimbolosAmbitos(tA);
      return ERROR;
    }

	if (grafo_insert_raiz(t->grafo, id_clase, tA) == false){
		destruirTablaSimbolosAmbitos(tA);
		return ERROR;
	}

	return OK;
}

/**
* abrirClaseHeredaN
*
* Realiza las tareas de añadir al grafo un nuevo nodo
* que debe conectarse a los nombres identificados mediante los últimos argumentos
*
*/
int abrirClaseHeredaN (tablaSimbolosClases* t, char *id_clase, int num_padres, char** nombres_padres){
	tablaSimbolosAmbitos *tA;

	if (!t){
		return ERROR;
	}

        tA = iniciarTablaSimbolosAmbitos();
        if (!tA){
		return ERROR;
	}

        if (abrirAmbitoPpalMain(tA, id_clase) == ERROR){
            destruirTablaSimbolosAmbitos(tA);
            return ERROR;
        }

        if(grafo_insert_node(t->grafo, id_clase, tA, nombres_padres, num_padres) == false){
		destruirTablaSimbolosAmbitos(tA);
		return ERROR;
	}

	return OK;
}

/**
* cerrarClase
*
* Realiza tareas asociadas con el final de la clase identificada
* mediante el segundo argumento
*
*/
int cerrarClase(tablaSimbolosClases* t, char *id_clase, int num_atributos_clase, int num_atributos_instancia, int num_metodos_sobreescribibles, int num_metodos_no_sobreescribibles){
	Nodo* nodo;
	tablaSimbolosAmbitos *tsa;
	elementoTablaSimbolos * e;

	if(!t || !id_clase)
		return ERROR;

	if(!(nodo = grafo_find_nodo(t->grafo, id_clase)))
		return ERROR;

	tsa = nodo_get_info(nodo);
	if (!tsa){
		return ERROR;
	}

	/*Insertar en la TS con la info de e*/

	e = nodo_crearElementoTablaSimbolos();

	e->numero_atributos_clase = num_atributos_clase;
	e->numero_atributos_instancia = num_atributos_instancia;
	e->numero_metodos_sobreescribibles = num_metodos_sobreescribibles;
	e->numero_metodos_no_sobreescribibles = num_metodos_no_sobreescribibles;

	if (insertarTablaSimbolosAmbitos(tsa, id_clase, e) == ERROR){
		return ERROR;
	}

   return OK;
}

/**
* cerrarTablaSimbolosClases
*
* Realiza tareas asociadas con el final de la clase identificada
* mediante el segundo argumento
*
*/
int cerrarTablaSimbolosClases(tablaSimbolosClases* t){
	if (!t){
		return ERROR;
	}

	//grafo_free(t->grafo);
	free(t->nombre);
	free(t);
	return OK;
}

/**
* abrirAmbitoPpalMain
*
* Realiza tareas asociadas con la apertura del ámbito principal
* de la tabla de símbolos por ámbitos de main
*
**/
int abrirAmbitoPpalMain(tablaSimbolosAmbitos* t, char *nombre_ambito){

	if (!t){
		return ERROR;
	}

	t->global = crearTablaHash(MAX_TAB);
	t->idAmbito = GLOBAL;
	t->nombre_global = (char*)malloc(strlen(nombre_ambito)*sizeof(char)+1);
	strcpy(t->nombre_global, nombre_ambito);
	return OK;
}

/**
* abrirAmbitoMain
*
* Realiza tareas asociadas con la apertura del ámbito asociado
* con una función global dentro del ámbito main
*
**/
int abrirAmbitoMain(tablaSimbolosAmbitos * t, char* id_ambito, int categoria_ambito, int tipo_ambito){

    elementoTablaSimbolos *e;

    if (!t || !id_ambito){
    	return -1;
    }
    t->nombre_local = (char*)malloc(strlen(id_ambito)*sizeof(char)+1);
    strcpy(t->nombre_local, id_ambito);

    t->local = crearTablaHash(MAX_TAB);
    t->idAmbito = LOCAL;

    e = nodo_crearElementoTablaSimbolos();
    if (!e){
    	return ERROR;
    }
    e->categoria = categoria_ambito;
	e->tipo = tipo_ambito;
	strcpy(e->clave, id_ambito);

    return insertarNodoHash(t->global, e->clave, e);
}
/**
* cerrarAmbitoMain
*
* Realiza tareas asociadas con el cierre del ámbito asociado con una
* función global dentro del ámbito main, cierra el ámbito actual, de hecho
*
**/
int cerrarAmbitoMain(tablaSimbolosAmbitos* t){
	if (!t){
		return ERROR;
	}
	eliminarTablaHash(t->local);
	free(t->nombre_local);
    t->local = NULL;
    t->nombre_local = NULL;
	t->idAmbito = GLOBAL;

	return OK;
}
/**
* tablaSimbolosClasesAbrirAmbitoEnClase
*
* Realiza tareas asociadas con la apertura del ámbito asociado con un método
*
**/
int tablaSimbolosClasesAbrirAmbitoEnClase(tablaSimbolosClases * grafo, char * id_clase, char* id_ambito, int categoria_ambito, int tipo_ambito, int acceso_ambito, int tipo_miembro, int posicion_metodo_sobre){
	Nodo *nodo;
	tablaSimbolosAmbitos *tA;
        char *tok;
        char aux[1000] = "";
        char aux2[1000] = "";

	/*elementoTablaSimbolos *e;*/

	if (!grafo || !id_clase || !id_ambito){
		return ERROR;
	}
	if(!(nodo = grafo_find_nodo(grafo->grafo, id_clase))){
		return ERROR;
	}
	tA = nodo_get_info(nodo);
	if (tA == NULL){
		return ERROR;
	}

        strcpy(aux, id_ambito);
        tok = strtok(id_ambito, "_");
        strcat(aux2, &aux[strlen(tok)+1]);

	return abrirAmbitoMain(tA, aux2, categoria_ambito, tipo_ambito);
	/*DUDA: e->categoria = categoria_ambito;
	e->tipo_acceso = acceso_ambito;
	e->tipo_miembro = tipo_miembro;
	e->posicion_metodo_sobreescribible = posicion_metodo_sobre;*/


}
/**
* tablaSimbolosClasesCerrarAmbitoEnClase
*
* Realiza tareas asociadas con el cierre del ámbito asociado con un método
*
**/
int tablaSimbolosClasesCerrarAmbitoEnClase(tablaSimbolosClases * grafo, char * id_clase){
	Nodo *nodo;
	tablaSimbolosAmbitos *tA;
	if (!grafo || !id_clase){
		return ERROR;
	}
	if(!(nodo = grafo_find_nodo(grafo->grafo, id_clase))){
		return ERROR;
	}

	tA = nodo_get_info(nodo);
	if (tA == NULL){
		return ERROR;
	}
	if(cerrarAmbitoMain(tA) == ERROR){
		return ERROR;
	}
	return OK;
}

/*******************************************************/
/*Busqueda de identificadores en la parte de sentencias*/
/*******************************************************/

/**
* buscarIdEnJerarquiaDesdeClase
*
* Busca en la jerarquía de clases (en las tablas tablaAmbitos de cada clase)
*
**/
int buscarIdEnJerarquiaDesdeClase(tablaSimbolosClases *t, char * nombre_id, char * nombre_clase_desde, elementoTablaSimbolos ** e, char * nombre_ambito_encontrado){
	Nodo *nodo;
	tablaSimbolosAmbitos *tA;



	if (!t || !nombre_id || !nombre_clase_desde){
		return ERROR;
	}
	/*Primero busco en los nodos y llamo a buscar basico*/
	nodo = grafo_find_nodo(t->grafo, nombre_clase_desde);
	if (!nodo){
		return ERROR;
	}
	tA = nodo_get_info(nodo);
	if (!tA){
		return ERROR;
	}
	/*Revisar params*/
	/*Habra que hacer algo con los nombres que paso a aplicarAccesos pero no se*/
	if (buscarTablaSimbolosAmbitoActual(tA, nombre_id, e, nombre_ambito_encontrado) == OK){
		return aplicarAccesos(t, nombre_clase_desde, nombre_ambito_encontrado, *e);
	}


	/*Luego si no se ha encontrado miro en los padres y llamo a buscar basico*/
	/*Si se ha encontrado entonces hacer aplicar accesos*/

	nodo = grafo_find_raiz(t->grafo, nombre_clase_desde);
	if (!nodo){
		return ERROR;
	}
	tA = nodo_get_info(nodo);
	if (!tA){
		return ERROR;
	}
	/*Revisar params*/
	/*Habra que hacer algo con los nombres que paso a aplicarAccesos pero no se*/
	if (buscarTablaSimbolosAmbitoActual(tA, nombre_id, e, nombre_ambito_encontrado) == OK){
		return aplicarAccesos(t, nombre_clase_desde, nombre_ambito_encontrado, *e);
	}

	return ERROR;
}
/**
* buscarTablaSimbolosAmbitosConPrefijos
*
* Encuentra simbolos por prefijo
*
**/
int buscarTablaSimbolosAmbitosConPrefijos (tablaSimbolosAmbitos *tA, char *id, elementoTablaSimbolos **e, char *id_ambito){

	if (!tA || !id || !e){
		return ERROR;
	}

	return buscarTablaSimbolosAmbitoActual(tA, id, e, id_ambito);
}
/**
* buscarIdNoCualificado
*
* Se responsabiliza de la búsqueda de un identificador cuando aparece en las sentencias y se quiere usar
* El identificador no debe ir cualificado
*
**/
int buscarIdNoCualificado(tablaSimbolosClases *t, tablaSimbolosAmbitos *tabla_main, char * nombre_id, char * nombre_clase_desde, elementoTablaSimbolos ** e, char * nombre_ambito_encontrado){
  if (/*!t || */!tabla_main || !nombre_id || !nombre_clase_desde ){
  	return ERROR;
  }
  if (strcmp(nombre_clase_desde, "main") == 0){
  	if (buscarTablaSimbolosAmbitosConPrefijos(tabla_main, nombre_id, e, nombre_ambito_encontrado) == ERROR){
  		return ERROR;
  	}
	return OK;
  } else {
  	if(buscarIdEnJerarquiaDesdeClase(t, nombre_id, nombre_clase_desde, e, nombre_ambito_encontrado) == OK){
  		return OK;
  	}
  	if (buscarTablaSimbolosAmbitosConPrefijos(tabla_main, nombre_id, e, nombre_ambito_encontrado) == ERROR){
  		return ERROR;
  	}
	return OK;
  }
  return ERROR;
}
/**
* buscarIdIDCualificadoClase
*
* Busca identificadores cualificados cuando aparecen así en la parte de sentencias (expresiones del tipo <identificador>.<identificador>)
* Se utiliza cuando se cualifica con el nombre de una clase
*
**/
int buscarIdIDCualificadoClase(tablaSimbolosClases *t, char * nombre_clase_cualifica, char * nombre_id, char * nombre_clase_desde, elementoTablaSimbolos ** e, char * nombre_ambito_encontrado){
	Nodo *nodo;
	if (!t || !nombre_clase_cualifica || !nombre_id || !nombre_clase_desde || !e || nombre_ambito_encontrado){
		return ERROR;
	}
	nodo = grafo_find_nodo(t->grafo, nombre_clase_cualifica);
	if (!nodo){
		return ERROR;
	}
	if (buscarIdEnJerarquiaDesdeClase(t, nombre_id, nombre_clase_cualifica, e, nombre_ambito_encontrado) == OK){
		 return aplicarAccesos(t, nombre_clase_desde, nombre_ambito_encontrado, *e);
	}
	return ERROR;
}
/**
* buscarIdCualificadoInstancia
*
* Busca identificadores cualificados cuando aparecen así en la parte de sentencias (expresiones del tipo <identificador>.<identificador>)
* Se utiliza cuando se cualifica con el nombre de una instancia
*
**/
int buscarIdCualificadoInstancia(tablaSimbolosClases *t, tablaSimbolosAmbitos * tabla_main, char * nombre_instancia_cualifica, char * nombre_id, char * nombre_clase_desde, elementoTablaSimbolos ** e, char * nombre_ambito_encontrado){

	if (!t || !tabla_main || !nombre_instancia_cualifica || !nombre_id || !nombre_clase_desde || !e){
		return ERROR;
	}
	if (buscarIdNoCualificado(t, tabla_main, nombre_instancia_cualifica, nombre_clase_desde, e, nombre_ambito_encontrado) == ERROR){
		return ERROR;
	} else {
		if ((*e)->tipo_acceso == ACCESO_CLASE){
			/*revisar*/
			strcat(nombre_clase_desde, ".");
			strcat(nombre_clase_desde, nombre_id);
			strcpy(nombre_instancia_cualifica, nombre_clase_desde);
		}
		if (aplicarAccesos(t, nombre_clase_desde, nombre_ambito_encontrado, *e) == ERROR){
			return ERROR;
		}
		if (buscarIdEnJerarquiaDesdeClase(t, nombre_id, nombre_instancia_cualifica, e, nombre_ambito_encontrado) == OK){
			return aplicarAccesos(t, nombre_clase_desde, nombre_ambito_encontrado, *e);
		}
		return OK;
	}

	return ERROR;
}

/**********************************************************/
/*Busqueda de identificadores en la parte de declaraciones*/
/**********************************************************/

/**
* buscarParaDeclararMiembroClase
*
* Realiza la búsqueda de identificadores cuando, al declararlos, se intenta insertarlos en la tabla de símbolos
* Se utiliza cuando se quiere declarar un miembro de clase (ya sea método o atributo)
*
**/
int buscarParaDeclararMiembroClase(tablaSimbolosClases *t, char * nombre_clase_desde, char * nombre_miembro, elementoTablaSimbolos ** e, char * nombre_ambito_encontrado){
	Nodo *nodo;
	tablaSimbolosAmbitos *tsa;
	if (!t || !nombre_clase_desde || !nombre_miembro || !e){
		return ERROR;
	}
	nodo = grafo_find_nodo(t->grafo, nombre_clase_desde);
	if (!nodo){
		return ERROR;
	}
	tsa = nodo_get_info(nodo);
	if (!tsa){
		return ERROR;
	}
	return buscarTablaSimbolosAmbitosConPrefijos(tsa, nombre_miembro, e, nombre_ambito_encontrado);

}
/**
* iniciarTablaSimbolosClases
*
* Realiza la búsqueda de identificadores cuando, al declararlos, se intenta insertarlos en la tabla de símbolos
* Se utiliza cuando se quiere declarar un miembro de instancia
*
**/
int buscarParaDeclararMiembroInstancia(tablaSimbolosClases *t, char * nombre_clase_desde, char * nombre_miembro, elementoTablaSimbolos ** e, char * nombre_ambito_encontrado){
  if (!t || !nombre_clase_desde || !nombre_miembro || !e){
  	return ERROR;
  }
  if (buscarTablaSimbolosClasesAmbitoActual(t, nombre_clase_desde, nombre_miembro, e, nombre_ambito_encontrado) == OK){
  	return OK;
  }
  return buscarIdEnJerarquiaDesdeClase(t, nombre_miembro, nombre_clase_desde, e, nombre_ambito_encontrado);
}
/**
* buscarTablaSimbolosAmbitoActual
*
* Busca el símbolo id en la tabla de símbolos t (especialmente pensada para main)
*
**/
int buscarTablaSimbolosAmbitoActual(tablaSimbolosAmbitos * t, char* id, elementoTablaSimbolos ** e, char * id_ambito){
	NodoHash *n;
	char aux[1000] = "";

	if (!t || !id){
		return ERROR;
	}
	if(t->idAmbito == GLOBAL){
		//sprintf(aux, "% s_%s", t->nombre_global, id);
                /*strcpy(aux, t->nombre_global);
                strcpy(aux, "_");
                strcpy(aux, id);*/
		n = buscarNodoHash(t->global, id);
		if(n){

			*e = nodo_get_ElementoTablaSimbolos(n);
			strcpy(id_ambito, t->nombre_global);
			return OK;
		}
		return ERROR;
	} else if (t->idAmbito == LOCAL){
                sprintf(aux, "%s_%s", t->nombre_local, id);
		n = buscarNodoHash(t->local, aux);
		if(!n){
                    sprintf(aux, "%s_%s", t->nombre_global, id);
			/*strcpy(aux, t->nombre_global);
			strcpy(aux, "_");
			strcpy(aux, id);*/
			n = buscarNodoHash(t->global, aux);

			if(n){
				*e = nodo_get_ElementoTablaSimbolos(n);
				strcpy(id_ambito, t->nombre_global);
				return OK;
			}
			return ERROR;
		} else {
			*e = nodo_get_ElementoTablaSimbolos(n);
			strcpy(id_ambito, t->nombre_local);
			return OK;
		}
	} else {
    	return ERROR;
	}

	return OK;
}
/**
* buscarTablaSimbolosClasesAmbitoActual
*
* Esta función se utilizará en situaciones similares a la anterior pero cuando se está en un método de una clase
*
**/
int buscarTablaSimbolosClasesAmbitoActual(tablaSimbolosClases *t, char * nombre_clase, char * nombre_id, elementoTablaSimbolos ** e, char * nombre_ambito_encontrado){
	Nodo *n;
	tablaSimbolosAmbitos *tA;
	if (!t || !nombre_clase || !nombre_id || !e){
		return ERROR;
	}
	n = grafo_find_nodo(t->grafo, nombre_clase);
	if (!n){
		return ERROR;
	}
	tA = nodo_get_info(n);
	if (!tA){
		return ERROR;
	}
	return buscarTablaSimbolosAmbitoActual(tA, nombre_id, e, nombre_ambito_encontrado);
}
/**
* buscarParaDeclararIdTablaSimbolosAmbitos
*
* Esta función realiza la busqueda previa a la declaracion de un identificador de cualquier tipo fuera de la jerarquia de clases
*
**/
int buscarParaDeclararIdTablaSimbolosAmbitos(tablaSimbolosAmbitos *t, char *id, elementoTablaSimbolos **e, char *idAmbito){
	if (!t || !id ){
		return ERROR;
	}
	if (buscarTablaSimbolosAmbitoActual(t, id, e, idAmbito) == ERROR){
		/*Se puede declarar*/
		return ERROR;
	}
	/*No se puede declarar*/
	return OK;
}
/**
* buscarParaDeclararIdLocalEnMetodo
*
* Esta función realiza la busqueda previa a la declaracion de un identificador local en un metodo de una clase
*
**/
int buscarParaDeclararIdLocalEnMetodo(tablaSimbolosClases *t, char *nombre_clase, char *nombre_id, elementoTablaSimbolos **e, char *nombre_ambito_encontrado){
	tablaSimbolosAmbitos *tsa;
	Nodo *aux;
	if (!t || !nombre_clase || !nombre_id || !e){
		return ERROR;
	}
	aux = grafo_find_nodo(t->grafo, nombre_clase);
	if (!aux){
		return ERROR;
	}
	tsa = nodo_get_info(aux);
	if (!tsa){
		return ERROR;
	}
	if (buscarTablaSimbolosAmbitoActual(tsa, nombre_id, e, nombre_ambito_encontrado) == ERROR){
		/*Se puede declarar*/
		return ERROR;
	}
	/*No se puede declarar*/
	return OK;
}

/********************************************************************/
/*Funciones insercion simbolos que no involucren creacion de ambitos*/
/********************************************************************/

/**
* insertarTablaSimbolosClases
*
* Realiza las tareas de inserción de un símbolo en el grafo
*
**/
int insertarTablaSimbolosClases(tablaSimbolosClases * grafo, char* id_clase,
					char* id,
					int clase,
					int categoria,
					int tipo,
					int estructura,
					int direcciones,
					int numero_parametros,
					int numero_variables_locales,
					int posicion_variable_local,
					int posicion_parametro,
					int dimension,
					int tamanio,
					int filas,
					int columnas,
					int capacidad,
					int numero_atributos_clase,
					int numero_atributos_instancia,
					int numero_metodos_sobreescribibles,
					int numero_metodos_no_sobreescribibles,
					int tipo_acceso,
					int tipo_miembro,
					int posicion_atributo_instancia,
					int posicion_metodo_sobreescribible,
					int num_acumulado_atributos_instancia,
					int num_acumulado_metodos_sobreescritura,
    				int posicion_acumulada_atributos_instancia,
    				int posicion_acumulada_metodos_sobreescritura,
					int * tipo_args){

	Nodo* nodo;
	elementoTablaSimbolos* e;
	tablaSimbolosAmbitos *tA;

	if (!grafo || !id_clase || !id){
		return ERROR;
	}

	if(!(nodo = grafo_find_nodo(grafo->grafo, id_clase)))
		return ERROR;

	tA = nodo_get_info(nodo);

	e = nodo_crearElementoTablaSimbolos();

	e = nodo_set_ElementoTablaSimbolos(e, id, clase, categoria, tipo, estructura, direcciones, numero_parametros,
										numero_variables_locales, posicion_variable_local, posicion_parametro,
										dimension, tamanio, filas, columnas, capacidad, numero_atributos_clase,
										numero_atributos_instancia, numero_metodos_sobreescribibles,
										numero_metodos_no_sobreescribibles, tipo_acceso, tipo_miembro, posicion_atributo_instancia,
										posicion_metodo_sobreescribible, num_acumulado_atributos_instancia,
										num_acumulado_metodos_sobreescritura, posicion_acumulada_atributos_instancia,
										posicion_acumulada_metodos_sobreescritura, tipo_args);
	insertarTablaSimbolosAmbitos(tA, id, e);


	return OK;
}

/**
* insertarTablaSimbolosClases
*
* Realiza las tareas de inserción de un símbolo en la TSA
*
**/
int insertarTablaSimbolosAmbitos(tablaSimbolosAmbitos * tA, char* id_clase, elementoTablaSimbolos *e){

	if (!tA || !id_clase || !e){
		return ERROR;
	}

	if (tA->idAmbito == CERRADO){
		return ERROR;
	}
	if (tA->idAmbito == GLOBAL){
    printf("\nSE METE EN INSERTAR NH DE LA GLOBAL\n")
		if (insertarNodoHash(tA->global, id_clase, e) == ERROR){
			return ERROR;
		}
	}
	if (tA->idAmbito == LOCAL){
		if (insertarNodoHash(tA->local, id_clase, e) == ERROR){
			return ERROR;
		}
	}
	return OK;
}

/***********************/
/*Funcionalidad variada*/
/***********************/

/**
* aplicarAccesos
*
* Esta función realiza el control de acceso aplicando la política de cualificadores de acceso (hidden, secret y exposed)
*
**/
int aplicarAccesos(tablaSimbolosClases *t, char * nombre_clase_ambito_actual, char * clase_declaro, elementoTablaSimbolos * pelem){
	Nodo *n;
	tablaSimbolosAmbitos *tA;

	if (!t || !nombre_clase_ambito_actual || !clase_declaro || !pelem){
		return ERROR;
	}

	if (strcmp(nombre_clase_ambito_actual, "main") == 0){
		pelem->tipo_acceso = ACCESO_CLASE;

		return OK;
	}
	if (pelem->tipo_acceso == ACCESO_HERENCIA){
		if (strcmp(nombre_clase_ambito_actual, clase_declaro) != 0){
			return ERROR;
		}
	}
	if (pelem->tipo_acceso == ACCESO_CLASE){
		n = grafo_find_raiz(t->grafo, nombre_clase_ambito_actual);
		if (!n){
			return ERROR;
		}
		tA = nodo_get_info(n);
		if (!tA){
			return ERROR;
		}
		if (tA->idAmbito == GLOBAL){
			if (buscarNodoHash(tA->global, clase_declaro)!=NULL){
				return ERROR;
			}
		} else if (tA->idAmbito == LOCAL){
			if (buscarNodoHash(tA->local, clase_declaro)!=NULL){
				return ERROR;
			}
		}
	}
	return OK;
}
/**
* tablaSimbolosClasesToDot
*
* Esta función genera el fichero que contiene el gráfico en formato dot de la tabla de simbolos de clases
* y que tiene como nombre el nombre de la tabla (con el que se creó) con la extensión .dot.
*
**/
tablaSimbolosClases * tablaSimbolosClasesToDot(tablaSimbolosClases * grafo){
	FILE *f;
	f = fopen("grafo.dot", "w+");
	if (!f){
		fprintf(stdout, "Error al abrir el archivo");
	}

	grafo_print_dot(f, grafo->grafo);

	fclose(f);
	return grafo;
}
/**
* tablaSimbolosClasesANasm
*
* Esta funcion abre un fichero ensamblador y se escribe el codigo NASM necesario
* para que contenga la TS y se pueda unir al codigo ensamblador del resto de la
* generacion para componer la version de bajo nivel que genera nuestro compilador
*
**/
int tablaSimbolosClasesANasm(tablaSimbolosClases *t){
	if (!t){
		return ERROR;
	}
	/*A partir del nombre del grafo: t->nombre*/
	/*Se abre un fichero ensamblador*/
	/*Se escribe el codigo NASM para que contenga la TS*/

	return OK;
}
