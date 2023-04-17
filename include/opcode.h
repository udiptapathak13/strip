#ifndef _OPCODE_H
#define _OPCODE_H

#include <string.h>
#include <stdlib.h>

#define MALLOC(x,y) (x *) malloc(y * sizeof(x))

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

char *opcodeString[31];

char *strGet(const char *str)
{
	size_t len = strlen(str) + 1;
	char *ret = MALLOC(char, len);
	strncpy(ret, str, len);	
	return ret;
}

void initOpcStr() __attribute__((constructor));

void initOpcStr()
{
	opcodeString[op_add] = strGet("add");
	opcodeString[op_sub] = strGet("sub");
	opcodeString[op_mul] = strGet("mul");
	opcodeString[op_div] = strGet("div");
	opcodeString[op_mod] = strGet("mod");
	opcodeString[op_addi] = strGet("addi");
	opcodeString[op_subi] = strGet("subi");
	opcodeString[op_muli] = strGet("muli");
	opcodeString[op_div_ir] = strGet("div_ir");
	opcodeString[op_div_ri] = strGet("div_ri");
	opcodeString[op_mod_ir] = strGet("mod_ir");
	opcodeString[op_mod_ri] = strGet("mod_ri");
	opcodeString[op_load] = strGet("load");
	opcodeString[op_store] = strGet("store");
	opcodeString[op_param] = strGet("param");
	opcodeString[op_call] = strGet("call");
	opcodeString[op_ret] = strGet("ret");
	opcodeString[op_jmp] = strGet("jmp");
	opcodeString[op_jmpif] = strGet("jmpif");
	opcodeString[op_ge] = strGet("ge");
	opcodeString[op_eq]  = strGet("eq");
	opcodeString[op_neq] = strGet("neq");
	opcodeString[op_inc] = strGet("inc");
	opcodeString[op_dec] = strGet("dec");
	opcodeString[op_lshift] = strGet("lshift");
	opcodeString[op_rshift] = strGet("rshift");
	opcodeString[op_and] = strGet("and");
	opcodeString[op_or] = strGet("or");
	opcodeString[op_xor] = strGet("xor");
	opcodeString[op_int] = strGet("int");
}

#undef MALLOC

#endif
