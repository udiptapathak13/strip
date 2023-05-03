#include "../include/mio.h"

#ifndef MALLOC
#define MALLOC(x,y) (x *) malloc(y * sizeof(x))
#endif

extern Imc imc;

void simplifyAlgebra()
{
	Instr in;
	for (int i = 0 ; i < imc.size ; i++) {
		in = *imc.base[i];
		switch (imc.base[i]->opc) {
		case op_muli:
			if (__builtin_popcount(in.opr2) == 1) {
				in.opc = op_lshift;
				in.opr2 = __builtin_ctz(in.opr2);
			} else if (in.opr2 == 1)
			{
				free(imc.base[i]);
				free(imc.base[i - 1]);
				imc.base[i - 1] = NULL;
				imc.base[i] = imc.base[i - 2];
			}
		case op_addi:
			if (in.opr2 == 1)
				in.opc = op_inc;
			else if (in.opr2 == -1)
				in.opc = op_dec;
			else if (in.opr2 == 0) {
				free(imc.base[i]);
				free(imc.base[i - 1]);
				imc.base[i - 1] = NULL;
				imc.base[i] = imc.base[i - 2];
			}
		}
	}
}

void rendudantInstrElimination()
{
	for (int i = 1 ; i < imc.size ; i++) {
		switch (imc.base[i]->opc) {
		op_mov:
			if (imc.base[i - 1]->opc == op_mov
			&& imc.base[i - 1]->opr1 == imc.base[i]->opr2
			&& imc.base[i - 1]->opr2 == imc.base[i]->opr1) {
				free(imc.base[i]);
				imc.base[i] = NULL;
			}
		}
	}
}

struct Fcnode {
	int addr;
	struct Fcnode *next;
};

typedef struct Fcnode Fcnode;

Fcnode *FcnodeCreate(int addr)
{
	Fcnode *this = MALLOC(Fcnode, 1);
	this->addr = addr;
	this->next = NULL;
	return this;
}

void optimizeControlFlow()
{
	Instr in;
	Fcnode *root, *curr;
	for (int i = 0 ; i < imc.size ; i++) {
		if (imc.base[i]->opc) {
			root = curr = FcnodeCreate(i);
			in = *imc.base[curr->addr];
			while (in.opc == op_jmp) {
				curr->next = FcnodeCreate(in.opr1);
				curr = curr->next;
				in = *imc.base[curr->addr];
			}
			int addr = curr->addr;
			while (root) {
				imc.base[root->addr]->opr1 = addr;
				root = root->next;
			}
		}
	}
}

void peepholeOptimization()
{
	simplifyAlgebra();
	eliminateRedundantInstr();
	optimizeControlFlow();
}