#ifndef _IMC_H
#define _IMC_H

#include "instr.h"
#include <stddef.h>
#include <stdio.h>

typedef struct {
	Instr **base;
	size_t size;
	size_t capacity;
} Imc;

void imcInit() __attribute__((constructor));
void imcAdd(Opcode, Operand, Operand);
void imcLog(const char *);
uint64_t imcCount();
void imcDump(const char *);
void imcClear() __attribute__((destructor));

#endif
