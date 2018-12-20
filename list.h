#ifndef LIST_H
#define LIST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

typedef struct _List List;

/* Tipos de los punteros a función soportados por la lista */
typedef void (*destroy_elementlist_function_type)(void*);
typedef void (*(*copy_elementlist_function_type)(const void*));
typedef bool (*print_elementlist_function_type)(FILE *, const void*);
/* La siguiente función permite comparar dos elementos, 
devolviendo un número  positivo, negativo o cero según si 
el primer argumento es mayor, menor o igual que el segundo 
argumento */
typedef int (*cmp_elementlist_function_type)(const void*, const void*);


List* linkedList_ini(destroy_elementlist_function_type f1, copy_elementlist_function_type f2, print_elementlist_function_type f3, cmp_elementlist_function_type f4, bool copy);

void linkedList_free_no_node(List* l);
void linkedList_free(List* l);

bool linkedList_insert_first(List* l, const void *e);
bool linkedList_insert_last(List* l, const void *e);
bool linkedList_inser_inOrder(List *l, const void *e);

void* linkedList_extract_first(List* l);
void* linkedList_extract_last(List* l);
void* linkedList_extract(List* l, int position);

void* linkedList_get_first(const List* l);
void* linkedList_get_last(const List* l);
void* linkedList_get(const List* l, int posicion);

bool linkedList_remove_first(List* l);
bool linkedList_remove_last(List* l);
bool linkedList_remove(List* l, int position);

int linkedList_find(const List* l, const void* e);

bool linkedList_isEmpty(const List* l);

bool linkedList_is_ordened(const List* l);

bool linkedList_is_copy(const List* l);

int linkedList_size(const List* l);

bool linkedList_print_alt(FILE *fp, const List* l);

bool linkedList_print(FILE *fd, const List* l);

#endif