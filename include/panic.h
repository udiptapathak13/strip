#ifndef _PANIC_H
#define _PANIC_H

typedef enum {
  E_FAILED_TO_OPEN_FILE,
  E_UNTERMINATED_STRING,
  E_UNMATCHED_PARENTHESIS,
  E_NUM_OVERFLOW,
  E_MISSING_RIGHT_OPERAND
} panic_t;

void panic(panic_t);

#endif