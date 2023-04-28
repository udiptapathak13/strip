#ifndef _INSTR_H
#define _INSTR_H

#include "opcode.h"
#include <stdint.h>

typedef uint64_t Operand;

typedef struct {
	Opcode opc;
	Operand opr1;
	Operand opr2;
} Instr;

#endif
