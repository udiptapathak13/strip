%{

#include <stdio.h>
#include <stdlib.h>

int yyparse();
int yylex();

void yyerror(const char *e)
{
	printf("Compilation Failed!\x0a");
	exit(EXIT_FAILURE);
}

int yywrap()
{
	return 1;
}

int main(int argc, char *argv[])
{
	if (argc != 2) {
		printf("usage: ./strip <file_name>\x0a");
		exit(EXIT_FAILURE);
	}
	if (!freopen(argv[1], "r", stdin)) {
		printf("failed to open the file %s\x0a", argv[1]);
		exit(EXIT_FAILURE);
	}
	yyparse();
	return 0;
}

%}

%token NUMERIC

%%

start
	: expr YYEOF
	{
	printf("Compilation Successful!\x0a");	
	}
	;

expr
	: expr '+' term
	| expr '-' term
	| term
	;

term
	: term '*' factor
	| term '/' factor
	| factor
	;

factor
	: '(' expr ')'
	| NUMERIC
	;
