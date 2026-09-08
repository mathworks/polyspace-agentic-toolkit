---
name: generate-polyspace-test-xunit-tests
description: Authors new C/C++ unit tests for the Polyspace Test XUnit framework (PSTUnit) — creates a test plan and writes the test source code. Use when the user asks to "generate PSTUnit tests", "write Polyspace Test xUnit tests", "author PSTUnit tests", "create PSTUnit tests for this function", or wants to design a PSTUnit test plan. For BUILDING or RUNNING already-authored tests, use `run-polyspace-test-xunit-tests` instead.
license: MathWorks BSD-3-Clause
metadata:
  version: "1.3"
---
# How to Generate Polyspace XUnit Tests

Step-by-step guide to author new unit tests using the Polyspace XUnit framework (PSTUnit). This skill covers test-plan design and test-source authoring. Compiling and executing the resulting test binary is the `run-polyspace-test-xunit-tests` skill's responsibility — invoke it after Step 3 finishes.

## When NOT to Use

- **Building or running existing PSTUnit tests.** If test sources are already written and the user wants to compile/execute them (with or without profiling/coverage), invoke the `run-polyspace-test-xunit-tests` skill instead.

## 1. Create a test plan

Before writing tests, analyze the function under test to create a test plan covering:
- **Main functionalities**: Nominal execution paths with valid inputs.
- **Error cases**: Invalid inputs, boundary violations, and error handling paths.
- **Edge cases**: Boundary values, empty inputs, maximum/minimum values, null pointers.

**User approval required**: Present the test plan to the user and wait for their approval before proceeding to the next step. Refine the plan if the user requests changes.

## 2. Get the XUnit API documentation

Read `references/xunit_api_c.md` (for C projects) or `references/xunit_api_cpp.md` (for C++ projects) in this folder to get the PSTUnit API reference.

## 3. Author the test code

- Include the pstunit header (`pstunit.h`) in your test file.
- Use the XUnit API macros and functions to define test cases and test suites.
- Include the headers of the functions under test.
- Create one test case per scenario from the test plan.

Do NOT write `main()` or the test-registration function by hand — `run-polyspace-test-xunit-tests` generates them.

**Commenting conventions**:
- Start the test file with a comment block describing its purpose: what module/function is tested and what the file covers.
- Before each test case, add a brief comment stating the goal of that test point.
- Inside each test case, add short comments describing the setup/initialization, the action being performed, and what is being verified.

## 4. Hand off to `run-polyspace-test-xunit-tests` for build and execution

Once the test sources are written, **stop authoring and invoke the `run-polyspace-test-xunit-tests` skill**. That skill owns compilation, execution via `polyspace-test -monitor`, and optional profiling/coverage collection — on host or target, with Makefile / CMake / raw commands.

Do NOT run `gcc`/`g++`/`polyspace-test` commands from this skill. Delegate.

If `run-polyspace-test-xunit-tests` reports build failures, iterate on the test sources (return to Step 3) and re-invoke `run-polyspace-test-xunit-tests`.

---

Copyright 2026 The MathWorks, Inc.

---
