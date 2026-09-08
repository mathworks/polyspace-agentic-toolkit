---
name: run-polyspace-test-xunit-tests
description: Builds and runs C/C++ PSTUnit (Polyspace Test xUnit) tests, on host or target, optionally collecting coverage/profiling. A test is PSTUnit when its sources include `<pstunit.h>` or `PST_*` macros.
license: MathWorks BSD-3-Clause
metadata:
  version: "1.2"
---

## Purpose

Build and run Polyspace Test xUnit tests (and optionally collect code profiling/coverage). Works on host or target.

## When NOT to Use

- **Authoring new tests from scratch.** If the user needs to *write* PSTUnit test cases, invoke the `generate-polyspace-test-xunit-tests` skill instead. Return here once test sources exist and need to be compiled and run.

## Determine Configuration

1. **Execution target** — **Host**, unless the user names embedded hardware, a
   board, a flash step, or a serial/TCP transport. Default: **Host**.

2. **Compiler** — whatever the build files specify; otherwise the platform
   default, **`gcc`**. (Target builds use the cross-compiler named by the
   toolchain/build files, e.g. `arm-none-eabi-gcc`, `armclang`, `iccarm`.)

3. **Code coverage** — **off**, unless the user asks for coverage or profiling.

4. **Coverage level** — only relevant when coverage is on. Default: **MC/DC**
   (decision + condition + MC/DC). Lighter options, if the user asks:
   **condition/decision**, or **decision**.

5. **Build system** — **detect from the workspace**: a `Makefile` → Makefile
   flow; a `CMakeLists.txt` → CMake flow; neither → build directly.

6. **Running the executable** — build *and* run the tests.

### Target execution (embedded hardware)

A **Target** run needs three things that cannot be inferred (items 7–9); if the
user asked for a target run without providing them, ask for these, then proceed.
The target reference files refer back to these item numbers.

7. **Transport** — serial or TCP/IP.
   - **serial** — which serial port and baud rate? (e.g. `COM6`, `115200`).
   - **TCP/IP** — which IP/hostname and port does the target listen on?
     (Polyspace default port `17725`; the board firmware may differ.)

8. **Transmit function** — what sends debug output over that transport?
   - Serial: `HAL_UART_Transmit(&huart1, (uint8_t*)buf, len, HAL_MAX_DELAY)`,
     `CDC_Transmit_FS((uint8_t*)buf, len)`, `SEGGER_RTT_Write(0, buf, len)`,
     `cyhal_uart_write(&uart_obj, buf, &len)`.
   - TCP/IP: `send(sock_fd, buf, len, 0)` (BSD sockets / lwIP),
     `netconn_write(conn, buf, len, NETCONN_COPY)` (lwIP netconn API).

9. **Flash/launch command** — e.g.
   `STM32_Programmer_CLI.exe --connect port=swd --download firmware.hex --go`.

## Getting Started

**CRITICAL: Invoke `resolve-polyspace-root` BEFORE doing anything else.** The resolved path is POLYSPACE_ROOT. Do NOT substitute any other path, including the working directory. The user's working directory (e.g., D:/Polyspace/...) is NOT the Polyspace installation.

**Check for PST_MAIN:** Grep the test sources for `PST_MAIN`. If it does not exist, load the `generate-main.md` reference to generate it.

### Simple Path: Quick "Did the tests pass?" run

**Use ONLY when all of the following are true:**
- Host execution (item 1 = Host)
- No coverage requested (item 3 = No)
- No build system detected (item 5 = not detected)
- The user has not asked for a persistent artefact such as a report

Compile and run directly:

```sh
<COMPILER> -c <src files> <test files> $POLYSPACE_ROOT/polyspace/pstest/pstunit/src/pstest.c \
    -I<include paths> -I$POLYSPACE_ROOT/polyspace/pstest/pstunit/include
<COMPILER> -o testrunner <all .o files>
./testrunner[.exe]
```

**Useful flags:** `-test <name>` runs a subset, `-format table` prints a results table. Use `-help` to see all options.

> **PSTUnit source-file name changed in R2026b.** If `pstest.c` does not exist (R2026a and earlier), use `pstunit.c` instead.

### All Other Cases — Load Reference

For anything other than the simple path, load the matching reference file and follow it exactly:

- **Makefile Detected + Host Execution** → load `references/makefile-integration.md`
- **Makefile Detected + Target Execution** → load `references/makefile-target-integration.md`
- **CMake Detected + Host Execution** → load `references/cmake-integration.md`
- **CMake Detected + Target Execution** → load `references/cmake-target-integration.md`
- **Build System Not Detected** → load `references/raw-commands.md`

### Additional References (Load on Demand)

- **Build or runtime error diagnosis** → load `references/common-errors.md` when the build fails, the test binary crashes, tests are silently skipped, or `PST_SUITE`/`PST_MAIN`/`PST_REGFCN_CALL` compile errors appear.

---

Copyright 2026 The MathWorks, Inc.

---
