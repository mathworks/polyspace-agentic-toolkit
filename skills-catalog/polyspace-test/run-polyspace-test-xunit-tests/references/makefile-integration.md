# Makefile Integration

When the project uses a Makefile, create a **separate** Makefile named `Makefile.test` rather than modifying the user's existing `Makefile`. This new file re-uses the source list and include paths from the user's Makefile, and adds the PSTUnit build + `polyspace-test -monitor` execution rules.

**You MUST create `Makefile.test` and run it with `make -f Makefile.test`.** Do NOT run raw `gcc` or `polyspace-test` commands directly — always go through the Makefile. This lets the user reproduce results independently.

After completing the run, tell the user what file was created (e.g., "I created `Makefile.test` — you can re-run tests anytime with `make -f Makefile.test`").

**Polyspace release compatibility.** All snippets below assume R2026b or later, which unifies the PSTUnit runtime into a single source file. For releases *older than R2026b* the workflow needs two files:

- The **tests-only** recipe compiles `pstest.c` in R2026b+. Pre-R2026b, replace it with `pstunit.c` in the same directory — i.e. `$(POLYSPACEROOT)/polyspace/pstest/pstunit/src/pstunit.c`.
- The **tests + profiling** recipe compiles the same `pstest.c` in R2026b+. Pre-R2026b, it needs BOTH `pstunit.c` (xUnit API definitions) AND `psprofile.c` for source-code profiling. Add:
  ```makefile
  PSPROFILE_SRC = $(POLYSPACEROOT)/polyspace/psprofile/src/psprofile.c
  ```
  and compile `psprofile.o` alongside `pstest.o` in the OBJS list.

## Tests Only

```makefile
POLYSPACEROOT = $(subst \,/,$(POLYSPACE_ROOT))
PSTEST_INC = $(POLYSPACEROOT)/polyspace/pstest/pstunit/include
PSTEST_SRC = $(POLYSPACEROOT)/polyspace/pstest/pstunit/src/pstest.c
PSTEST = $(POLYSPACEROOT)/polyspace/bin/polyspace-test
CC = <compiler>
CFLAGS = <flags from user's Makefile, e.g. -Wall -Wextra -g>
INCLUDES = <-I flags from user's Makefile>
TEST_DIR = <test_dir>

# List source files EXPLICITLY as in user's Makefile. Do NOT use $(wildcard src/*.c) —
# it silently misses nested subdirectories like src/hal/, src/drivers/, etc.
SRCS = <src/file1.c src/sub/file2.c ...>
TESTS = $(wildcard $(TEST_DIR)/*.c)
OBJS = $(SRCS:.c=.o) $(TESTS:.c=.o) pstest.o
PRG = testrunner

all: $(PRG) run report

%.o: %.c
	$(CC) $(CFLAGS) -c $< $(INCLUDES) -I$(PSTEST_INC) -DPST_MONITOR_MODE -o $@

pstest.o: $(PSTEST_SRC)
	$(CC) -c $< -I$(PSTEST_INC) -DPST_MONITOR_MODE -o $@

$(PRG): $(OBJS)
	$(CC) -o $@ $^

run: $(PRG)
	$(PSTEST) -monitor -results-dir results -- ./$(PRG)

report: run
	$(PSTEST) -report -xml -report-dir test_report results/pstest_results.pstestr

clean:
	rm -f $(SRCS:.c=.o) $(TESTS:.c=.o) pstest.o $(PRG)
	rm -rf results test_report

.PHONY: all run clean report
```

## Tests + Profiling



```makefile
POLYSPACEROOT = $(subst \,/,$(POLYSPACE_ROOT))
PSTEST_INC = $(POLYSPACEROOT)/polyspace/pstest/pstunit/include
PSTEST_SRC = $(POLYSPACEROOT)/polyspace/pstest/pstunit/src/pstest.c
PSPROFILE_INC = $(POLYSPACEROOT)/polyspace/psprofile/include
PSTEST = $(POLYSPACEROOT)/polyspace/bin/polyspace-test
PSPROF = $(POLYSPACEROOT)/polyspace/bin/polyspace-code-profiler
CC = <compiler>
CFLAGS = <flags from user's Makefile, e.g. -Wall -Wextra -g>
INCLUDES = <-I flags from user's Makefile>
TEST_DIR = <test_dir>

# List source files EXPLICITLY as in user's Makefile. Do NOT use $(wildcard src/*.c) —
# it silently misses nested subdirectories like src/hal/, src/drivers/, etc.
SRCS = <src/file1.c src/sub/file2.c ...>

# Instrument only source files, not tests
# NOTE: -limit-instrumentation-to must be repeated for each directory
# NOTE: -cov-metric-level default is mcdc; change to condition/decision or decision per user's item-4 choice
CC_COV = $(PSPROF) -instrument \
  -limit-instrumentation-to <src/dir1> \
  -limit-instrumentation-to <src/dir2> \
  -instrum-dir instrum -cov-metric-level mcdc -- $(CC)

TESTS = $(wildcard $(TEST_DIR)/*.c)
SRC_OBJS = $(SRCS:.c=.o)
TEST_OBJS = $(TESTS:.c=.o)
OBJS = $(SRC_OBJS) $(TEST_OBJS) pstest.o
PRG = testrunner

all: $(PRG) run report

# Source files — compiled through profiler
$(SRC_OBJS): %.o: %.c
	$(CC_COV) $(CFLAGS) -c $< $(INCLUDES) -I$(PSTEST_INC) -I$(PSPROFILE_INC) -DPST_MONITOR_MODE_WITH_PROFILING -o $@

# Test files — compiled without profiler
$(TEST_OBJS): %.o: %.c
	$(CC) $(CFLAGS) -c $< $(INCLUDES) -I$(PSTEST_INC) -I$(PSPROFILE_INC) -DPST_MONITOR_MODE_WITH_PROFILING -o $@

pstest.o: $(PSTEST_SRC)
	$(CC) -c $< -I$(PSTEST_INC) -I$(PSPROFILE_INC) -DPST_MONITOR_MODE_WITH_PROFILING -o $@

$(PRG): $(OBJS)
	$(CC) -o $@ $^

run: $(PRG)
	$(PSTEST) -monitor -instrum-dir instrum -results-dir results -- ./$(PRG)

report: run
	$(PSTEST) -report -xml -report-dir coverage_report results/pstest_results.psprof

clean:
	rm -f $(SRC_OBJS) $(TEST_OBJS) pstest.o $(PRG)
	rm -rf instrum results coverage_report

.PHONY: all run report clean
```

Key differences from tests-only:
- Source files are compiled with `$(CC_COV)` (wrapped in profiler); test files use plain `$(CC)`.
- Use `-DPST_MONITOR_MODE_WITH_PROFILING` instead of `-DPST_MONITOR_MODE`.
- Pass `-instrum-dir instrum` to `$(PSTEST) -monitor` so it collects profiling data.
- `-cov-metric-level` defaults to `mcdc`; change per the user's item-4 choice (`condition/decision` or `decision`).
- `-limit-instrumentation-to` must be repeated once per source directory (it does NOT accept space-separated paths).

---

Copyright 2026 The MathWorks, Inc.

---
