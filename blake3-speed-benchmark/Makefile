# Makefile to compile test_blake3.c with Blake3 library files

# Set the compiler and flags
CC = gcc
CFLAGS = -O3 -Wall -Wextra -std=c11 -pedantic -fstack-protector-strong -D_FORTIFY_SOURCE=2 -fPIE -fvisibility=hidden
LDFLAGS = -pie -Wl,-z,relro,-z,now

# Path to Blake3 source files (parent directory)
BLAKE3_SRC = ../

# List of source files from Blake3
BLAKE3_FILES = $(BLAKE3_SRC)blake3.c $(BLAKE3_SRC)blake3_dispatch.c $(BLAKE3_SRC)blake3_portable.c

# Assembly optimization files
ASM_FILES = $(BLAKE3_SRC)blake3_sse2_x86-64_unix.S $(BLAKE3_SRC)blake3_sse41_x86-64_unix.S \
            $(BLAKE3_SRC)blake3_avx2_x86-64_unix.S $(BLAKE3_SRC)blake3_avx512_x86-64_unix.S

# Test file
TEST_FILE = test_blake3.c

# Output binary name
OUTPUT = test_blake3

# Compilation target: build the test binary
all: $(OUTPUT)

$(OUTPUT): $(TEST_FILE) $(BLAKE3_FILES) $(ASM_FILES)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

# Clean up the generated files
clean:
	rm -f $(OUTPUT) *.o

# Phony targets
.PHONY: all clean
