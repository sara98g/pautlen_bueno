#ifndef HASH
#define HASH

#include "list.h"

typedef struct _elementoTablaSimbolos elementoTablaSimbolos;


/**************** CONSTANTES ****************/
#define HASH_INI 5381
#define HASH_FACTOR 33
#define TAM_L 100
#define MAX_TAB 64 /*tamanio de la tabla entre 1 y 64*/


/***************************************************************************/
/*Enumerados utiles para la clasificacion de la informacion de los simbolos*/
/***************************************************************************/

typedef enum {
    OK = 0, ERROR = -1
} STATUS;

typedef enum {
	VARIABLE = 1, PARAMETRO = 2, FUNCION = 3, CLASE = 4, METODO_SOBREESCRIBIBLE = 5, METODO_NO_SOBREESCRIBIBLE = 6, ATRIBUTO_CLASE = 7, ATRIBUTO_INSTANCIA = 8
} CATEGORIA;

typedef enum {
	INT = 1, BOOLEAN = 3
} TIPO;

typedef enum {
	ESCALAR = 1, VECTOR = 2
} TIPO_CLASE;

typedef enum {
    CERRADO = -1, GLOBAL = 0, LOCAL = 1
} AMBITO;

typedef enum {
    NINGUNO = 0, ACCESO_CLASE = 1, ACCESO_HERENCIA = 2, ACCESO_TODOS = 3
} TIPO_ACCESO;

typedef enum {
    MIEMBRO_UNICO = 1, MIEMBRO_NO_UNICO = 2
} TIPO_MIEMBRO;


/**************** DECLARACIONES DE TIPOS ****************/

struct _elementoTablaSimbolos {
    char *clave; /*clave de acceso a la tabla*/
    int categoria; /*variable, parametro de funcion, funcion, clase*/
    int tipo; /*boolean o int*/
    int clase; /*escalar o vector*/
    int tamanio; /*1-64*//*filas*//*Su valor ira de 1 a (#define MAX_TAB), solo valdra 0 si no se trata de un vector*/
    int numero_parametros; /*numero de parametros que contiene la funcion */
    int posicion_parametro; /*posicion del parametro de la funcion. COMIENZA EN 0*/
    int numero_variables_locales; /*numero de variables locales*/
    int posicion_variable_local; /*posicion de variable local. COMIENZA EN 1*/

    int direcciones; /*>=1 si es variable*/

    /* INFORMACION PARA CLASES */
  	int numero_atributos_clase;
  	int numero_atributos_instancia;
  	int numero_metodos_sobreescribibles;
  	int numero_metodos_no_sobreescribibles;
  	TIPO_ACCESO tipo_acceso;
  		/*NINGUNO (exposed) ACCESO_CLASE (secret)
      ACCESO_HERENCIA	(hidden) ACCESO_TODOS (exposed) */
  	TIPO_MIEMBRO tipo_miembro;
  		/*MIEMBRO_UNICO (unique) MIEMBRO_NO_UNICO*/
  	int posicion_atributo_instancia;
  	int posicion_metodo_sobreescribible;
  	int num_acumulado_atributos_instancia;
  	int num_acumulado_metodos_sobreescritura;
  	int * tipo_args;

}; /*info de los nodos hash*/

typedef struct NodoHash {
	elementoTablaSimbolos *info;
	char *clave;        /*Identificador del nodo.*/
	struct NodoHash *siguiente; /*NULL en caso de que no exista un nodo en colision. El siguiente en caso contrario.*/
} NodoHash;

typedef struct TablaHash {
	int tam;    	/*Tamaño de la tabla hash.*/
	char **lista;
    int nElem;
	NodoHash **tabla; /*Array de punteros a los primeros elementos de la tabla hash.*/
} TablaHash;

NodoHash* nodoHash_copiar(NodoHash* nodo);
/**************** FUNCIONES ****************/
elementoTablaSimbolos * nodo_crearElementoTablaSimbolos();
int nodo_free_ElementoTablaSimbolos(elementoTablaSimbolos * e);
elementoTablaSimbolos * nodo_get_ElementoTablaSimbolos(NodoHash *n);
elementoTablaSimbolos * nodo_set_ElementoTablaSimbolos(elementoTablaSimbolos *e,
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
													int * tipo_args);
/*Recibe un tamaño y crea una tabla de dicha longitud.*/
TablaHash* crearTablaHash(int tam);

/*Elimina la tabla Hash.
Devuelve OK en caso de que se borre correctamente y ERROR en caso de que no.*/
int eliminarTablaHash(TablaHash *th);

/*Recibe el identificador de un nodo y devuelve su indice para la tabla hash.
Funcion auxiliar, se llama dentro de la funcion insertarNodoHash.*/
int funcionHash(char *clave);

/*Recibe la clave y la informacion, y devuelve un nuevo NodoHash. Reservara memoria y rellenara la estructura de NodoHash.
Funcion auxiliar, se llama dentro de la funcion insertarNodoHash.*/
NodoHash* crearNodoHash(char *clave, elementoTablaSimbolos *info);
void destruirNodoHash(NodoHash *nh);
/*Inserta en la tabla hash un nodo en un indice calculado por funcionHash.
Utilizara la funcionHash para saber donde insertar el nuevo elemento y debera crear dentro el nuevo nodo (crearNodoHash).
Devuelve OK en caso de que se inserte y ERROR en caso de que no.*/
int insertarNodoHash(TablaHash *th, char *clave, elementoTablaSimbolos *info);

/*Busca en la tabla hash el nodo identificado por su clave y lo devuelve. NULL en caso contrario.*/
NodoHash* buscarNodoHash(TablaHash *th, char *clave);
bool printHashDot(FILE* fp, TablaHash* th);

#endif
