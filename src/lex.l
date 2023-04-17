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
delim	[{}\[\]();]
id	[alpha_'][alnum_']*

%%

{n_dec}	{
	yylval.expr.ref = rval;
	yylval.expr.dtype = i64;
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

{id}	{
	return ID;
	}

<<EOF>>	{
	return YYEOF;
	}

.	{
	fprintf(stderr, "\x1b[31merror: \x1b[0m"
			"found an invalid token \x27%s\x27\x0a", yytext);
	exit(EXIT_FAILURE);
	}
