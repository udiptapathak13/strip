%{

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <strip/token.h>

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
	#ifdef _A_H
	printf("Included\x0a");
	#endif
	if (argc != 2) {
		printf("usage: strip <file_name>\x0a");
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

%token NUM
%token ID

%left '-'
%left '+'
%left '*'
%left '/'
%left '%'

%union
{
	struct {
		int ref;
		int dtype;
		uint64_t val;
	} expr;
}

%type <expr> expr

%%

start
	: block YYEOF
	{
	printf("Compilation Successful!\x0a");	
	}
	;

block
	: statement ';' 
	;

statement
	: expr ';'
	;

expr
	: expr '-' expr
	{
		if ($1.ref == rval && $3.ref == rval) {
			$$.ref = rval;
			$$.val = $1.val - $3.val;
		}
	}
	| expr '+' expr
	{
		if ($1.ref == rval && $3.ref == rval) {
			$$.ref = rval;
			$$.val = $1.val + $3.val;
		}
	}
	| expr '*' expr
	{
		if ($1.ref == rval && $3.ref == rval) {
			$$.ref = rval;
			$$.val = $1.val * $3.val;
		}
	}
	| expr '/' expr
	{
		if ($1.ref == rval && $3.ref == rval) {
			$$.ref = rval;
			$$.val = $1.val / $3.val;
		}
	}
	| expr '%' expr
	{
		if ($1.ref == rval && $3.ref == rval) {
			$$.ref = rval;
			$$.val = $1.val % $3.val;
		}
	}
	| '(' expr ')'
	{
		$$ = $2;
	}
	| NUM
	{
		$$.ref = yylval.expr.ref;
		$$.dtype = yylval.expr.dtype;
		$$.val = yylval.expr.val;
	}
	;
