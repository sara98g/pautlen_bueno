#ifndef OMICRON_H
#define OMICRON_H

#define MAX_ID 50

typedef struct 
{
    char lexema[MAX_ID+1];
    int valor_entero;
    int tipo;
    int es_direccion;
    int etiqueta;
    
}tipo_atributo;

#endif
