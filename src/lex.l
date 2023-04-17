%{

#include "y.tab.h"
#include <strip/primitive.h>
#include <strip/token.h>

void panic(const char *, const char *);

%}

small	[a-z]
big	[A-Z]
alpha	{small}|{big}
digit	[0-9]
alnum	{alpha}|{digit}
n_dec	{digit}*
ws	[ \t\n]
binop	[\+\-\*/\%]
delim	[{}\[\]()=;]
id	({alpha}|[_'])({alnum}|[_'])*

%%

{n_dec}	{
	yylval.expr.ref = rval;
	yylval.expr.dtype = u64;
	yylval.expr.val = atoi(yytext);
	return NUM;
	}

{ws}	{}

{binop}	{
	return yytext[0];
	}

{delim}	{
	return yytext[0];
	}

<<EOF>>	{
	return YYEOF;
	}

.	{
	fprintf(stderr, "\x1b[31merror: \x1b[0m"
			"found an invalid token \x27%s\x27\x0a", yytext);
	exit(EXIT_FAILURE);
	}

let	{
	return LET;
	}

{id}	{
	strcpy(yylval.id.name, yytext);
	return ID;
	}
