#include "../include/opcode.h"
#include <stdio.h>

char *opcodeString[31];

char *strGet(const char *str)
{
	size_t len = strlen(str) + 1;
	char *ret = MALLOC(char, len);
	strncpy(ret, str, len);
	return ret;
}

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