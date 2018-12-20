#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "functions.h"

/*
* En este fichero se definen las funciones de destrucción, copia e impresión de elementos a almacenar en
* una pila para distintos tipos de datos
*/
/* Las siguientes funciones se usarán cuando se quieran guardar enteros en la pila. Ojo! Estas funciones
reciben un puntero a entero, no una estructura con un puntero a entero (como en el ejercicio P2_E1) */
void destroy_intp_function(void * e){
    free((int*)e);
}

void * copy_intp_function(const void* e){
    int* dst;
   
    if (!e)
        return NULL;
        
    dst = (int*)malloc(sizeof(int));
    if(!dst)
        return NULL;
    
    /*Copiamos el elemento*/
    *(dst) = *((int*)e);
    
    return dst;
}

bool print_intp_function(FILE * f, const void* e){
    if (f != NULL && e != NULL)
        return fprintf(f, "%d", *(int*)e);
        
    return false;
}

int cmp_intp_function(const void* e, const void* c){
    if (!e || !c)
        return -2;
        
    if ( *((int*)e) < *((int*)c))
        return -1;        
    else if ( *((int*)e) > *((int*)c))
        return 1;  
    else
        return 0;
}