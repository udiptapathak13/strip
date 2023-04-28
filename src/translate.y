%{

#include <stdlib.h>
#include <stdint.h>
#include <strip/token.h>
#include <strip/opcode.h>
#include <strip/imc.h>
#include <strip/symbol.h>
#include <strip/primitive.h>
#include <strip/panic.h>

#ifndef MALLOC
#define MALLOC(x,y) (x *) malloc(y * sizeof(x))
#endif

int dataCnt = 0;
int textCnt = 0;

extern int row;
extern int col;
extern int yyleng;

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

char *opcodeString[31];

int main(int argc, char *argv[])
{
	if (argc != 2) {
		printf("usage: strip <file_name>\x0a");
		exit(EXIT_FAILURE);
	}
	if (!freopen(argv[1], "r", stdin))
		panic(E_FAILED_TO_OPEN_FILE);
	initOpcStr();
	global = symbolCreate();
	yyparse();
	printf("Compilation Successful!\x0a");
	symbolDestroy(global);
	imcDump("out");
	imcLog("log");
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

%expect 6

%union
{
	struct {
		int ref;
		int dtype;
		uint64_t val;
	} expr;
	struct {
		int dtype;
		int row;
		int col;
		uint64_t addr;
		char name[32];
	} id;
	struct {
		int row;
		int col;
	} pos;
}

%type <expr> expr
%type <pos> pos

%%

start
	: blocks YYEOF
	;

blocks
	: block blocks
	| letBlock blocks
	| %empty
	;

block
	: statements ';' 
	;

statements
	: statement statements
	| %empty
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
	: pos ID '=' expr ';'
	{
	Token t;
	t.id = tok_id;
	t.row = $1.row;
	t.col = $1.col;
	t.addr = dataCnt++;
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
		} else if ($1.ref == lval && $3.ref == rval) {
			imcAdd(op_load, $1.val, 0);
			imcAdd(op_sub, $1.val, $3.val);
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
	| pos '(' expr ')'
	{
		$$ = $3;
	}
	| pos '(' expr %expect 6
	{
		printf("%d %d\x0a", $1.row, $1.col);
		panic(E_UNMATCHED_PARENTHESIS);
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
		$$.ref = lval;
	}
	;

pos
	: %empty
	{
		$$.row = row;
		$$.col = col - yyleng;
	}
	;