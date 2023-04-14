%{

#include "y.tab.h"

void panic(const char *, const char *);

%}

digit	[0-9]
n_dec	{digit}*
ws	[ \t\n]

%%

{n_dec}	{
	return NUMERIC;
	}

{ws}	{}

<<EOF>>	{
	return YYEOF;
	}

.	{
	fprintf(stderr, "\x1b[31merror: \x1b[0m"
			"found an invalid token \x27%s\x27\x0a", yytext);
	exit(EXIT_FAILURE);
	}
