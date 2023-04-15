#ifndef _TOKEN_H
#define _TOKEN_H

typedef union {
	struct {
		int dtype;
		bool mutable;
	} num;
} TokenAttr;

typedef struct {
	int id;
	int row;
	int col;
	TokenAttr attr;
} Token;

#endif
