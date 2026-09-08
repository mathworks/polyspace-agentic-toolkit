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

## C++-specific features

### Entry point
A `main()` function is required. Use a trivial main that calls `PST_MAIN`:
```cpp
int main(int argc, char* argv[]) {
    return PST_MAIN(argc, argv);
}
```

### Auto-registration
In C++, tests are automatically registered. No `PST_REGFCN` or `PST_ADD_TEST` needed.

Note: in rare cases (e.g. tests linked from a static library), the linker may drop the auto-registration code. If tests are not found at runtime, add `PST_ADD_TEST` calls in `main()` as in C.

### Generic comparison macros
In C++, comparison macros use type deduction -- no type suffix needed:
```cpp
PST_VERIFY_EQ(lhs, rhs);  // Equal
PST_VERIFY_NE(lhs, rhs);  // Not equal
PST_VERIFY_LT(lhs, rhs);  // Less than
PST_VERIFY_GT(lhs, rhs);  // Greater than
PST_VERIFY_LE(lhs, rhs);  // Less or equal
PST_VERIFY_GE(lhs, rhs);  // Greater or equal
```

### Exception assessments
```cpp
PST_VERIFY_THROW(statement, exception_type);
PST_VERIFY_ANY_THROW(statement);
PST_VERIFY_NO_THROW(statement);
```

### Fixtures (suite-level setup/teardown)
```cpp
struct myFixture : public pst_suite_fixture {
  public:
    static void suite_setup()        { /* once before all tests */ }
    static void suite_teardown()     { /* once after all tests */ }
    void test_setup() override       { /* before each test */ }
    void test_teardown() override    { /* after each test */ }
};

PST_SUITE_WITH_FIXTURE(my_suite, myFixture);
```
Access the fixture from a test with `PST_SUITE_TEST_FIXTURE_PTR()`.

## Complete C++ example
```cpp
/* Tests for the add() function */
#include "pstunit.h"
#include "my_module.h"

PST_SUITE(my_suite);

/* Test: addition returns correct result */
PST_TEST(my_suite, test_add_positive) {
    int result = add(2, 3);
    PST_VERIFY_EQ(result, 5);
}

/* Test: adding zero does not change the value */
PST_TEST(my_suite, test_add_zero) {
    int result = add(7, 0);
    PST_VERIFY_EQ(result, 7);
}

int main(int argc, char* argv[]) {
    return PST_MAIN(argc, argv);
}
```

## Building the tests

To compile the tests for C++, compile `pstest.c` alongside your test file. For example:

```
g++ <test_file> <polyspace_root>/polyspace/pstest/pstunit/src/pstest.c \
    -I<polyspace_root>/polyspace/pstest/pstunit/include -o test_executable
```

Use the same compiler and flags as the project under test to ensure compatibility.

If you need details on a specific macro not covered above, grep for it in the header file:
`<polyspace_root>/polyspace/pstest/pstunit/include/pstunit.h`

---

Copyright 2026 The MathWorks, Inc.

---
