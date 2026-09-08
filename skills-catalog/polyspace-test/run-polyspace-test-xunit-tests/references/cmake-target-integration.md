# CMake Target Integration

When the project uses CMake for a target (embedded) build, create a **separate** `pstest_build/CMakeLists.txt` rather than modifying the user's existing `CMakeLists.txt`. This file cross-compiles the test firmware, flashes it, and monitors the test run over the chosen transport.

After completing the run, tell the user what was created and how to reproduce (e.g., "I created `pstest_build/` — you can re-run with `cd pstest_build/build && make && make run`").

## Creating pstest_config.h

Create `pstest_build/pstest_config.h` containing the mode macro and `PST_WRITE` mapping. Use the transmit function confirmed by the user in item 8.

**Tests only:**
```c
#ifndef PSTEST_CONFIG_H
#define PSTEST_CONFIG_H

#define PST_MONITOR_MODE 1
#define PST_ENABLE_EXECUTION_TIME 0

#include "<board_header.h>"

extern <transmit_handle_type> <handle_name>;

#define PST_WRITE(buf, len) \
    <transmit_function>((uint8_t*)(buf), (len))

#endif
```

**Tests + profiling:**
```c
#ifndef PSTEST_CONFIG_H
#define PSTEST_CONFIG_H

#define PST_MONITOR_MODE_WITH_PROFILING 1
#define PST_ENABLE_EXECUTION_TIME 0

#include "<board_header.h>"

extern <transmit_handle_type> <handle_name>;

#define PST_WRITE(buf, len) \
    <transmit_function>((uint8_t*)(buf), (len))

#endif
```

## Test Main

The test `main()` must initialize hardware before calling `PST_MAIN`. Create `pstest_build/test_main.c`:

```c
#include "<board_header.h>"
#include "pstunit.h"

<handle_type> <handle_name>;

static void SystemClock_Config(void);
static void UART_Init(void);

void SysTick_Handler(void) { HAL_IncTick(); }

int main(int argc, char **argv) {
    HAL_Init();
    SystemClock_Config();
    UART_Init();

    PST_REGFCN_CALL(register_xxx_tests);
    return PST_MAIN(argc, argv);
}
```

Copy `SystemClock_Config` and `UART_Init` (including `MspInit`) from the user's sources. Only the clocks and UART are needed — skip LCD, LED, and application logic.

## Toolchain File

Create `pstest_build/toolchain.cmake` matching the user's cross-compiler:

```cmake
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR <arch, e.g. arm>)

set(CMAKE_C_COMPILER <cross-compiler path>)
set(CMAKE_ASM_COMPILER <cross-compiler path>)
set(CMAKE_OBJCOPY <objcopy path>)

set(CMAKE_C_FLAGS_INIT "<target flags, e.g. -mcpu=cortex-m7 -mthumb -mfpu=fpv5-sp-d16 -mfloat-abi=hard>")
set(CMAKE_EXE_LINKER_FLAGS_INIT "<linker flags, e.g. -specs=nosys.specs -specs=nano.specs -Wl,--gc-sections>")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
```

## Tests Only

Create `pstest_build/CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.13.0)
project(MyProject_TargetTest C ASM)

find_package(pstest PATHS "$ENV{POLYSPACE_ROOT}/polyspace/pstest/pstunit/cmake")

# Linker script
set(LINKER_SCRIPT "<path to .ld file>")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -T${LINKER_SCRIPT}")

# Defines
add_definitions(-DUSE_HAL_DRIVER -D<MCU_DEFINE> -DPST_USER_CONFIG)

# Include paths
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}        # for pstest_config.h
    <user include paths>
)

# Application source under test (NOT the user's main.c)
set(APP_SRCS <../Src/app.c ...>)

# HAL/BSP/system sources
set(HAL_SRCS <hal/bsp/system sources from user's CMakeLists>)

# Startup
set(STARTUP <path to startup .s file>)
enable_language(ASM)

# Test sources
file(GLOB TEST_SRCS ../test/*.c)

# Test firmware executable
add_executable(testrunner
    ${APP_SRCS}
    ${HAL_SRCS}
    ${STARTUP}
    ${TEST_SRCS}
    test_main.c
)
target_link_libraries(testrunner pstest::pstest_c)

# Generate hex
add_custom_command(TARGET testrunner POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex testrunner testrunner.hex
)

# Flash and monitor (serial transport — see note below for TCP/IP)
# IMPORTANT: Inline the flash command directly in COMMAND. Do NOT store it in a
# set(FLASH_CMD ...) list variable — CMake expands list variables incorrectly
# when passed through COMMAND with -- separators.
set(PSTEST "$ENV{POLYSPACE_ROOT}/polyspace/bin/polyspace-test<.exe on Windows>")

add_custom_target(run
    COMMAND ${PSTEST} -monitor -com serial -port <port from item 7> -baud-rate <baud from item 7>
            -results-dir ${CMAKE_BINARY_DIR}/results
            -- "<flash executable from item 9>"
            <flash arguments from item 9>
    DEPENDS testrunner
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Report generation from monitor-produced .pstestr
# NOTE: polyspace-test -monitor already produces .pstestr directly — no
# pstest_add_convert_target needed (convert is for CTest MRF output only).
pstest_add_report_target(report RESULTS_DIRS ${CMAKE_BINARY_DIR}/results REPORTS_DIR ${CMAKE_BINARY_DIR}/reports HTML XML)
```

> **TCP/IP transport variant.** If the user picked TCP/IP in item 7 (target board with an on-chip Ethernet/Wi-Fi stack, or a network-connected simulator), replace the serial `run` target with:
>
> ```cmake
> add_custom_target(run
>     COMMAND ${PSTEST} -monitor -com tcpip -ip-addr <IP address from item 7> -ip-port <TCP port from item 7>
>             -results-dir ${CMAKE_BINARY_DIR}/results
>             -- "<flash executable from item 9>"
>             <flash arguments from item 9>
>     DEPENDS testrunner
>     WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
> )
> ```
>
> Everything else (compile, link, flash) stays the same. The transport choice only affects how `polyspace-test -monitor` listens for results streamed back from the board.

Build and run:
```sh
cd pstest_build
mkdir build && cd build
cmake -G "Unix Makefiles" -DCMAKE_TOOLCHAIN_FILE=../toolchain.cmake ..
make
make run
make report
```

## Tests + Profiling

For profiling on target, create a static runtime with a target-specific `psprofile_config.h`.

**`pstest_build/psprofile_config.h`** (target variant):
```c
#ifndef PSPROFILE_CONFIG_H
#define PSPROFILE_CONFIG_H

#define PSPROFILE_SENDING_TYPE              2
#define PSPROFILE_WORKING_BUFFER_SIZE   65536
#define PSPROFILE_HOST_EXECUTION            0
#define PSPROFILE_PROFILING_COUNTER_WIDTH  32

#define PSPROFILE_SAVE_DATETIME         psprofile_save_datetime
#define PSPROFILE_GET_START_DATETIME    psprofile_getdatetime_start
#define PSPROFILE_GET_STOP_DATETIME     psprofile_getdatetime_stop

#endif
```

Key `psprofile_config.h` differences from host:
- `PSPROFILE_HOST_EXECUTION 0` (target, not host).
- `PSPROFILE_SENDING_TYPE 2` (serial output, not file).
- `PSPROFILE_PROFILING_COUNTER_WIDTH 32` (most embedded targets are 32-bit).

**`pstest_build/CMakeLists.txt`:**
```cmake
cmake_minimum_required(VERSION 3.13.0)
project(MyProject_TargetTest C ASM)

find_package(pstest PATHS "$ENV{POLYSPACE_ROOT}/polyspace/pstest/pstunit/cmake")

set(LINKER_SCRIPT "<path to .ld file>")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -T${LINKER_SCRIPT}")

add_definitions(-DUSE_HAL_DRIVER -D<MCU_DEFINE> -DPST_USER_CONFIG)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    <user include paths>
)

# Profiling runtime (target needs a static runtime with custom config)
pstest_add_profiling_runtime(myruntime CONFIG_HEADER_FILE psprofile_config.h STATIC)

# Application source — instrument for coverage
set(APP_SRCS <../Src/app.c ...>)
add_library(app OBJECT ${APP_SRCS})
# NOTE: LEVEL defaults to mcdc (decision + condition + MC/DC). Change to
# `condition/decision` or `decision` per the user's item-4 choice.
pstest_instrument_target(app COVERAGE LEVEL mcdc RUNTIME myruntime)

# HAL/BSP/system sources (not instrumented)
set(HAL_SRCS <hal/bsp/system sources>)
set(STARTUP <startup .s file>)
enable_language(ASM)

# Test sources
file(GLOB TEST_SRCS ../test/*.c)

# Test firmware
add_executable(testrunner
    $<TARGET_OBJECTS:app>
    ${HAL_SRCS}
    ${STARTUP}
    ${TEST_SRCS}
    test_main.c
)
target_link_libraries(testrunner pstest::pstest_c)

# Generate hex
add_custom_command(TARGET testrunner POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex testrunner testrunner.hex
)

# Flash and monitor with profiling (serial transport — for TCP/IP see the note in the tests-only section above)
# IMPORTANT: Inline the flash command directly — do NOT use a set(FLASH_CMD ...) list variable.
set(PSTEST "$ENV{POLYSPACE_ROOT}/polyspace/bin/polyspace-test<.exe on Windows>")

add_custom_target(run
    COMMAND ${PSTEST} -monitor -com serial -port <port from item 7> -baud-rate <baud from item 7>
            -instrum-dir ${CMAKE_BINARY_DIR}/instrum -results-dir ${CMAKE_BINARY_DIR}/results
            -- "<flash executable from item 9>"
            <flash arguments from item 9>
    DEPENDS testrunner
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Report generation (test results + coverage from monitor-produced .pstestr + .psprof)
# NOTE: No pstest_add_convert_target needed — monitor already produces final results.
pstest_add_report_target(report RESULTS_DIRS ${CMAKE_BINARY_DIR}/results REPORTS_DIR ${CMAKE_BINARY_DIR}/reports HTML XML)
```

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
