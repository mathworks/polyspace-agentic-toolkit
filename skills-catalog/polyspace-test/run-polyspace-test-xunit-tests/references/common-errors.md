# Common Errors with Polyspace Test xUnit API

## Wrong header name
- **Wrong:** `#include "pstest.h"`
- **Right:** `#include "pstunit.h"`
- **Symptom:** `fatal error: pstest.h: No such file or directory`

## Missing semicolon after PST_SUITE
- **Wrong:** `PST_SUITE(math_tests)`
- **Right:** `PST_SUITE(math_tests);`
- **Symptom:** `error: expected ',' or ';' before 'static'` on the next `PST_TEST` line. The error points inside pstunit.h, not your code.

## Generic assertions in C mode
- **Wrong:** `PST_ASSERT_EQ(a, b)` — this is C++ only
- **Right:** `PST_ASSERT_EQ_INT(a, b)`, `PST_ASSERT_EQ_UINT(a, b)`, `PST_ASSERT_EQ_BOOL(a, b)`, `PST_ASSERT_EQ_APPROX_FLT(a, b, tol)`
- **Symptom:** `implicit declaration of function 'PST_ASSERT_EQ'` or `_Generic` errors

## Missing test registration in C mode
- In C, tests must be explicitly registered. C++ does this automatically.
- **Required:**
  ```c
  PST_REGFCN(register_tests) {
      PST_ADD_TEST(suite, test_name);
  }
  ```
- **Symptom:** Compiles and runs but reports 0 tests executed

## PST_MAIN without arguments
- **Wrong:** `return PST_MAIN();`
- **Right:** `return PST_MAIN(argc, argv);`
- Main signature must be `int main(int argc, char *argv[])`
- **Symptom:** `error: too few arguments to function 'pst_main'`

## Missing PST_REGFCN_CALL in main
- **Wrong:**
  ```c
  int main(int argc, char *argv[]) {
      return PST_MAIN(argc, argv);
  }
  ```
- **Right:**
  ```c
  int main(int argc, char *argv[]) {
      PST_REGFCN_CALL(register_tests);
      return PST_MAIN(argc, argv);
  }
  ```
- **Symptom:** Compiles and runs but reports 0 tests executed

---

Copyright 2026 The MathWorks, Inc.

---
