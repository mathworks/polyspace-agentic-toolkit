# Raw Commands (No Build System)

Use these commands when no Makefile or CMakeLists.txt is detected in the user's project.

**You MUST author a reproducible script (`run_tests.sh` on Linux/macOS or `run_tests.bat` on Windows) that contains every command you actually ran, in order.** After completing the run, tell the user what file was created (e.g., "I created `run_tests.sh` — you can re-run everything with `./run_tests.sh`"). 

## Paths Needed

```sh
PSTEST_INC=$POLYSPACE_ROOT/polyspace/pstest/pstunit/include
PSTEST_SRC=$POLYSPACE_ROOT/polyspace/pstest/pstunit/src/pstest.c
```

**Polyspace release compatibility.** For R2026a or earlier releases:

- Use `pstunit.c` instead of `pstest.c`
- For any recipe that enables profiling/coverage, also compile `$POLYSPACE_ROOT/polyspace/psprofile/src/psprofile.c`
- Use `-D PST_USER_CONFIG_FILE` instead of `-D PST_USER_CONFIG`
- Use `pstunit_config.h` instead of `pstest_config.h`

All snippets below assume R2026b or later.

**Executables:**
```
PSTEST=$POLYSPACE_ROOT/polyspace/bin/polyspace-test[.exe]
PROFILER=$POLYSPACE_ROOT/polyspace/bin/polyspace-code-profiler[.exe]
```

## Template for `run_tests` Script

**`run_tests.sh` template** (Linux/macOS, bash):
```sh
#!/usr/bin/env bash
# Reproduces the PSTUnit test run authored by the run-polyspace-test-xunit-tests skill.
# Prerequisites: POLYSPACE_ROOT set, <compiler> in PATH.
set -euo pipefail # Enables strict mode. Script stops with error when a command fails.

POLYSPACE_ROOT="${POLYSPACE_ROOT:?POLYSPACE_ROOT must be set}"
PSTEST_INC="$POLYSPACE_ROOT/polyspace/pstest/pstunit/include"
PSTEST_SRC="$POLYSPACE_ROOT/polyspace/pstest/pstunit/src/pstest.c"
PSTEST="$POLYSPACE_ROOT/polyspace/bin/polyspace-test"
# PROFILER="$POLYSPACE_ROOT/polyspace/bin/polyspace-code-profiler"   # uncomment for coverage
# PSPROFILE_INC="$POLYSPACE_ROOT/polyspace/psprofile/include"        # uncomment for coverage

# --- Build, run, and (optionally) report commands appended below ---
```

**`run_tests.bat` template** (Windows, cmd):
```bat
@echo off
REM Reproduces the PSTUnit test run authored by the run-polyspace-test-xunit-tests skill.
REM Prerequisites: POLYSPACE_ROOT set, <compiler> on PATH.
setlocal enableextensions
if not defined POLYSPACE_ROOT ( echo POLYSPACE_ROOT must be set & exit /b 1 )

set "PSTEST_INC=%POLYSPACE_ROOT%\polyspace\pstest\pstunit\include"
set "PSTEST_SRC=%POLYSPACE_ROOT%\polyspace\pstest\pstunit\src\pstest.c"
set "PSTEST=%POLYSPACE_ROOT%\polyspace\bin\polyspace-test.exe"
REM set "PROFILER=%POLYSPACE_ROOT%\polyspace\bin\polyspace-code-profiler.exe"   REM uncomment for coverage
REM set "PSPROFILE_INC=%POLYSPACE_ROOT%\polyspace\psprofile\include"           REM uncomment for coverage

REM --- Build, run, and (optionally) report commands appended below ---
```

## Host Execution (Tests Only)


```sh
<COMPILER> -c src.c tests.c main.c $PSTEST_SRC -I$PSTEST_INC -D PST_MONITOR_MODE
<COMPILER> -o testrunner src.o tests.o main.o pstest.o
$PSTEST -monitor -results-dir results -- ./testrunner
```

Produces `.pstestr` in `results/`.

## Host Execution (Tests + Profiling)


```sh
# -cov-metric-level default is mcdc (decision + condition + MC/DC).
# Replace with `condition/decision` or `decision` per the user's item-4 choice.
$PROFILER -instrument -instrum-dir instrum -limit-instrumentation-to <src_dir> \
    -cov-metric-level mcdc \
    -- <COMPILER> -c src.c tests.c main.c $PSTEST_SRC \
       -I$PSTEST_INC -I$PSPROFILE_INC -D PST_MONITOR_MODE_WITH_PROFILING
<COMPILER> -o testrunner src.o tests.o main.o pstest.o
$PSTEST -monitor -instrum-dir instrum -results-dir results -- ./testrunner
```

Produces both `.pstestr` and `.psprof` in `results/`.

If source and test files are in the same folder, add `-ignore-file <test_file>` to the `$PROFILER -instrument` command for each test file so they are not instrumented.

Additional path needed for profiling:
```
PSPROFILE_INC=$POLYSPACE_ROOT/polyspace/psprofile/include
```

## Target Execution

Requires a `pstest_config.h` with `PST_WRITE` mapped to the target's transport function. For signature and example of `<user_transport_fn>`, see `ref_config.c`.

**pstest_config.h (tests only):**
```c
#define PST_MONITOR_MODE 1
#define PST_ENABLE_EXECUTION_TIME 0
extern void <user_transport_fn>(<params>);
#define PST_WRITE(str, len) <user_transport_fn>(str, len)
```

**pstest_config.h (tests + profiling):**
```c
#define PST_MONITOR_MODE_WITH_PROFILING 1
#define PST_ENABLE_EXECUTION_TIME 0
extern void <user_transport_fn>(<params>);
#define PST_WRITE(str, len) <user_transport_fn>(str, len)
```

Build with `-D PST_USER_CONFIG`:
```sh
<COMPILER> -c src.c tests.c main.c $PSTEST_SRC -I$PSTEST_INC -I<config_dir> -D PST_USER_CONFIG
<COMPILER> -o firmware.elf src.o tests.o main.o pstest.o
```

Run with monitor listening on serial:
```sh
$PSTEST -monitor -com serial -port <PORT> -baud-rate <BAUD> -results-dir results -- <flash_command>
```

Or TCP:
```sh
$PSTEST -monitor -com tcpip -ip-addr <ADDR> -ip-port <PORT> -results-dir results -- <flash_command>
```
Example flash command:
```sh
STM32_Programmer_CLI.exe --connect port=swd --download firmware.elf --go
```
## Generating Reports

Reports are generated from the artefacts produced by `polyspace-test -monitor`:
- `.pstestr` → **test results report** (pass/fail per assertion, per test, per suite)
- `.psprof` → **coverage report** (per-file / per-function coverage metrics at the requested level)

**Test results report (from `.pstestr`):**
```sh
# XML
$PSTEST -report -report-dir report -xml results/pstest_results.pstestr

# HTML
$PSTEST -report -report-dir report -html results/pstest_results.pstestr

# HTML, showing only failing assessments
$PSTEST -report -report-dir report -html results/pstest_results.pstestr -omit-passed-assessments
```

**Coverage report (from `.psprof`):**
```sh
# XML
$PSTEST -report -report-dir report -xml results/pstest_results.psprof

# HTML
$PSTEST -report -report-dir report -html results/pstest_results.psprof
```

**Combined test + coverage report** (point `-report` at the whole results directory):
```sh
$PSTEST -report -report-dir report -xml results
$PSTEST -report -report-dir report -html results
```

This produces `report/pstest_results/pstunit/pstest_results.xml` (test results) and `report/pstest_results/profiling/pstest_results.xml` (coverage) in one invocation, assuming the monitor produced the standard `pstest_results.pstestr` + `pstest_results.psprof` filenames.

---

Copyright 2026 The MathWorks, Inc.

---
