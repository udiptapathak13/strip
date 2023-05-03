#ifndef _BLOCK_H
#define _BLOCK_H

#include "imc.h"

struct Block {
	addr_t addr;
	struct Block *next;
};

typedef struct Block Block;

Block *BlockCreate(addr_t);
Block *BlockDetect();

#endif
