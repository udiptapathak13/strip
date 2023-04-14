yacc -d translate.y
lex lex.l
gcc lex.yy.c y.tab.c -o strip
