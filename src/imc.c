#include "../include/imc.h"
#include <string.h>

#ifndef MALLOC
#define MALLOC(x,y) (x *) malloc(y * sizeof(x))
#endif

extern char **opcodeString;

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

void imcAdd1(Opcode opc, const char *opr)
{
	if (imc.size == imc.capacity)
		imcGrow();
	Instr *in = MALLOC(Instr, 1);
	size_t len = strlen(opr) + 1;
	in->opc = opc;
	in->opr1 = MALLOC(char, len);
	strncpy(in->opr1, opr, len);
	imc.base[imc.size++] = in;
}

void imcAdd2(Opcode opc, const char *opr1, const char *opr2)
{
	if (imc.size == imc.capacity)
		imcGrow();
	Instr *in = MALLOC(Instr, 1);
	size_t len = strlen(opr1) + 1;
	in->opc = opc;
	in->opr1 = MALLOC(char, len);
	strncpy(in->opr1, opr1, len);
	len = strlen(opr2) + 1;
	in->opc = opc;
	in->opr2 = MALLOC(char, len);
	strncpy(in->opr2, opr2, len);
	imc.base[imc.size++] = in;
}

void imcClear()
{
	for (int i = 0, n = imc.size ; i < n ; i++)
		free(imc.base[i]);
	free(imc.base);
}

void imcLog(FILE *fptr)
{
	for (int i = 0, n = imc.size ; i < n ; i++) {
		fprintf(fptr, "%d %x] ", imc.base[i]->opc, opcodeString[imc.base[i]->opc]);
		fprintf(fptr, "%s ", imc.base[i]->opr1);
		if (imc.base[i]->opr2)
			fprintf(fptr, "%s ", imc.base[i]->opr2);
		fprintf(fptr, "\x0a");
	}
}
