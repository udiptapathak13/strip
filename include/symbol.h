#ifndef _SYMBOL_H
#define _SYMBOL_H

#include <stdbool.h>
#include "token.h"

struct symbolNode {
	bool end;
	Token tok;
	struct symbolNode *child[64];
};

typedef struct symbolNode symbolNode;

struct {
	symbolNode *root;
} symbol;

void symbolInit();
void symbolInsert(const char *, Token);
bool symbolMember(const char *);

#endif
