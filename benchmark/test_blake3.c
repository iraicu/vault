#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "../blake3.h"

#define HASH_SIZE 32
#define MAX_INPUT_SIZE 256

void print_hash(uint8_t *hash)
{
    for (size_t i = 0; i < HASH_SIZE; i++)
    {
        printf("%02x", hash[i]);
    }
    printf("\n");
}

int main()
{
    uint8_t hash[HASH_SIZE];
    uint8_t input[MAX_INPUT_SIZE];

    for (size_t i = 0; i < MAX_INPUT_SIZE; i++)
    {
        input[i] = (uint8_t)(i % 256);
    }

    for (size_t size = 1; size <= MAX_INPUT_SIZE; size *= 2)
    {
        printf("Input size: %zu bytes\n", size);

        blake3_hasher hasher;
        blake3_hasher_init(&hasher);
        blake3_hasher_update(&hasher, input, size);
        blake3_hasher_finalize(&hasher, hash, HASH_SIZE);

        print_hash(hash);
    }

    return 0;
}