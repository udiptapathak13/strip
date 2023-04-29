%{

#include <stdlib.h>
#include <stdint.h>
#include <strip/token.h>
#include <strip/opcode.h>
#include <strip/imc.h>
#include <strip/symbol.h>
#include <strip/primitive.h>
#include <strip/panic.h>
#include <strip/backpatch.h>

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
%token IF
%token ELIF
%token ELSE
%token GE
%token LE
%token EQ
%token NE
%token AND
%token OR

%left LE GE EQ NE '<' '>'
%left '!' AND OR
%left '-' '+'
%left '*' '/' '%'

%union
{
	struct {
		int ref;
		int dtype;
		uint32_t addr;
		uint64_t val;
	} aexpr;
	struct {
		uint32_t addr;
		char name[32];
		int row;
		int col;
	} id;
	struct {
		uint32_t addr;
	} pos;
	struct {
		void *trueList;
		void *falseList;
		int ref;
		int val;
	} bexpr;
	struct {
		void *blist;
	} condBody;
} 

%type <aexpr> aexpr
%type <bexpr> bexpr
%type <pos> pos
%type <id> id
%type <condBody> condBody elifBlock

%%

start
	: body YYEOF
	;

block
	: '{' body '}'
	;

body
	: statement body
	| letBlock body
	| ifBlock body
	| block body
	|
 	;

statement
	: aexpr ';'
	;

letBlock
	: LET '{' letStatements '}'
	;

letStatements
	: letStatement letStatements
	| letStatement
	;

letStatement
	: id '=' aexpr ';'
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

aexpr
	: aexpr '-' aexpr
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
	| aexpr '+' aexpr
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
	| aexpr '*' aexpr
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
	| aexpr '/' aexpr
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
	| aexpr '%' aexpr
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
	| '(' aexpr ')'
	{
	$$ = $2;
	}
	| NUM
	{
	$$.ref = yylval.aexpr.ref;
	$$.dtype = yylval.aexpr.dtype;
	$$.val = yylval.aexpr.val;
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

bexpr
	: bexpr AND pos bexpr
	{
	$$.trueList = $4.trueList;
	$$.falseList = BlistMerge($1.falseList, $4.falseList);
	BlistPatch($1.trueList, $3.addr);
	}
	| bexpr OR bexpr
	| '!' bexpr
	{
	$$ = $2;
	}
	| aexpr '>' aexpr
	{
	$$.trueList = 0;
	$$.falseList = 0;
	}
	| aexpr LE aexpr
	{
	fflush(stdout);
	if ($1.ref == lval)
		if($1.addr < dataEndp)
			imcAdd(op_load, $1.addr, 0);
		else
			imcAdd(op_mov, $1.addr, 0);
	else
		imcAdd(op_movi, $1.val, 0);
	if ($3.ref == lval)
		if($3.addr < dataEndp)
			imcAdd(op_load, $3.addr, 0);
		else
			imcAdd(op_mov, $3.addr, 0);
	else
		imcAdd(op_movi, $3.val, 0);
	imcAdd(op_ge, textCnt + 1, textCnt);
	$$.val = textCnt + 2;
	imcAdd(op_jmpif, 0, 0);
	$$.trueList = BlistCreate(textCnt + 3);
	imcAdd(op_jmpifn, 0, 0);
	$$.falseList = BlistCreate(textCnt + 4);
	textCnt += 5;
	}
	| aexpr '<' aexpr
	{
	$$.trueList = 0;
	$$.falseList = 0;
	}
	| aexpr GE aexpr
	{
	$$.trueList = 0;
	$$.falseList = 0;
	}
	| aexpr EQ aexpr
	{
	$$.trueList = 0;
	$$.falseList = 0;
	}
	| aexpr NE aexpr
	{
	$$.trueList = 0;
	$$.falseList = 0;
	}
	| '(' bexpr ')'
	{
	$$.trueList = 0;
	$$.falseList = 0;
	}
	;

ifBlock
	: IF bexpr pos '{' condBody pos '}' elifBlock pos
	{
	BlistPatch($2.trueList, $3.addr);
	BlistPatch($2.falseList, $6.addr);
	BlistPatch($5.blist, $9.addr);
	}
	;

condBody
	: body
	{
	$$.blist = BlistCreate(textCnt);
	imcAdd(op_jmp, 0, 0);
	textCnt++;
	}
	;

elifBlock
	: ELIF bexpr pos '{' condBody  pos '}' elifBlock
	{
	$$.blist = BlistMerge($5.blist, $8.blist);
	BlistPatch($2.trueList, $3.addr);
	BlistPatch($2.falseList, $6.addr);
	}
	| ELSE '{' body '}'
	{
	$$.blist = NULL;
	}
	|
	{
	$$.blist = NULL;
	}
	;

pos
	:
	{
	$$.addr = textCnt;
	}
	;