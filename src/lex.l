%{

#include "y.tab.h"
#include <strip/primitive.h>
#include <strip/token.h>
#include <strip/panic.h>

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
str	({alnum}|{delim}|{ws}|{binop})*

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

'{str}'	{
	}

\'{str}	{
	panic(E_UNTERMINATED_STRING);
	}

{delim}	{
	return yytext[0];
	}

<<EOF>>	{
	return YYEOF;
	}

let	{
	return LET;
	}

{id}	{
	strcpy(yylval.id.name, yytext);
	return ID;
	}

.	{
	fprintf(stderr, "\x1b[31merror: \x1b[0m"
			"found an invalid token \x27%s\x27\x0a", yytext);
	exit(EXIT_FAILURE);
	}
