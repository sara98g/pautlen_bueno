#include <stdio.h>
#include <string.h>

#include "omicron.h"
#include "generacion.h"
#include "estructuras.h"

extern int yyparse();
extern void yyerror(char *e);

extern FILE *yyin;
extern FILE *salida;

tablaSimbolosAmbitos *tsa;


int main(int argc, char** argv)
{


    if (argc != 3) {
      fprintf (stdout, "Error de argumentos: ./pruebaSintactico entrada salida\n");
      return -1;
    }

    salida = fopen(argv[2],"w");
    if(!salida){
        fprintf(stdout,"No se pudo abrir el fichero de salida \n");
    }
    yyin =fopen(argv[1],"r");
    if(!yyin){
        fprintf(stdout,"No se pudo abrir el fichero de entrada \n");
        return 1;
    }

    tsa = iniciarTablaSimbolosAmbitos();
    if(tsa == NULL){
      printf("Error al iniciar TSA");
      exit(-1);
}
    if (abrirAmbitoPpalMain(tsa, "main")==ERROR){
      printf("Error al abrir el ambito main");
      exit(-1);
    }
     do
    {
        yyparse();
    }while (!feof(yyin));

    cerrarAmbitoMain(tsa);
    destruirTablaSimbolosAmbitos(tsa);
    //¿tsc?

    fclose(yyin);
    fclose(salida);
    return 0;

}
