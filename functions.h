#ifndef FUNCTIONS_H
#define FUNCTIONS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void destroy_intp_function(void* e);

void * copy_intp_function(const void* e);

bool print_intp_function(FILE * f, const void* e);

int cmp_intp_function(const void * e, const void * c);


#endif