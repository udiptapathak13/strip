#include "../include/panic.h"
#include <stdlib.h>
#include <stdio.h>

void panic(panic_t e)
{
	fprintf(stderr, "\x1b[31merror:\x1b[0m ");
	switch (e) {
	case E_FAILED_TO_OPEN_FILE:
		fprintf(stderr, "failed to open file");
		break;
	case E_UNTERMINATED_STRING:
		fprintf(stderr, "string not termininated");
		break;
	case E_UNMATCHED_PARENTHESIS:
		fprintf(stderr, "parenthesis is not matched");
	}
	fprintf(stderr, "\x0a");
	exit(EXIT_FAILURE);
}
