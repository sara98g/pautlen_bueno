#include "generacion.h"


void escribir_cabecera_bss(FILE* fpasm){
    fprintf(fpasm, "\n; --- Funcion escribir_cabecera .bss---\n");
    fprintf(fpasm, "segment .bss\n");
    fprintf(fpasm, "\t __esp resd 1\n");
}

void escribir_subseccion_data(FILE* fpasm){
    fprintf(fpasm, "\n; --- Funcion escribir_subseccion_data---\n");
    fprintf(fpasm, "segment .data\n");
    fprintf(fpasm, "\tErrorDiv0 db \"Error division por cero\", 0\n");
    fprintf(fpasm, "\tErrorIndex db \"Indice fuera de rango\", 0\n");
}

void declarar_variable(FILE* fpasm, char * nombre,  int tipo,  int tamano){
    fprintf(fpasm, "\n; ---Funcion declarar_variable---\n");
    fprintf(fpasm, "\t_%s resd %d\n", nombre, tamano);
}

void escribir_segmento_codigo(FILE* fpasm){
    fprintf(fpasm, "\n; --- Funcion segmento codigo---\n");
    fprintf(fpasm,"segment .text\n");
    fprintf(fpasm,"\tglobal main\n");
    fprintf(fpasm,"\textern scan_int, print_int, print_boolean, scan_boolean\n");
	fprintf(fpasm, "\textern print_blank, print_endofline, print_string\n");

}

void escribir_inicio_main(FILE* fpasm){

    fprintf(fpasm, "\n;---Funcion escribir_inicio_main---\n");
    fprintf(fpasm, "main:\n\tmov dword [__esp], esp\n");

}

void escribir_fin(FILE* fpasm){
    fprintf(fpasm, "\n; ---Funcion fin---\n");
    fprintf(fpasm, "\tjmp near fin\n");

    fprintf(fpasm, "\tmensaje_1:\n");
    fprintf(fpasm, "\t\tpush dword ErrorIndex\n");
    fprintf(fpasm, "\t\tcall print_string\n");
    fprintf(fpasm, "\t\tadd esp, 4\n");
    fprintf(fpasm, "\tjmp near fin\n");


    fprintf(fpasm, "\tfin_error_division:\n");
    fprintf(fpasm, "\t\tpush dword ErrorDiv0\n");
    fprintf(fpasm, "\t\tcall print_string\n");
    fprintf(fpasm, "\t\tadd esp, 4\n");

    fprintf(fpasm, "\tfin:\n");
    fprintf(fpasm, "\t\tmov dword esp, [__esp]\n");
    fprintf(fpasm, "\t\tcall print_endofline\n");
    fprintf(fpasm, "\t\tret\n");
}

void escribir_operando(FILE* fpasm, char* nombre, int es_variable){
    fprintf(fpasm, "\n; ---Funcion escribir_operando---\n");
    if(es_variable)
        fprintf(fpasm, "\tpush dword _%s\n", nombre); /***************************/
    else
        fprintf(fpasm, "\tpush dword %s\n", nombre);

}

void asignar(FILE* fpasm, char* nombre, int es_variable){
    fprintf(fpasm, "\n; ---Funcion asignar---\n");
    fprintf(fpasm, "\tpop dword eax\n");
    if(es_variable)
        fprintf(fpasm, "\tmov dword eax, [eax]\n");

    fprintf(fpasm, "\tmov dword [_%s], eax\n", nombre);

}


void sumar(FILE* fpasm, int es_variable_1, int es_variable_2){
    fprintf(fpasm, "\n;---Funcion suma---\n");
    fprintf(fpasm, "\tpop dword eax\n\tpop dword ecx\n");

    if(es_variable_1)
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");

    if(es_variable_2)
        fprintf(fpasm, "\tmov dword eax, [eax]\n");

    fprintf(fpasm, "\tadd eax, ecx\n");
    fprintf(fpasm, "\tpush dword eax\n");

}
void restar(FILE* fpasm, int es_variable_1, int es_variable_2){

    fprintf(fpasm, "\n;---Funcion resta---\n");
    fprintf(fpasm, "\tpop dword eax\n\tpop dword ecx\n");

    if(es_variable_1)
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");

    if(es_variable_2)
        fprintf(fpasm, "\tmov dword eax, [eax]\n");

    fprintf(fpasm, "\tsub ecx, eax\n");
    fprintf(fpasm, "\tpush dword ecx\n");
}


void multiplicar(FILE* fpasm, int es_variable_1, int es_variable_2){
    fprintf(fpasm, "\n;---Funcion multiplicar---\n");
    fprintf(fpasm, "\tpop dword eax\n\tpop dword ecx\n");

    if(es_variable_1)
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");

    if(es_variable_2)
        fprintf(fpasm, "\tmov dword eax, [eax]\n");

    fprintf(fpasm, "\timul ecx\n");
    fprintf(fpasm, "\tpush dword eax\n");
}

void dividir(FILE* fpasm, int es_variable_1, int es_variable_2){
    fprintf(fpasm, "\n;---Funcion dividir---\n");
    fprintf(fpasm, "\tpop dword ecx\n\tpop dword eax\n");

    if(es_variable_1)
        fprintf(fpasm, "\tmov dword eax, [eax]\n");

    if(es_variable_2)
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");

    fprintf(fpasm, "\tmov edx, 0\n");
    fprintf(fpasm, "\tcmp ecx, edx\n");
    fprintf(fpasm, "\tje near fin_error_division\n");

    fprintf(fpasm, "\tcdq\n");
    fprintf(fpasm, "\tidiv ecx\n");
    fprintf(fpasm, "\tpush dword eax\n");


}

void o(FILE* fpasm, int es_variable_1, int es_variable_2){
    fprintf(fpasm, "\n;---Funcion or---\n");
    fprintf(fpasm, "pop dword ecx\n\tpop dword eax\n");

    if(es_variable_1)
        fprintf(fpasm, "\tmov dword eax, [eax]\n");

    if(es_variable_2)
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");

    fprintf(fpasm, "\tor eax, ecx\n");
    fprintf(fpasm, "\tpush dword eax\n");
}

void y(FILE* fpasm, int es_variable_1, int es_variable_2){
    fprintf(fpasm, "\n;---Funcion and---\n");
    fprintf(fpasm, "\tpop dword eax\n\tpop dword ecx\n");

    if(es_variable_1)
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");

    if(es_variable_2)
        fprintf(fpasm, "\tmov dword eax, [eax]\n");

    fprintf(fpasm, "\tand eax, ecx\n");
    fprintf(fpasm, "\tpush dword eax\n");

}


void cambiar_signo(FILE* fpasm, int es_variable){

    fprintf(fpasm, "\n;---Funcion cambiar_signo---\n");
    fprintf(fpasm, "\tpop dword eax\n");

    if(es_variable)
        fprintf(fpasm, "\tmov dword eax, [eax]\n");

    fprintf(fpasm, "\tneg eax\n");
    fprintf(fpasm, "\tpush dword eax\n");
}

void no(FILE* fpasm, int es_variable, int cuantos_no){
    fprintf(fpasm, "\n;---Funcion no---\n");

    fprintf(fpasm, "\tpop dword ecx\n");
    if(es_variable)
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");

    fprintf(fpasm, "\tmov dword eax, 0\n");
    fprintf(fpasm, "\tcmp eax, ecx\n");
    fprintf(fpasm, "\tje near positivo_negativo%d\n",cuantos_no);

    fprintf(fpasm, "\tmov dword eax, 0\n");
    fprintf(fpasm, "\tpush dword eax\n");
    fprintf(fpasm, "\tjmp near continua_%d\n", cuantos_no);


    fprintf(fpasm, "\tpositivo_negativo%d:\n", cuantos_no);
    fprintf(fpasm, "\t\tmov dword eax, 1\n");
    fprintf(fpasm, "\t\tpush dword eax\n");
    fprintf(fpasm, "\tcontinua_%d:\n", cuantos_no);

}

void igual(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta){
    fprintf(fpasm, "\n;---Funcion igual---\n");
    fprintf(fpasm, "\tpop dword ecx\n\tpop dword eax\n");

    if(es_variable1)
        fprintf(fpasm, "\tmov dword eax, [eax]\n");

    if(es_variable2)
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");

    fprintf(fpasm, "\tcmp eax, ecx\n");
    fprintf(fpasm, "\tjz near true_%d\n", etiqueta);

    fprintf(fpasm, "\tmov dword eax, 0\n");
    fprintf(fpasm, "\tpush dword eax\n");
    fprintf(fpasm, "\tjmp near continua_%d\n", etiqueta);
    fprintf(fpasm,"\ttrue_%d:\n", etiqueta);
    fprintf(fpasm,"\t\tmov dword eax, 1\n");
    fprintf(fpasm, "\t\tpush dword eax\n");
    fprintf(fpasm, "\tcontinua_%d:\n", etiqueta);
}

void distinto(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta){
    fprintf(fpasm, "\n;---Funcion distinto---\n");
    fprintf(fpasm, "\tpop dword ecx\n\tpop dword eax\n");

    if(es_variable1)
        fprintf(fpasm, "\tmov dword eax, [eax]\n");

    if(es_variable2)
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");

    fprintf(fpasm, "\tcmp eax, ecx\n");
    fprintf(fpasm, "\tjnz near true_%d\n", etiqueta);

    fprintf(fpasm, "\tmov dword  eax, 0\n");
    fprintf(fpasm, "\tpush dword eax\n");
    fprintf(fpasm, "\tjmp near continua_%d\n", etiqueta);
    fprintf(fpasm,"\ttrue_%d:\n", etiqueta);
    fprintf(fpasm,"\t\tmov dword eax, 1\n");
    fprintf(fpasm, "\t\tpush dword eax\n");
    fprintf(fpasm, "\tcontinua_%d:\n", etiqueta);


}


void menor_igual(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta){
    fprintf(fpasm, "\n;---Funcion mayor_igual---\n");
    fprintf(fpasm, "\tpop dword ecx\n\tpop dword eax\n");

    if(es_variable1)
        fprintf(fpasm, "\tmov dword eax, [eax]\n");

    if(es_variable2)
        fprintf(fpasm, "\tmov dword dword ecx, [ecx]\n");

    fprintf(fpasm, "\tcmp eax, ecx\n");
    fprintf(fpasm, "\tjle near true_%d\n", etiqueta);
    fprintf(fpasm, "\tmov dword eax, 0\n");
    fprintf(fpasm, "\tpush dword eax\n");
    fprintf(fpasm, "\tjmp near continua_%d\n", etiqueta);
    fprintf(fpasm,"\ttrue_%d:\n", etiqueta);
    fprintf(fpasm,"\t\tmov dword eax, 1\n");
    fprintf(fpasm, "\t\tpush dword eax\n");
    fprintf(fpasm, "\tcontinua_%d:\n", etiqueta);

}

void mayor_igual(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta){

    fprintf(fpasm, "\n;---Funcion mayor_igual---\n");
    fprintf(fpasm, "\tpop dword ecx\n\tpop dword eax\n");

    if(es_variable1)
        fprintf(fpasm, "\tmov dword eax, [eax]\n");

    if(es_variable2)
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");

    fprintf(fpasm, "\tcmp eax, ecx\n");
    fprintf(fpasm, "\tjge near true_%d\n", etiqueta);
    fprintf(fpasm, "\tmov dword eax, 0\n");
    fprintf(fpasm, "\tpush dword eax\n");
    fprintf(fpasm, "\tjmp continua_%d\n", etiqueta);
    fprintf(fpasm,"\ttrue_%d:\n", etiqueta);
    fprintf(fpasm,"\t\tmov dword eax, 1\n");
    fprintf(fpasm, "\t\tpush dword eax\n");
    fprintf(fpasm, "\tcontinua_%d:\n", etiqueta);


}

void menor(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta){
    fprintf(fpasm, "\n;---Funcion menor---\n");
    fprintf(fpasm, "\tpop dword ecx\n\tpop dword eax\n");

    if(es_variable1)
        fprintf(fpasm, "\tmov dword eax, [eax]\n");

    if(es_variable2)
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");

    fprintf(fpasm, "\tcmp eax, ecx\n");
    fprintf(fpasm, "\tjl near true_%d\n", etiqueta);
    fprintf(fpasm, "\tmov dword eax, 0\n");
    fprintf(fpasm, "\tpush dword eax\n");
    fprintf(fpasm, "\tjmp near continua_%d\n", etiqueta);
    fprintf(fpasm,"\ttrue_%d:\n", etiqueta);
    fprintf(fpasm,"\t\tmov dword eax, 1\n");
    fprintf(fpasm, "\t\tpush dword eax\n");
    fprintf(fpasm, "\tcontinua_%d:\n", etiqueta);

}

void mayor(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta){
    fprintf(fpasm, "\n;---Funcion mayor---\n");
    fprintf(fpasm, "\tpop dword ecx\n\tpop dword eax\n");

    if(es_variable1)
        fprintf(fpasm, "\tmov dword eax, [eax]\n");

    if(es_variable2)
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");

    fprintf(fpasm, "\tcmp eax, ecx\n");
    fprintf(fpasm, "\tjg near true_%d\n", etiqueta);
    fprintf(fpasm, "\tmov dword eax, 0\n");
    fprintf(fpasm, "\tpush dword eax\n");
    fprintf(fpasm, "\tjmp near continua_%d\n", etiqueta);
    fprintf(fpasm,"\ttrue_%d:\n", etiqueta);
    fprintf(fpasm,"\t\tmov dword eax, 1\n");
    fprintf(fpasm, "\t\tpush dword eax\n");
    fprintf(fpasm, "\tcontinua_%d:\n", etiqueta);
}


void leer(FILE* fpasm, char* nombre, int tipo){
    fprintf(fpasm, "\n;---Funcion leer---\n");
    fprintf(fpasm, "\tpush dword _%s\n", nombre);/*****/

    if(tipo == ENTERO)
        fprintf(fpasm, "\tcall scan_int\n");
    else
        fprintf(fpasm, "\tcall scan_boolean\n");

    fprintf(fpasm, "\tadd esp, 4\n");

}

void leer_exp_pila(FILE* fpasm, char* nombre, int tipo){
    fprintf(fpasm, "\n;---Funcion leer---\n");

    if(tipo == ENTERO)
        fprintf(fpasm, "\tcall scan_int\n");
    else
        fprintf(fpasm, "\tcall scan_boolean\n");

    fprintf(fpasm, "\tadd esp, 4\n");

}

void escribir(FILE* fpasm, int es_variable, int tipo){

    fprintf(fpasm, "\n;---Funcion escribir---\n");

    if(es_variable){
    	fprintf(fpasm, "\tpop dword eax\n");
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
    	fprintf(fpasm, "\tpush dword eax\n");
	}
    if(tipo == ENTERO)
        fprintf(fpasm, "\tcall print_int\n");
    else
        fprintf(fpasm, "\tcall print_boolean\n");

    fprintf(fpasm, "\tadd esp, 4\n");
	fprintf(fpasm, "\tcall print_endofline\n");
}

void ifthen_inicio(FILE * fpasm, int exp_es_variable, int etiqueta){
  fprintf(fpasm, "\n;---Funcion ifthen_inicio---\n");
  fprintf(fpasm,"\tpop eax\n");
  if(exp_es_variable)
    fprintf(fpasm,"\tmov eax , [eax]\n");
  fprintf(fpasm,"\tcmp eax, 0\n");
  fprintf(fpasm,"\tje near fin_si%d\n",etiqueta );

}

void ifthen_fin(FILE* fpasm,int etiqueta){
  fprintf(fpasm, "\n;---Funcion ifthen_fin---\n");
  fprintf(fpasm,"fin_si%d:\n", etiqueta);
}


void ifthenelse_fin_then( FILE * fpasm, int etiqueta){
  fprintf(fpasm, "\n;---Funcion ifthenelse_fin_then---\n");
  fprintf(fpasm,"jmp near fin_sino%d\n", etiqueta);
  ifthen_fin(fpasm, etiqueta);

}

void ifthenelse_fin( FILE * fpasm, int etiqueta){
  fprintf(fpasm, "\n;---Funcion ifthenelse_fin---\n");
  fprintf(fpasm,"fin_sino%d:\n", etiqueta);
}

void while_inicio(FILE * fpasm, int etiqueta){
  fprintf(fpasm,"\n;---Funcion while_inicio---\n");
  fprintf(fpasm,"inicio_while%d:\n", etiqueta);
}

void while_exp_pila (FILE * fpasm, int exp_es_variable, int etiqueta){
  fprintf(fpasm, "\n;---Funcion while_exp_pila---\n");
  fprintf(fpasm,"\tpop eax\n");
  if(exp_es_variable)
    fprintf(fpasm,"\tmov eax , [eax]\n");
  fprintf(fpasm,"\tcmp eax, 0\n");
  fprintf(fpasm,"\tje near fin_while%d\n",etiqueta );

}

void while_fin( FILE * fpasm, int etiqueta){
  fprintf(fpasm, "\n;---Funcion while_fin---\n");
  fprintf(fpasm,"jmp near inicio_while%d\n", etiqueta);
  fprintf(fpasm,"fin_while%d:\n", etiqueta);
}

void escribir_elemento_vector(FILE * fpasm,char * nombre_vector, int tam_max, int exp_es_direccion){
  fprintf(fpasm,"\tpop dword eax\n");
  if(exp_es_direccion == 1)
    fprintf(fpasm,"\tmov dword eax, [eax]\n");
  fprintf(fpasm,"\tcmp eax,0\n");
  fprintf(fpasm,"\tjl near mensaje_1\n");

  fprintf(fpasm,"\tcmp eax, %d\n", tam_max-1);
  fprintf(fpasm,"\tjg near mensaje_1\n");
  fprintf(fpasm,"\tmov dword edx, _%s\n", nombre_vector);
  fprintf(fpasm,"\tlea eax, [edx + eax*4]\n");
  fprintf(fpasm,"\tpush dword eax\n");






}
