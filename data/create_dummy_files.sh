#!/bin/bash

readonly output_prefix=processTime
readonly execute_file=target

cat <<- _EOF_ | gcc -o ${execute_file} -xc - -lm
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <math.h>
#define INIT_SEED (12345)
#define MAX_LOOP (32)
#define MAX_ITER (1000 * 1000 * 10)

int main(int argc, char **argv) {
    int32_t i;
    uint32_t seed;
    uint64_t iter, max_iter;
    clock_t start_clock, end_clock;

    if (argc == 2) {
        seed = (uint32_t)atol(argv[0]);
    }
    else {
        seed = (uint32_t)INIT_SEED;
    }
    srand(seed);

    for (i = 0; i < (int32_t)MAX_LOOP; i++) {
        max_iter = (uint64_t)MAX_ITER + (uint64_t)rand() % (uint64_t)MAX_ITER;

        start_clock = clock();
        for (iter = 0; iter < max_iter; iter++) {
            sin(2.0 * M_PI * (double)iter / (double)max_iter);
            cos(2.0 * M_PI * (double)iter / (double)max_iter);
            log(1.0 + (double)iter / (double)max_iter);
        }
        end_clock = clock();

        // output elapse time [sec]
        printf("%.5f\n", (double)(end_clock - start_clock) / (double)CLOCKS_PER_SEC);
    }

    return 0;
}
_EOF_

seq -w 1 20 | while read num; do
    seed=$(echo ${num} | sed -e "s|^0*||g")
    echo process: ${num}, seed: ${seed}
    ./${execute_file} ${seed} > ${output_prefix}_${num}.txt
done
rm -f ${execute_file}
