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
#include <strip/mio.h>
#include <strip/block.h>

#ifndef MALLOC
#define MALLOC(x,y) (x *) malloc(y * sizeof(x))
#endif

int dataCnt = 16;
int textCnt = 1 << 16;

extern int row;
extern int col;
extern int yyleng;

extern Imc imc;

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
%token LOOP
%token CNT
%token BRK
 
%left LE GE EQ NE '<' '>'
%left '!' AND OR
%left '-' '+'
%left '*' '/' '%'

%union
{
	struct {
		int ref;
		int dtype;
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
%type <bexpr> bexpr loopBody
%type <pos> pos
%type <id> id
%type <condBody> condBody elifBlock brk

%%

start
	: body YYEOF
	;

block
	: '{' body '}'
	| letBlock
	| ifBlock
	| loopBlock
	;

body
	: statement body
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
		imcAexpr(op_sub, $1.ref, $3.ref, $1.val, $3.val);
		$$.ref = lval;
		$$.val = imc.last - 1;
	}
	}
	| aexpr '+' aexpr
	{
	if ($1.ref == rval && $3.ref == rval) {
		$$.ref = rval;
		$$.val = $1.val + $3.val;
	} else {
		imcAexpr(op_add, $1.ref, $3.ref, $1.val, $3.val);
		$$.ref = lval;
		$$.val = imc.last - 1;
	}
	}
	| aexpr '*' aexpr
	{
	if ($1.ref == rval && $3.ref == rval) {
		$$.ref = rval;
		$$.val = $1.val * $3.val;
	} else {
		imcAexpr(op_mul, $1.ref, $3.ref, $1.val, $3.val);
		$$.ref = lval;
		$$.val = imc.last - 1;
	}
	}
	| aexpr '/' aexpr
	{
	if ($1.ref == rval && $3.ref == rval) {
		$$.ref = rval;
		$$.val = $1.val / $3.val;
	} else {
		imcAexpr(op_div, $1.ref, $3.ref, $1.val, $3.val);
		$$.ref = lval;
		$$.val = imc.last - 1;
	}
	}
	| aexpr '%' aexpr
	{
	if ($1.ref == rval && $3.ref == rval) {
		$$.ref = rval;
		$$.val = $1.val % $3.val;
	} else {
		imcAexpr(op_div, $1.ref, $3.ref, $1.val, $3.val);
		$$.ref = lval;
		$$.val = imc.last - 1;
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
	}
	| id
	{
	Token *t;
	if (!(t = symbolMember(global, $1.name))) {
		fprintf(stderr, "\x1b[31merror:\x1b[0m %s is not defined\x0a",
		$1.name);
		exit(EXIT_FAILURE);
	}
	$$.ref = lval;
	$$.val = t->addr;
	}
	;

bexpr
	: bexpr AND pos bexpr
	{
	$$.trueList = $4.trueList;
	$$.falseList = BlistMerge($1.falseList, $4.falseList);
	BlistPatch($1.trueList, $3.addr);
	}
	| bexpr OR pos bexpr
	{
	$$.falseList = $4.falseList;
	$$.trueList = BlistMerge($1.trueList, $4.trueList);
	BlistPatch($1.falseList, $3.addr);
	}
	| '!' bexpr
	{
	$$.trueList = $2.falseList;
	$$.falseList = $2.trueList;
	$$.val = $2.val;
	$$.ref = $2.ref;
	}
	| aexpr '>' aexpr
	{
	imcAexpr(op_gr, $1.ref, $3.ref, $1.val, $3.val);
	$$.val = imc.last;
	$$.trueList = BlistCreate(imc.last);
	imcAdd(op_jmpif, 0, 0);
	$$.falseList = BlistCreate(imc.last);
	imcAdd(op_jmpifn, 0, 0);
	}
	| aexpr LE aexpr
	{
	imcAexpr(op_ge, $3.ref, $1.ref, $3.val, $1.val);
	$$.val = imc.last;
	$$.trueList = BlistCreate(imc.last);
	imcAdd(op_jmpif, 0, 0);
	$$.falseList = BlistCreate(imc.last);
	imcAdd(op_jmpifn, 0, 0);
	}
	| aexpr '<' aexpr
	{
	imcAexpr(op_gr, $3.ref, $1.ref, $3.val, $1.val);
	$$.val = imc.last;
	$$.trueList = BlistCreate(imc.last);
	imcAdd(op_jmpif, 0, 0);
	$$.falseList = BlistCreate(imc.last);
	imcAdd(op_jmpifn, 0, 0);
	}
	| aexpr GE aexpr
	{

	imcAexpr(op_ge, $1.ref, $3.ref, $1.val, $3.val);
	$$.val = imc.last;
	$$.trueList = BlistCreate(imc.last);
	imcAdd(op_jmpif, 0, 0);
	$$.falseList = BlistCreate(imc.last);
	imcAdd(op_jmpifn, 0, 0);
	}
	| aexpr EQ aexpr
	{
	imcAexpr(op_eq, $1.ref, $3.ref, $1.val, $3.val);
	$$.val = imc.last;
	$$.trueList = BlistCreate(imc.last);
	imcAdd(op_jmpif, 0, 0);
	$$.falseList = BlistCreate(imc.last);
	imcAdd(op_jmpifn, 0, 0);
	}
	| aexpr NE aexpr
	{

	imcAexpr(op_neq, $1.ref, $3.ref, $1.val, $3.val);
	$$.val = imc.last;
	$$.trueList = BlistCreate(imc.last);
	imcAdd(op_jmpif, 0, 0);
	$$.falseList = BlistCreate(imc.last);
	imcAdd(op_jmpifn, 0, 0);
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

loopBlock
	: LOOP pos '{' loopBody pos '}' pos
	{
	imcAdd(op_jmp, $2.addr, 0);
	Blist *blist = BlistMerge(BlistCreate(imc.last - 1), $4.trueList);
	BlistPatch(blist, $2.addr);
	BlistPatch($4.falseList, $5.addr);
	}

loopBody
	: statement loopBody
	{
	$$ = $2;
	}
	| block loopBody
	{
	$$ = $2;
	}
	| CNT ';' loopBody
	{
	imcAdd(op_jmp, 0, 0);
	$$.trueList = BlistMerge($$.trueList, BlistCreate(textCnt)); 
	textCnt++;
	}
	| pos brk ';' loopBody
	{
	$$.falseList = BlistMerge($4.falseList, BlistCreate($1.addr)); 
	$$.trueList = $4.trueList;
	}
	|
	{
	$$.trueList = NULL;
	$$.falseList = NULL;
	}
	;

brk
	: BRK
	{
	imcAdd(op_jmp, 0, 0);
	}

pos
	:
	{
	$$.addr = imc.last;
	}
	;