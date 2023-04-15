#ifndef _IMC_H
#define _IMC_H

#include "instr.h"
#include <stddef.h>
#include <stdio.h>

struct {
	Instr **base;
	size_t size;
	size_t capacity;
} Imc;

void imcAdd1(Opcode, const char *);
void imcAdd2(Opcode, const char *, const char *);
void imcLog(FILE *);

#endif
