#ifndef _INSTR_H
#define _INSTR_H

#include "opcode.h"
#include <stdint.h>

typedef struct {
	Opcode opc;
	char *opr1;
	char *opr2;
} Instr;

#endif
