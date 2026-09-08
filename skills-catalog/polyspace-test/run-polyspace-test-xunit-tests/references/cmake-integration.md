# CMake Integration

When the project uses CMake, create a **separate** `CMakeLists.txt` in a subdirectory (e.g., `pstest_build/CMakeLists.txt`) rather than modifying the user's existing `CMakeLists.txt`. This file re-declares the source targets and adds test/profiling targets.

After completing the run, tell the user what was created and how to reproduce independently (e.g., "I created `pstest_build/CMakeLists.txt` — you can re-run with `cd pstest_build/build && make test && make convert && make report`").

## Tests Only

Create `pstest_build/CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.13.0)
project(MyProject_Test C)
find_package(pstest PATHS "$ENV{POLYSPACE_ROOT}/polyspace/pstest/pstunit/cmake")

# Source library (mirrors user's sources)
add_library(app ../src/foo.c ../src/bar.c)
target_include_directories(app PUBLIC ../src)

# Test executable
enable_testing()
add_executable(testrunner ../test/test_foo.c ../test/test_bar.c ../test/main.c)
target_link_libraries(testrunner pstest::pstest_c app)

# Run tests and collect results
set(CMAKE_CTEST_ARGUMENTS "-O;out/pstest_results.mrf;--verbose")
add_test(NAME testrunner COMMAND testrunner -format mrf)

# Convert and report
pstest_add_convert_target(convert RESULTS_DIRS out CONVERTED_RESULTS_DIR results)
pstest_add_report_target(report RESULTS_DIRS results REPORTS_DIR reports HTML XML)

add_custom_target(all_tests ALL DEPENDS testrunner)

# Single "all" target that builds, tests, converts, and reports
add_custom_target(run_all
    COMMAND ${CMAKE_CTEST_COMMAND} ${CMAKE_CTEST_ARGUMENTS}
    COMMAND ${CMAKE_COMMAND} --build . --target convert
    COMMAND ${CMAKE_COMMAND} --build . --target report
    DEPENDS testrunner
)
```

Build and run:
```sh
cd pstest_build
mkdir build && cd build
cmake -G "Unix Makefiles" ..
make run_all
```

## Tests + Profiling

For profiling, create a static runtime. This requires a small config header (`psprofile_config.h`).

**`pstest_build/psprofile_config.h`:**
```c
#ifndef PSPROFILE_CONFIG_H
#define PSPROFILE_CONFIG_H

#define PSPROFILE_SENDING_TYPE              1
#define PSPROFILE_WORKING_BUFFER_SIZE   65536
#define PSPROFILE_HOST_EXECUTION            1
#define PSPROFILE_PROFILING_COUNTER_WIDTH  64

#define PSPROFILE_SAVE_DATETIME         psprofile_save_datetime
#define PSPROFILE_GET_START_DATETIME    psprofile_getdatetime_start
#define PSPROFILE_GET_STOP_DATETIME     psprofile_getdatetime_stop

#endif
```

**`pstest_build/CMakeLists.txt`:**
```cmake
cmake_minimum_required(VERSION 3.13.0)
project(MyProject_Test C)
find_package(pstest PATHS "$ENV{POLYSPACE_ROOT}/polyspace/pstest/pstunit/cmake")

# Static profiling runtime
pstest_add_profiling_runtime(myruntime CONFIG_HEADER_FILE psprofile_config.h STATIC)

# Source library — instrument for coverage with static runtime
# NOTE: LEVEL defaults to mcdc (decision + condition + MC/DC). Change to
# `condition/decision` or `decision` per the user's item-4 choice.
add_library(app ../src/foo.c ../src/bar.c)
target_include_directories(app PUBLIC ../src)
pstest_instrument_target(app COVERAGE LEVEL mcdc RUNTIME myruntime)

# Test executable
enable_testing()
add_executable(testrunner ../test/test_foo.c ../test/test_bar.c ../test/main.c)
target_link_libraries(testrunner pstest::pstest_c app)

# Run tests with profiling output
set(CMAKE_CTEST_ARGUMENTS "-O;out/pstest_results.mrf;--verbose")
add_test(NAME testrunner COMMAND testrunner -format mrf)
set_tests_properties(testrunner PROPERTIES ENVIRONMENT PSPROFILE_RESULTS_FILE=out/pstest_coverage.bin)

# Convert and report
pstest_add_convert_target(convert RESULTS_DIRS out CONVERTED_RESULTS_DIR results)
pstest_add_report_target(report RESULTS_DIRS results REPORTS_DIR reports HTML XML)

# Single target to build, test, convert, and report
add_custom_target(run_all
    COMMAND ${CMAKE_CTEST_COMMAND} ${CMAKE_CTEST_ARGUMENTS}
    COMMAND ${CMAKE_COMMAND} --build . --target convert
    COMMAND ${CMAKE_COMMAND} --build . --target report
    DEPENDS testrunner
)
```

Key differences from tests-only:
- `pstest_add_profiling_runtime(myruntime CONFIG_HEADER_FILE psprofile_config.h STATIC)` — builds a static runtime for profiling instrumentation.
- `pstest_instrument_target(app COVERAGE LEVEL mcdc RUNTIME myruntime)` — instruments only the source target, linked against the static runtime. `LEVEL` defaults to `mcdc`; use `condition/decision` or `decision` for lighter coverage per the user's item-4 choice.
- `set_tests_properties(... ENVIRONMENT PSPROFILE_RESULTS_FILE=...)` — tells the runtime where to write profiling data.
- `psprofile_config.h` — always the same boilerplate for host execution. Generate it automatically.

## Provided Targets and Libraries

The `pstest` package provides:
- `pstest::pstest_c` — interface library for C PSTUnit tests (includes + source)
- `pstest::pstest_cpp` — interface library for C++ PSTUnit tests
- `pstest_instrument_target()` — instrument a source target for profiling
- `pstest_add_profiling_runtime()` — create a custom runtime library (for cross-compilation)
- `pstest_add_convert_target()` — convert raw results to `.pstestr`/`.psprof`
- `pstest_add_report_target()` — generate HTML/XML reports from results

---

Copyright 2026 The MathWorks, Inc.

---
