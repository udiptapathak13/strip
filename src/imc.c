#include "../include/imc.h"
#include <string.h>

#define MALLOC(x,y) (x *) malloc(y * sizeof(x))

void imcInit()
{
	Imc.base = MALLOC(Instr *, 1);
	Imc.size = 0;
	Imc.capacity = 1;
}

void imcGrow()
{
	Imc.capacity <<= 1;
	Instr **base = MALLOC(Instr *, Imc.capacity);
	for (int i = 0, n = Imc.size ; i < n ; i++)
		base[i] = Imc.base[i];
	free(Imc.base);
	Imc.base = base;
}

void imcAdd1(Opcode opc, const char *opr)
{
	if (Imc.size == Imc.capacity)
		imcGrow();
	Instr *in = MALLOC(Instr, 1);
	size_t len = strlen(opr) + 1;
	in->opc = opc;
	in->opr1 = MALLOC(char, len);
	strncpy(in->opr1, opr, len);
	Imc.base[Imc.size++] = in;
}

void imcAdd2(Opcode opc, const char *opr1, const char *opr2)
{
	if (Imc.size == Imc.capacity)
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
	Imc.base[Imc.size++] = in;
}

void imcClear()
{
	for (int i = 0, n = Imc.size ; i < n ; i++)
		free(Imc.base[i]);
	free(Imc.base);
}

void imcLog(FILE *fptr)
{
	for (int i = 0, n = Imc.size ; i < n ; i++) {
		fprintf(fptr, "%s ", opcodeString[Imc.base[i]->opc]);
		fprintf(fptr, "%s ", Imc.base[i]->opr1);
		if (Imc.base[i]->opr2)
			fprintf(fptr, "%s ", Imc.base[i]->opr2);
		fprintf(fptr, "\x0a");
	}
}

#undef MALLOC
