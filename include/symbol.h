#ifndef _SYMBOL_H
#define _SYMBOL_H

#include <stdbool.h>
#include "token.h"

struct SymbolNode {
	bool end;
	Token tok;
	struct SymbolNode *child[64];
};

typedef struct SymbolNode SymbolNode;

typedef struct {
	SymbolNode *root;
} Symbol;

Symbol * symbolCreate();
void symbolInsert(Symbol *, const char *, Token);
Token *symbolMember(Symbol *, const char *);
void symbolDestroy(Symbol *);

#endif
