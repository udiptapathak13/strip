#ifndef _OPCODE_H
#define _OPCODE_H

#include <string.h>
#include <stdlib.h>

#ifndef MALLOC
#define MALLOC(x,y) (x *) malloc(y * sizeof(x))
#endif

extern char *opcodeString[31];

typedef enum {
	op_add,
	op_sub,
	op_mul,
	op_div,
	op_mov,
	op_movi,
	op_mod,
	op_load,
	op_store,
	op_param,
	op_call,
	op_ret,
	op_jmp,
	op_jmpif,
	op_jmpifn,
	op_ge,
	op_eq,
	op_neq,
	op_inc,
	op_dec,
	op_lshift,
	op_rshift,
	op_and,
	op_or,
	op_xor,
	op_int
} Opcode;

void initOpcStr();

#endif
