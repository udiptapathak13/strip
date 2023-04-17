%{

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <strip/token.h>
#include <strip/opcode.h>
#include <strip/imc.h>
#include <strip/symbol.h>
#include <strip/primitive.h>

#ifndef MALLOC
#define MALLOC(x,y) (x *) malloc(y * sizeof(x))
#endif

int dataCnt = 0, textCnt = 0;

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

Symbol *global;

int main(int argc, char *argv[])
{
	if (argc != 2) {
		printf("usage: strip <file_name>\x0a");
		exit(EXIT_FAILURE);
	}
	if (!freopen(argv[1], "r", stdin)) {
		printf("failed to open the file %s\x0a", argv[1]);
		exit(EXIT_FAILURE);
	}
	global = symbolCreate();
	yyparse();
	return 0;
}

%}

%token NUM
%token ID
%token LET

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
	struct {
		int dtype;
		uint64_t addr;
		char name[32];
	} id;
}

%type <expr> expr

%%

start
	: blocks YYEOF
	{
	printf("Compilation Successful!\x0a");	
	symbolDestroy(global);
	}
	;

blocks
	: block blocks
	| letBlock blocks
	|
	;

block
	: statements ';' 
	;

statements
	: statement statements
	|
	;

statement
	: expr ';'
	;

letBlock
	: LET letStatements ';'
	;

letStatements
	: letStatement letStatements
	| letStatement
	;

letStatement
	: ID '=' expr ';'
	{
	Token t;
	t.id = tok_id;
	t.attr.num.dtype = u64;
	t.attr.num.mut = false;
	t.addr = dataCnt++;
	symbolInsert(global, yylval.id.name, t);
	}
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
	| ID
	{
		if (!symbolMember(global, yylval.id.name)) {
			fprintf(stderr, "\x1b[31merror:\x1b[0m %s is not denfined\x0a",
																	yylval.id.name);
			exit(EXIT_FAILURE);
		}
	}
	;
