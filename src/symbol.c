#include "../include/symbol.h"
#include <stdlib.h>

#ifndef MALLOC
#define MALLOC(x,y) (x *) malloc(y * sizeof(x))
#endif

char hashChar(char ch)
{
	if ('a' <= ch && ch <= 'z')
		return ch - 'a';
	if ('A' <= ch && ch <= 'Z')
		return 26 + ch - 'A';
	if ('0' <= ch  && ch <= '9')
		return 52 + ch - '0';
	if (ch == '\x5f') return 62;
	return 63;
}

SymbolNode  *symbolNodeCreate()
{
	SymbolNode *ret = MALLOC(SymbolNode, 1);
	for (int i = 0 ; i < 64 ; i++) ret->child[i] = NULL;
	ret->end = false;
	return ret;
}

Symbol *symbolCreate()
{
	Symbol *ret = MALLOC(Symbol, 1);
	ret->root = symbolNodeCreate();
	return ret;
}

void symbolInsert(Symbol *sym, const char *sname, Token tok)
{
	SymbolNode *itr = sym->root;
	SymbolNode *ptr;
	int cnt = 0;
	char curr = sname[cnt];
	while (curr) {
		curr = hashChar(curr);
		ptr = itr->child[curr];
		itr = ptr?
			ptr:
			(itr->child[curr] = symbolNodeCreate());
		curr = sname[++cnt];
	}
	itr->tok = tok;
	itr->end = true;
}

Token *symbolMember(Symbol *sym, const char *sname)
{
	SymbolNode *itr = sym->root;
	SymbolNode *ptr;
	int cnt = 0;
	char curr = sname[cnt];
	while (curr) {
		ptr = itr->child[hashChar(curr)];
		if (!ptr)
			return false;
		itr = ptr;
		curr = sname[++cnt];
	}
	if(!itr->end) return NULL;
	return &itr->tok;

}

void theLastPostOrder(SymbolNode *root)
{
	SymbolNode *tmp;
	for (int i = 0 ; i < 64 ; i++)
		if (tmp = root->child[i])
			theLastPostOrder(tmp);
	free(root);
}

void symbolDestroy(Symbol *sym)
{
	theLastPostOrder(sym->root);
	free(sym);
}