#include "../include/opcode.h"
#include <stdio.h>

char *strGet(const char *str)
{
	size_t len = strlen(str) + 1;
	char *ret = MALLOC(char, len);
	strncpy(ret, str, len);
	ret[len] = 0;
	return ret;
}

void initOpcStr()
{
	opcodeString[op_add] = strGet("add");
	opcodeString[op_sub] = strGet("sub");
	opcodeString[op_mul] = strGet("mul");
	opcodeString[op_div] = strGet("div");
	opcodeString[op_mod] = strGet("mod");
	opcodeString[op_mov] = strGet("mov");
	opcodeString[op_movi] = strGet("movi");
	opcodeString[op_sub] = strGet("sub");
	opcodeString[op_load] = strGet("load");
	opcodeString[op_store] = strGet("store");
	opcodeString[op_param] = strGet("param");
	opcodeString[op_call] = strGet("call");
	opcodeString[op_ret] = strGet("ret");
	opcodeString[op_jmp] = strGet("jmp");
	opcodeString[op_jmpif] = strGet("jmpif");
	opcodeString[op_jmpifn] = strGet("jmpifn");
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