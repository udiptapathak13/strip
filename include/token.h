#ifndef _TOKEN_H
#define _TOKEN_H

#include <stdbool.h>
#include <stdint.h>

typedef enum {
	tok_num,
	tok_id
} Tokid;

typedef enum {
	rval,
	lval
} Ref;

typedef union {
	struct {
		int dtype;
		bool mut;
	} num;
} TokenAttr;

typedef struct {
	Tokid id;
	int row;
	int col;
	uint64_t addr;
	TokenAttr attr;
} Token;

#endif
