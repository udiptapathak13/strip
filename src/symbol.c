#include "../include/symbol.h"
#include <stdlib.h>

#define MALLOC(x,y) (x *) malloc(y * sizeof(x))

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

symbolNode  *symbolNodeCreate()
{
	symbolNode *ret = MALLOC(symbolNode, 1);
	for (int i = 0 ; i < 64 ; i++) ret->child[i] = NULL;
	ret->end = false;
	return ret;
}

void symbolInit()
{
	symbol.root = symbolNodeCreate();
}

void symbolInsert(const char *sname, Token tok)
{
	symbolNode *itr = symbol.root;
	symbolNode *ptr;
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

bool symbolMember(const char *sname)
{
	symbolNode *itr = symbol.root;
	symbolNode *ptr;
	int cnt = 0;
	char curr = sname[cnt];
	while (curr) {
		ptr = itr->child[hashChar(curr)];
		if (!ptr)
			return false;
		itr = ptr;
		curr = sname[++cnt];
	}
	return itr->end;
}

#undef MALLOC
