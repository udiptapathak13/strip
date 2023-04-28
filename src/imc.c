#include "../include/imc.h"
#include <string.h>

#ifndef MALLOC
#define MALLOC(x,y) (x *) malloc(y * sizeof(x))
#endif

const uint64_t regEndp = 1 << 4;
const uint64_t dataEndp = 1 << 16;

Imc imc;

void imcInit()
{
	imc.base = MALLOC(Instr *, 1);
	imc.size = 0;
	imc.capacity = 1;
}

void imcGrow()
{
	imc.capacity <<= 1;
	Instr **base = MALLOC(Instr *, imc.capacity);
	for (int i = 0, n = imc.size ; i < n ; i++)
		base[i] = imc.base[i];
	free(imc.base);
	imc.base = base;
}

void imcAdd(Opcode opc, Operand opr1, Operand opr2)
{
	if (imc.size == imc.capacity)
		imcGrow();
	Instr *in = MALLOC(Instr, 1);
	in->opc = opc;
	in->opr1 = opr1;
	in->opr2 = opr2;
	imc.base[imc.size++] = in;
}

void imcClear()
{
	for (int i = 0, n = imc.size ; i < n ; i++)
		free(imc.base[i]);
	free(imc.base);
}

void imcDump(const char *fname)
{
	FILE *fptr = fopen(fname, "w");
	const int isize = sizeof(Opcode) + (sizeof(Operand) << 1);
	for (int i = 0 ; i < imc.size ; i++)
		fwrite(imc.base[i], isize, 1,fptr);
	fclose(fptr);
}

FILE *imcFptr;

void logOperand(Operand opr)
{
	if (opr < regEndp) fprintf(imcFptr, "R%d", opr);
	else if (opr < dataEndp) fprintf(imcFptr, "D[%d]", opr - regEndp);
	else fprintf(imcFptr, "I[%d]", opr - dataEndp);
}

void imcLog(const char *fname)
{
	imcFptr = fopen(fname, "w");
	for (int i = 0, n = imc.size ; i < n ; i++) {
		fprintf(imcFptr, "%s ", opcodeString[imc.base[i]->opc]);
		logOperand(imc.base[i]->opr1);
		fprintf(imcFptr, " ");
		if (imc.base[i]->opr2) logOperand(imc.base[i]->opr2);
		fprintf(imcFptr, "\x0a");
	}
	fclose(imcFptr);
}
