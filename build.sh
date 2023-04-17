sudo mkdir -p /usr/include/strip
sudo cp -rf include/* /usr/include/strip
yacc -d src/translate.y
lex src/lex.l
gcc lex.yy.c y.tab.c -o strip
sudo mv strip /usr/bin
