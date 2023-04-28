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

int dataCnt = 16;
int textCnt = 1 << 16;

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

%left '-' '+'
%left '*' '/' '%'

%expect 6

%union
{
	struct {
		int ref;
		int dtype;
		uint32_t addr;
		uint64_t val;
	} expr;
	struct {
		uint32_t addr;
		char name[32];
		int row;
		int col;
	} id;
	struct {
		int row;
		int col;
	} pos;
}

%type <expr> expr
%type <pos> pos
%type <id> id

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
	: id '=' expr ';'
	{
	Token t;
	t.id = tok_id;
	t.row = $1.row;
	t.col = $1.col;
	t.attr.num.dtype = u64;
	t.attr.num.mut = false;
	t.addr = dataCnt++;
	symbolInsert(global, $1.name, t);
	}
	;

id
	: ID
	{
	strcpy($$.name, yylval.id.name);
	$$.col = yylval.id.col;
	$$.row = yylval.id.row;
	}
	;

expr
	: expr '-' expr
	{
	if ($1.ref == rval && $3.ref == rval) {
		$$.ref = rval;
		$$.val = $1.val - $3.val;
	} else {
		if ($1.ref == lval)
			$1.addr < dataEndp?
			imcAdd(op_load, $1.addr, 0):
			imcAdd(op_mov, $1.addr, 0);
		else
			imcAdd(op_movi, $1.val, 0);
		if ($3.ref == lval)
			$1.addr < dataEndp?
			imcAdd(op_load, $3.addr, 0):
			imcAdd(op_mov, $3.addr, 0);
		else
			imcAdd(op_movi, $3.val, 0);
		imcAdd(op_sub, textCnt, textCnt + 1);
		textCnt += 3;
		$$.ref = lval;
		$$.addr = textCnt - 1;
	}
	}
	| expr '+' expr
	{
	if ($1.ref == rval && $3.ref == rval) {
		$$.ref = rval;
		$$.val = $1.val + $3.val;
	} else {
		if ($1.ref == lval)
			$1.addr < dataEndp?
			imcAdd(op_load, $1.addr, 0):
			imcAdd(op_mov, $1.addr, 0);
		else
			imcAdd(op_movi, $1.val, 0);
		if ($3.ref == lval)
			$1.addr < dataEndp?
			imcAdd(op_load, $3.addr, 0):
			imcAdd(op_mov, $3.addr, 0);
		else
			imcAdd(op_movi, $3.val, 0);
		imcAdd(op_add, textCnt, textCnt + 1);
		textCnt += 3;
		$$.ref = lval;
		$$.addr = textCnt - 1;
	}
	}
	| expr '*' expr
	{
	if ($1.ref == rval && $3.ref == rval) {
		$$.ref = rval;
		$$.val = $1.val * $3.val;
	} else {
		if ($1.ref == lval)
			$1.addr < dataEndp?
			imcAdd(op_load, $1.addr, 0):
			imcAdd(op_mov, $1.addr, 0);
		else
			imcAdd(op_movi, $1.val, 0);
		if ($3.ref == lval)
			$1.addr < dataEndp?
			imcAdd(op_load, $3.addr, 0):
			imcAdd(op_mov, $3.addr, 0);
		else
			imcAdd(op_movi, $3.val, 0);
		imcAdd(op_mul, textCnt, textCnt + 1);
		textCnt += 3;
		$$.ref = lval;
		$$.addr = textCnt - 1;
	}
	}
	| expr '/' expr
	{
	if ($1.ref == rval && $3.ref == rval) {
		$$.ref = rval;
		$$.val = $1.val / $3.val;
	} else {
		if ($1.ref == lval)
			$1.addr < dataEndp?
			imcAdd(op_load, $1.addr, 0):
			imcAdd(op_mov, $1.addr, 0);
		else
			imcAdd(op_movi, $1.val, 0);
		if ($3.ref == lval)
			$1.addr < dataEndp?
			imcAdd(op_load, $3.addr, 0):
			imcAdd(op_mov, $3.addr, 0);
		else
			imcAdd(op_movi, $3.val, 0);
		imcAdd(op_div, textCnt, textCnt + 1);
		textCnt += 3;
		$$.ref = lval;
		$$.addr = textCnt - 1;
	}
	}
	| expr '%' expr
	{
	if ($1.ref == rval && $3.ref == rval) {
		$$.ref = rval;
		$$.val = $1.val % $3.val;
	} else {
		if ($1.ref == lval)
			$1.addr < dataEndp?
			imcAdd(op_load, $1.addr, 0):
			imcAdd(op_mov, $1.addr, 0);
		else
			imcAdd(op_movi, $1.val, 0);
		if ($3.ref == lval)
			$1.addr < dataEndp?
			imcAdd(op_load, $3.addr, 0):
			imcAdd(op_mov, $3.addr, 0);
		else
			imcAdd(op_movi, $3.val, 0);
		imcAdd(op_mod, textCnt, textCnt + 1);
		textCnt += 3;
		$$.ref = lval;
		$$.addr = textCnt - 1;
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
	$$.addr = 0;
	}
	| id
	{
	Token *t;
	if (!(t = symbolMember(global, $1.name))) {
		fprintf(stderr, "\x1b[31merror:\x1b[0m %s is not denfined\x0a",
		$1.name);
		exit(EXIT_FAILURE);
	}
	$$.ref = lval;
	$$.addr = t->addr;
	}
	;

pos
	: %empty
	{
	$$.row = row;
	$$.col = col - yyleng;
	}
	;