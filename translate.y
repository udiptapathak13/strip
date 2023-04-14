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
	freopen(argv[1], "r", stdin);
	if (!stdin) {
		printf("Failed to open the file %s\x0a", argv[1]);
		exit(EXIT_FAILURE);
	}
	yyparse();
	return 0;
}

%}

%token NUM

%%

start
	: NUM YYEOF
	{
	printf("Compilation Successful!\x0a");	
	}
	;
