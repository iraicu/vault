#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include "../blake3.h"

#define HASH_SIZE 32
#define MAX_INPUT_SIZE 256
#define ITERATIONS 1000
#define CONVERSION_FACTOR 1000

void print_hash(uint8_t *hash)
{
    for (size_t i = 0; i < HASH_SIZE; i++)
    {
        printf("%02x", hash[i]);
    }
    printf("\n");
}

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        fprintf(stderr, "Usage: %s <input_size>\n", argv[0]);
        return EXIT_FAILURE;
    }

    size_t input_size = atoi(argv[1]);
    if (input_size == 0 || input_size > MAX_INPUT_SIZE)
    {
        fprintf(stderr, "Error: input size must be between 1 and %d bytes.\n", MAX_INPUT_SIZE);
        return EXIT_FAILURE;
    }

    uint8_t hash[HASH_SIZE];
    uint8_t input[MAX_INPUT_SIZE];

    // Fill the input array with predictable data
    for (size_t i = 0; i < MAX_INPUT_SIZE; i++)
    {
        input[i] = (uint8_t)(i % 256);
    }

    clock_t start_time = clock();

    for (size_t i = 0; i < ITERATIONS; i++)
    {
        blake3_hasher hasher;
        blake3_hasher_init(&hasher);
        blake3_hasher_update(&hasher, input, input_size);
        blake3_hasher_finalize(&hasher, hash, HASH_SIZE);
    }

    clock_t end_time = clock();
    double total_time = (double)(end_time - start_time) / CLOCKS_PER_SEC;
    double avg_time_per_hash = total_time / ITERATIONS * CONVERSION_FACTOR * CONVERSION_FACTOR * CONVERSION_FACTOR;

    printf("Input size: %zu bytes\n", input_size);
    printf("Total time for %d hashes: %.6f seconds\n", ITERATIONS, total_time);
    printf("Average time per hash: %.f nanoseconds\n", avg_time_per_hash);

    return EXIT_SUCCESS;
}
