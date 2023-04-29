#include "../include/backpatch.h"
#include "../include/imc.h"
#include <stdlib.h>

#ifndef MALLOC
#define MALLOC(x,y) (x *) malloc(y * sizeof(x))
#endif

extern Imc imc;

Blist *BlistCreate(addr_t addr)
{
	Blist *ret = MALLOC(Blist, 1);
	ret->addr = addr;
	ret->next = NULL;
	return ret;
}

Blist *BlistMerge(Blist *b1, Blist *b2)
{
	Blist *ptr = b1;
	while (ptr->next) {
		ptr = ptr->next;
	}
	ptr->next = b2;
	return b1;
}

void BlistPatch(Blist *bl, addr_t addr)
{
	Blist *prev, *curr = bl;
	while (curr) {
		imc.base[curr->addr - dataEndp]->opr1 = addr;
		prev = curr;
		curr = curr->next;
		free(prev);
	}
}
