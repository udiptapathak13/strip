#ifndef _OPCODE_H
#define _OPCODE_H

#include <string.h>
#include <stdlib.h>

#ifndef MALLOC
#define MALLOC(x,y) (x *) malloc(y * sizeof(x))
#endif

typedef enum {
	op_add,
	op_sub,
	op_mul,
	op_div,
	op_mod,
	op_addi,
	op_subi,
	op_muli,
	op_div_ir,
	op_div_ri,
	op_mod_ir,
	op_mod_ri,
	op_load,
	op_store,
	op_param,
	op_call,
	op_ret,
	op_jmp,
	op_jmpif,
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

void initOpcStr() __attribute__((constructor));

#endif
