%{
#include "y.tab.h"
%}

digit	[0-9]
n_dec	{digit}*
ws	[ \t\n]

%%

{n_dec}	{
	return NUM;
	}

{ws}	{}

<<EOF>>	{
	return YYEOF;
	}
