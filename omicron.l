%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "omicron.h"
#include "y.tab.h"

#define MAX_LONG_ID 50

FILE* salida;
int columna = 1;
int line =1;
%}



%option noyywrap

IDENTIFICADOR [A-Za-z][A-Za-z0-9]*
ENTERO [0-9]+

SIMBOLOS ";"|"#"|","|"="|"("|")"|"["|"]"|"{"|"}"|":"|"+"|"-"|"/"|"*"|"<"|">"|"&"|"!"|"."|","
ERROR (.)
COMENTARIO "//"(.)*(\n)
ESPACIO [ ]
TAB [\t]
SALTO [\n]


%%

none			{fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_NONE;}
class       {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_CLASS;}
inherits    {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_INHERITS;}
instance_of {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_INSTANCE_OF;}
discard     {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_DISCARD;}
itself      {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_ITSELF;}
->          {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_FLECHA;}
hidden      {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_HIDDEN;}
secret      {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_SECRET;}
exposed     {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_EXPOSED;}
unique      {fprintf(salida,";D:\t%s\n",yytext);columna += yyleng; return TOK_UNIQUE;}

function    {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_FUNCTION;}
return      {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_RETURN;}
main        {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_MAIN;}
int         {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_INT;}
boolean     {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_BOOLEAN;}
array       {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_ARRAY;}
if          {
					fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;

					return TOK_IF;
				}
else        {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_ELSE;}
while       {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_WHILE;}
scanf       {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_SCANF;}
printf      {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_PRINTF;}

"=="					{fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_IGUAL;}
"!="					{fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_DISTINTO;}
"<="					{fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_MENORIGUAL;}
">="					{fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_MAYORIGUAL;}
"||"					{fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_OR;}
"&&"					{fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					return TOK_AND;}

{ENTERO}		{fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					strcpy(yylval.atributos.lexema,yytext);
					yylval.atributos.valor_entero = atoi(yytext);
					return TOK_CONSTANTE_ENTERA;}
false       {fprintf(salida,";D:\t%s\n",yytext);
						strcpy(yylval.atributos.lexema,yytext);
					columna += yyleng;
					return TOK_FALSE;}
true        {fprintf(salida,";D:\t%s\n",yytext);
					columna += yyleng;
					strcpy(yylval.atributos.lexema,yytext);
					
					return TOK_TRUE;}


{IDENTIFICADOR} {
	if (yyleng > MAX_LONG_ID){
		printf("ERROR MORFOLÓGICO: %d>:%d :IDENTIFICADOR DEMASIADO LARGO (<%s>)\n", line, columna, yytext);
		fprintf(salida,";D:\t%s\n",yytext);
		columna += yyleng;
		return TOK_ERROR;

	}

	else{
		fprintf(salida,";D:\t%s\n",yytext);
		columna += yyleng;
		/*profe*/
		strcpy(yylval.atributos.lexema, yytext);
		return TOK_IDENTIFICADOR;}

 }

{SIMBOLOS} {fprintf(salida,";D:\t%s\n",yytext); columna += yyleng; return yytext[0];}
{ESPACIO}  {columna++;}
{TAB}		{columna++;}
{SALTO}		{columna = 1; line++;}
{COMENTARIO} {columna = 1; line++;}

{ERROR}		{fprintf(salida,";D:\t%s\n",yytext);
			printf("ERROR MORFOLÓGICO: %d:%d :CARÁCTER INVÁLIDO (%s)\n", line, columna, yytext);
			columna += yyleng;
			return TOK_ERROR;}



%%
