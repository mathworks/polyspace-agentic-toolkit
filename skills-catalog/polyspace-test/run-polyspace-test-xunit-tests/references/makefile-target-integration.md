# Makefile Target Integration

When the project uses a Makefile to cross-compile for a target board, create a **separate** Makefile named `Makefile.test` rather than modifying the user's existing `Makefile`. This new file re-uses the cross-compiler, linker script, HAL/BSP sources, and flash command from the user's Makefile, and adds the PSTUnit build, `pstest_config.h`, `-D PST_USER_CONFIG` rules, and the `polyspace-test -monitor` invocation that flashes and listens on serial/TCP.

**You MUST create `Makefile.test` and run it with `make -f Makefile.test`.** Do NOT run raw cross-compile or `polyspace-test` commands directly — always go through the Makefile. This lets the user reproduce results independently.

After completing the run, tell the user what file was created (e.g., "I created `Makefile.test` — you can re-run tests anytime with `make -f Makefile.test`").

**Polyspace release compatibility.** All snippets below assume R2026b or later. For releases *older than R2026b*:

- Use `pstunit.c` instead of `pstest.c`
- For any recipe that enables profiling/coverage, also compile `$(POLYSPACEROOT)/polyspace/psprofile/src/psprofile.c`
- Use `-D PST_USER_CONFIG_FILE` instead of `-D PST_USER_CONFIG`
- Use `pstunit_config.h` instead of `pstest_config.h`

## Creating pstest_config.h

Create `<test_dir>/pstest_config.h` containing the mode macro and `PST_WRITE` mapping. Use the transmit function confirmed by the user in item 8.

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

The `extern` declaration must match the UART handle used by the transmit function. The include gives the handle's type definition.

## Test Main

The test `main()` must initialize hardware before calling `PST_MAIN`. Create `<test_dir>/test_main.c`:

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
    /* ... more register calls ... */
    return PST_MAIN(argc, argv);
}
```

Copy `SystemClock_Config` and `UART_Init` (including `MspInit`) from the user's `main.c`. Only the clocks and UART are needed — skip LCD, LED, and application logic.

## Tests Only

```makefile
POLYSPACEROOT = $(subst \,/,$(POLYSPACE_ROOT))
PSTEST_INC = $(POLYSPACEROOT)/polyspace/pstest/pstunit/include
PSTEST_SRC = $(POLYSPACEROOT)/polyspace/pstest/pstunit/src/pstest.c
PSTEST = $(POLYSPACEROOT)/polyspace/bin/polyspace-test

CC = <cross-compiler>
OBJCOPY = <objcopy>
CFLAGS = <target flags from user's Makefile>
INCLUDES = <-I flags from user's Makefile>
LDFLAGS = <linker flags + linker script from user's Makefile>
TEST_DIR = <test_dir>

# Application source under test (NOT main.c — tests provide their own main)
APP_SRCS = <Src/app.c ...>

# HAL/BSP/system sources needed for hardware init
HAL_SRCS = <hal sources from user's Makefile>

# Startup
STARTUP = <startup .s file from user's Makefile>

# Test sources
TESTS = $(wildcard $(TEST_DIR)/*.c)

# Objects — all in flat directory
APP_OBJS = $(notdir $(APP_SRCS:.c=.o))
HAL_OBJS = $(notdir $(HAL_SRCS:.c=.o))
TEST_OBJS = $(notdir $(TESTS:.c=.o))
STARTUP_OBJ = $(notdir $(STARTUP:.s=.o))
PSTEST_OBJ = pstest.o
OBJS = $(APP_OBJS) $(HAL_OBJS) $(TEST_OBJS) $(STARTUP_OBJ) $(PSTEST_OBJ)

PRG = testrunner
HEX = $(PRG).hex

all: $(HEX) run report

# Application sources — compiled with PST_USER_CONFIG
<explicit rules for each app source, e.g.:>
app.o: Src/app.c
	$(CC) $(CFLAGS) $(INCLUDES) -I$(PSTEST_INC) -I$(TEST_DIR) -DPST_USER_CONFIG -c $< -o $@

# HAL/BSP sources — no PSTUnit flags needed
<vpath or explicit rules matching user's Makefile pattern>

# Test sources
$(TEST_OBJS): %.o: $(TEST_DIR)/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -I$(PSTEST_INC) -I$(TEST_DIR) -DPST_USER_CONFIG -c $< -o $@

# PSTUnit framework — needs $(INCLUDES) because pstest_config.h includes board headers
$(PSTEST_OBJ): $(PSTEST_SRC)
	$(CC) $(CFLAGS) $(INCLUDES) -I$(PSTEST_INC) -I$(TEST_DIR) -DPST_USER_CONFIG -c $< -o $@

# Startup
$(STARTUP_OBJ): $(STARTUP)
	$(CC) $(CFLAGS) -c $< -o $@

# Link
$(PRG).elf: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^

# Convert to hex
$(HEX): $(PRG).elf
	$(OBJCOPY) -O ihex $< $@

# Flash and monitor (serial transport — see note below for TCP/IP)
FLASH_CMD = <flash command from item 9>
PORT = <serial port from item 7>
BAUD = <baud rate from item 7>

run: $(HEX)
	$(PSTEST) -monitor -com serial -port $(PORT) -baud-rate $(BAUD) -results-dir results -- $(FLASH_CMD)

report: run
	$(PSTEST) -report -xml -report-dir test_report results/pstest_results.pstestr

clean:
	rm -f $(OBJS) $(PRG).elf $(HEX)
	rm -rf results test_report

.PHONY: all run report clean
```

> **TCP/IP transport variant.** If the user picked TCP/IP in item 7 (target board with an on-chip Ethernet/Wi-Fi stack, or a network-connected simulator), replace the `-com serial -port ... -baud-rate ...` fragment in the `run` recipe with:
>
> ```makefile
> IP_ADDR = <IP address / hostname from item 7>
> IP_PORT = <TCP port from item 7>
>
> run: $(HEX)
> 	$(PSTEST) -monitor -com tcpip -ip-addr $(IP_ADDR) -ip-port $(IP_PORT) -results-dir results -- $(FLASH_CMD)
> ```
>
> Everything else (compile, link, flash) stays the same. The transport choice only affects how `polyspace-test -monitor` listens for results streamed back from the board.

## Tests + Profiling



```makefile
POLYSPACEROOT = $(subst \,/,$(POLYSPACE_ROOT))
PSTEST_INC = $(POLYSPACEROOT)/polyspace/pstest/pstunit/include
PSTEST_SRC = $(POLYSPACEROOT)/polyspace/pstest/pstunit/src/pstest.c
PSPROFILE_INC = $(POLYSPACEROOT)/polyspace/psprofile/include
PSTEST = $(POLYSPACEROOT)/polyspace/bin/polyspace-test
PSPROF = $(POLYSPACEROOT)/polyspace/bin/polyspace-code-profiler

CC = <cross-compiler>
OBJCOPY = <objcopy>
CFLAGS = <target flags from user's Makefile>
INCLUDES = <-I flags from user's Makefile>
LDFLAGS = <linker flags + linker script from user's Makefile>
TEST_DIR = <test_dir>

APP_SRCS = <Src/app.c ...>
HAL_SRCS = <hal sources from user's Makefile>
STARTUP = <startup .s file>
TESTS = $(wildcard $(TEST_DIR)/*.c)

# Instrument only application sources
# NOTE: -limit-instrumentation-to must be repeated for each directory
# NOTE: -cov-metric-level default is mcdc; change to condition/decision or decision per user's item-4 choice
CC_COV = $(PSPROF) -instrument \
  -limit-instrumentation-to <Src> \
  -instrum-dir instrum -cov-metric-level mcdc -- $(CC)

APP_OBJS = $(notdir $(APP_SRCS:.c=.o))
HAL_OBJS = $(notdir $(HAL_SRCS:.c=.o))
TEST_OBJS = $(notdir $(TESTS:.c=.o))
STARTUP_OBJ = $(notdir $(STARTUP:.s=.o))
PSTEST_OBJ = pstest.o
OBJS = $(APP_OBJS) $(HAL_OBJS) $(TEST_OBJS) $(STARTUP_OBJ) $(PSTEST_OBJ)

PRG = testrunner
HEX = $(PRG).hex

all: $(HEX) run report

# Application sources — instrumented + PST_USER_CONFIG
<explicit rules using $(CC_COV) instead of $(CC), e.g.:>
app.o: Src/app.c
	$(CC_COV) $(CFLAGS) $(INCLUDES) -I$(PSTEST_INC) -I$(PSPROFILE_INC) -I$(TEST_DIR) -DPST_USER_CONFIG -c $< -o $@

# HAL/BSP sources — no instrumentation, no PSTUnit flags
<vpath or explicit rules matching user's Makefile pattern>

# Test sources — no instrumentation
$(TEST_OBJS): %.o: $(TEST_DIR)/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -I$(PSTEST_INC) -I$(PSPROFILE_INC) -I$(TEST_DIR) -DPST_USER_CONFIG -c $< -o $@

# PSTUnit framework
$(PSTEST_OBJ): $(PSTEST_SRC)
	$(CC) $(CFLAGS) $(INCLUDES) -I$(PSTEST_INC) -I$(PSPROFILE_INC) -I$(TEST_DIR) -DPST_USER_CONFIG -c $< -o $@

# Startup
$(STARTUP_OBJ): $(STARTUP)
	$(CC) $(CFLAGS) -c $< -o $@

# Link
$(PRG).elf: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^

$(HEX): $(PRG).elf
	$(OBJCOPY) -O ihex $< $@

# Flash and monitor with profiling (serial transport — for TCP/IP use
# `-com tcpip -ip-addr $(IP_ADDR) -ip-port $(IP_PORT)` instead of the
# `-com serial -port $(PORT) -baud-rate $(BAUD)` fragment; see the TCP/IP
# variant note in the tests-only section above.)
FLASH_CMD = <flash command from item 9>
PORT = <serial port from item 7>
BAUD = <baud rate from item 7>

run: $(HEX)
	$(PSTEST) -monitor -com serial -port $(PORT) -baud-rate $(BAUD) -instrum-dir instrum -results-dir results -- $(FLASH_CMD)

report: run
	$(PSTEST) -report -xml -report-dir coverage_report results/pstest_results.psprof

clean:
	rm -f $(OBJS) $(PRG).elf $(HEX)
	rm -rf instrum results coverage_report

.PHONY: all run report clean
```

Key differences from tests-only:
- Application sources compiled with `$(CC_COV)` (wrapped in profiler); HAL/test files use plain `$(CC)`.
- Add `-I$(PSPROFILE_INC)` to all compile rules that use `-DPST_USER_CONFIG`.
- Pass `-instrum-dir instrum` to `$(PSTEST) -monitor` so it collects profiling data.
- `-cov-metric-level` defaults to `mcdc`; change per the user's item-4 choice (`condition/decision` or `decision`).
- `-limit-instrumentation-to` must be repeated once per source directory (does NOT accept space-separated paths).

---

Copyright 2026 The MathWorks, Inc.

---
