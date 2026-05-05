# PSTUnit Framework Documentation
## Overview
PSTUnit is a unit testing framework for C and C++ projects.

## Defining tests
```
PST_SUITE(suite_name);

PST_TEST(suite_name, test_name) {
    // Test code
}
```

## Verification Macros

### Boolean assessments
```
PST_VERIFY_TRUE(expr);
PST_VERIFY_FALSE(expr);
```

### String comparisons
```
PST_VERIFY_EQ_CSTR(lhs, rhs);
PST_VERIFY_NE_CSTR(lhs, rhs);
```

### Floating-point comparisons with tolerance
```
PST_VERIFY_EQ_APPROX_FLT(lhs, rhs, delta);
```

### Assessments with messages
Append `_MSG` to any macro to add a diagnostic message (C-style char array):
```
PST_VERIFY_TRUE_MSG(expr, "my message");
```

### VERIFY vs ASSERT
- **VERIFY**: Test continues on failure.
- **ASSERT**: Test stops immediately on failure.

Every `PST_VERIFY_*` macro has a corresponding `PST_ASSERT_*` variant.

## Setup and teardown
Use `PST_TEST_CONFIG` and `PST_TEST_BODY` instead of `PST_TEST`:
```
void my_setup(void)    { /* ... */ }
void my_teardown(void) { /* ... */ }

PST_TEST_CONFIG(my_suite, my_test) {
    PST_SETUP(my_setup);
    PST_TEARDOWN(my_teardown);
}

PST_TEST_BODY(my_suite, my_test) {
    // test code
}
```

## Parametrized tests
```
int my_param_vals[] = {1, 2, 4};
PST_PARAM_WITH_VALUES(my_param, int, pst_format_param_int, my_param_vals, 3);

PST_TEST_CONFIG(my_suite, my_test) {
    PST_ADD_PARAM(my_param);
}

PST_TEST_BODY(my_suite, my_test) {
    int val = *PST_PARAM_PTR(my_param);
    PST_VERIFY_TRUE(my_fun(val) > 0);
}
```
Built-in display functions: `pst_format_param_int`, `pst_format_param_uint`, `pst_format_param_flt`.

## C-specific features

### Typed comparison macros
In C, comparison macros use type suffixes. The pattern is `PST_VERIFY_{OP}_{TYPE}(lhs, rhs)`.
Available types: `_INT` (signed), `_UINT` (unsigned), `_FLT` (float), `_PTR` (pointer).
Available operations: `EQ`, `NE`, `LT`, `GT`, `LE`, `GE`.
Examples:
```c
PST_VERIFY_EQ_INT(result, 5);
PST_VERIFY_GT_UINT(count, 0u);
PST_VERIFY_NE_PTR(ptr, NULL);
```

### Entry point
A `main()` function is required. Use a trivial main that calls `PST_MAIN`:
```c
int main(int argc, char* argv[]) {
    /* register tests here (see below) */
    return PST_MAIN(argc, argv);
}
```

### Registration (required in C)
In C, tests must be explicitly registered with `PST_ADD_TEST` before calling `PST_MAIN`:
```c
int main(int argc, char* argv[]) {
    PST_ADD_TEST(my_suite, my_test);
    return PST_MAIN(argc, argv);
}
```
For multi-file projects, use `PST_REGFCN` / `PST_REGFCN_CALL`:
```c
PST_REGFCN(my_tests) {
    PST_ADD_TEST(my_suite, my_test);
}

int main(void) {
    PST_REGFCN_CALL(my_tests);
    return pst_init_run_terminate();
}
```

## Complete C example
```c
/* Tests for the add() function */
#include "pstunit.h"
#include "my_module.h"

PST_SUITE(my_suite);

/* Test: addition returns correct result */
PST_TEST(my_suite, test_add_positive) {
    int result = add(2, 3);
    PST_VERIFY_EQ_INT(result, 5);
}

/* Test: adding zero does not change the value */
PST_TEST(my_suite, test_add_zero) {
    int result = add(7, 0);
    PST_VERIFY_EQ_INT(result, 7);
}

int main(int argc, char* argv[]) {
    PST_ADD_TEST(my_suite, test_add_positive);
    PST_ADD_TEST(my_suite, test_add_zero);
    return PST_MAIN(argc, argv);
}
```

## Building the tests

To compile the tests for C, compile `pstest.c` alongside your test file. For example:

```
gcc <test_file> <polyspace_root>/polyspace/pstest/pstunit/src/pstest.c \
    -I<polyspace_root>/polyspace/pstest/pstunit/include -o test_executable
```

Use the same compiler and flags as the project under test to ensure compatibility.

If you need details on a specific macro not covered above, grep for it in the header file:
`<polyspace_root>/polyspace/pstest/pstunit/include/pstunit.h`

---

Copyright 2026 The MathWorks, Inc.

---
