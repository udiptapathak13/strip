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
void imcAdd1(Opcode, const char *);
void imcAdd2(Opcode, const char *, const char *);
void imcLog(FILE *);
uint32_t imcCount();
void imcClear() __attribute__((destructor));

#endif
