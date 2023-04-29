#ifndef _BACKPATCH_H
#define _BACKPATCH_H

#include "imc.h"

#ifndef MALLOC
#define MALLOC(x,y) (x *) malloc(y * sizeof(x))
#endif

struct Blist {
	addr_t addr;
	struct Blist *next;
};

typedef struct Blist Blist;

Blist *BlistCreate(addr_t);
Blist *BlistMerge(Blist *, Blist *);
void BlistPatch(Blist *, addr_t);

#endif
