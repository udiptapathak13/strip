#include "../include/block.h"

#ifndef MALLOC
#define MALLOC(x,y) (x *) malloc(y * sizeof(x))
#endif

extern Imc imc;

Block *BlockCreate(addr_t addr)
{
	Block *this = MALLOC(Block, 1);
	this->next = NULL;
	return this;
}

Block *sortBlock(Block *root)
{
	if (!root || !root->next) return root;
	Block *turtle = root, *hare = root->next;
	while (hare && hare->next) {
		turtle = turtle->next;
		hare = hare->next->next;
	}
	hare = sortBlock(turtle->next);
	turtle->next = NULL;
	root = sortBlock(root);
	Block *ret = root->addr < hare->addr ? root : hare;
	turtle = ret;
	if (ret == hare) hare = hare->next;
	else  root = root->next;
	while (root || hare) {
		if (!root) {
			turtle->next = hare; 
			hare = hare->next;
		} else if (!hare || root->addr < hare->addr) {
			turtle->next = ret;
			root = root->next;
		} else {
			turtle->next = hare;
			hare = hare->next;
		}
	}
	turtle->next = NULL;
	return ret;
}

Block *BlockDetect()
{
	Block *ret = BlockCreate(0);
	Block *curr = ret;
	for (addr_t i = 0 ; i < imc.size ; i++) {
		if (imc.base[i]->opc == op_jmp) {
			curr->next = BlockCreate(i - 1);
			curr = curr->next;
			curr->next = BlockCreate(imc.base[i]->opr1);
		}
	}
	sortBlock(ret);
}