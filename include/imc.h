#ifndef _IMC_H
#define _IMC_H

#include "instr.h"
#include "token.h"
#include <stddef.h>
#include <stdio.h>

typedef uint32_t addr_t;
typedef uint64_t word;

extern const addr_t dataEndp;
extern const addr_t regEndp;

typedef struct {
	Instr **base;
	size_t size;
	size_t capacity;
	size_t last;
} Imc;

void imcInit() __attribute__((constructor));
void imcAdd(Opcode, Operand, Operand);
void imcLog(const char *);
uint64_t imcCount();
void imcDump(const char *);
void imcClear() __attribute__((destructor));
void imcAexpr(Opcode, Ref, Ref, word, word);

#endif
