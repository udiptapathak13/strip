#ifndef _TOKEN_H
#define _TOKEN_H

#include <stdbool.h>

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
		bool mutable;
	} num;
} TokenAttr;

typedef struct {
	Tokid id;
	int row;
	int col;
	TokenAttr attr;
} Token;

#endif
