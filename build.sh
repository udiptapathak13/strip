sudo mkdir -p /usr/include/strip
sudo cp -rf include/* /usr/include/strip
yacc -d src/translate.y
lex src/lex.l
mkdir -p tmp
cd tmp
gcc -c ../src/*.c
ar -rcs libstrip.a *.o
cd ../
gcc lex.yy.c y.tab.c -o strip -Ltmp -lstrip
sudo mv strip /usr/bin
