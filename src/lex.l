%{

#include "y.tab.h"
#include <strip/primitive.h>
#include <strip/token.h>
#include <strip/panic.h>

int row = 1, col = 1;

%}

small	[a-z]
big	[A-Z]
alpha	{small}|{big}
digit	[0-9]
alnum	{alpha}|{digit}
n_dec	{digit}*
ws	[ \t]
nl	\n
binop	[\+\-\*/\%]
delim	[{}\[\]()=;]
id	({alpha}|[_'])({alnum}|[_'])*
str	({alnum}|{delim}|{ws}|{binop})*
bool	true|false

%%

{n_dec} {
	col += yyleng;
	yylval.aexpr.ref = rval;
	yylval.aexpr.dtype = u64;
	yylval.aexpr.val = atoi(yytext);
	return NUM;
}

{ws} {
	col++;
}

{nl} {
	row++;
	col = 1;
}

{binop} {
	col += yyleng;
	return yytext[0];
}

"<" {
	col += 2;
	return '<';
}

">" {
	col += 2;
	return '>';
}

"<=" {
	col += 2;
	return LE;
}

">=" {
	col += 2;
	return GE;
}

"==" {
	col += 2;
	return EQ;
}

"!=" {
	col += 2;
	return NE;
}

"&&"	{
	col += 2;
	return AND;
}

"||"	{
	col += 2;
	return OR;
}

'{str}' {
	col += yyleng;
}

\'{str} {	
	panic(E_UNTERMINATED_STRING);
}

{delim} {
	col++;
	return yytext[0];
}

<<EOF>> {
	return YYEOF;
}

let {
	col += yyleng;
	return LET;
}

if {
	col += yyleng;
	return IF;
}

elif {
	col += yyleng;
	return ELIF;
}

else {
	col += yyleng;
	return ELSE;
}

bool {
	return yytext[0] == 't';
}

loop {
	return LOOP;
}

break {
	return BRK; 
}

continue {
	return CNT;
}


{id}	{
	strcpy(yylval.id.name, yytext);
	yylval.id.row = row;
	yylval.id.col = col;
	col += yyleng;
	return ID;
}

.	{
	fprintf(stderr, "\x1b[31merror: \x1b[0m"
		"found an invalid token \x27%s\x27\x0a", yytext);
	exit(EXIT_FAILURE);
}
