/*
 * Copyright 2026 The MathWorks, Inc.
 *
 * Reference implementation of transport functions for self-managed builds.
 * This file writes test/profiling output to local files (simulating data
 * capture from target hardware). On real targets, replace file I/O with
 * your transport (UART, SPI, flash, shared memory, etc.).
 */

#include <stdio.h>

/* --- Test output transport (used by test config) --- */

static FILE *test_output = NULL;

void pst_write(const char *str, unsigned long len) {
    if (!test_output) {
        test_output = fopen("out_test.mrf", "ab");
    }
    if (test_output) {
        fwrite(str, 1, len, test_output);
        fflush(test_output);
    }
}
