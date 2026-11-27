// Benchmark: Allocation & Array Iteration (1,000,000 elements x 10 runs)
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

int main() {
    size_t n = 1000000;
    size_t iterations = 10;

    struct timespec ts_start, ts_end;
    clock_gettime(CLOCK_MONOTONIC, &ts_start);

    int64_t total_sum = 0;
    for (size_t iter = 0; iter < iterations; ++iter) {
        int64_t* p = (int64_t*)malloc(n * sizeof(int64_t));
        for (size_t i = 0; i < n; ++i) {
            p[i] = (int64_t)i + (int64_t)iter;
        }
        int64_t s = 0;
        for (size_t i = 0; i < n; ++i) {
            s += p[i];
        }
        total_sum += s;
        free(p);
    }

    clock_gettime(CLOCK_MONOTONIC, &ts_end);
    uint64_t elapsed_ms = (ts_end.tv_sec - ts_start.tv_sec) * 1000 + (ts_end.tv_nsec - ts_start.tv_nsec) / 1000000;

    printf("C_ALLOC_RESULT: %llu ms (sum: %lld)\n", (unsigned long long)elapsed_ms, (long long)total_sum);
    return 0;
}
