# Generate Test Main

**You MUST run `polyspace-test -generate` to create the test main. Do NOT write it by hand.**

## Paths Needed

```sh
PSTEST=$POLYSPACE_ROOT/polyspace/bin/polyspace-test[.exe]
```

## Command

```sh
$PSTEST -generate -main -registration \
    -results-dir <output_dir> \
    -test-sources <test1.c> <test2.c> ... \
    -filename generated_main.c
```

The generated file contains everything: `PST_TEST_VAR_EXTERN` declarations, the registration function, and `main()` like this:

   ```c
   int main(int argc, char **argv) {
       PST_REGFCN_CALL(testRegistration);
       return PST_MAIN(argc, argv);         
   }
   ```

Include it in the build alongside the test source files.


## Target Execution — Patching the Generated Main

For target builds, `main()` must initialize hardware before `PST_MAIN` is called. After generating the file:

1. Add the necessary `#include` directives for the board/HAL headers at the top
2. Add any global handle declarations needed by the transmit function (from item 8), e.g. `UART_HandleTypeDef huart1;`
3. Copy the hardware init functions from the user's `main.c` — only what's needed for clocks and the transport confirmed in item 8 (e.g., `SystemClock_Config` + `UART_Init` + `MspInit` for UART). Skip LCD, LED, and application logic.
4. Insert the hardware init calls at the start of `main()`, before the generated `PST_REGFCN_CALL(testRegistration)` line:
   ```c
   int main(int argc, char **argv) {
       HAL_Init();            // example for STM32 HAL
       SystemClock_Config();
       UART_Init();           // init transport from item 8

       PST_REGFCN_CALL(testRegistration);  // already generated — leave as-is
       return PST_MAIN(argc, argv);         // already generated — leave as-is
   }
   ```

---

Copyright 2026 The MathWorks, Inc.

---
