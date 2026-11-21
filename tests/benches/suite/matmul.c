#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static unsigned long long get_time_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (unsigned long long)ts.tv_sec * 1000ULL + (unsigned long long)(ts.tv_nsec / 1000000ULL);
}

int main(void) {
    size_t n = 512;
    size_t total_elements = n * n;
    size_t bytes = total_elements * sizeof(double);

    double* a = (double*)malloc(bytes);
    double* b = (double*)malloc(bytes);
    double* c = (double*)malloc(bytes);

    for (size_t i = 0; i < total_elements; ++i) {
        a[i] = ((double)(i % 100)) * 0.01;
        b[i] = ((double)((i + 50) % 100)) * 0.01;
        c[i] = 0.0;
    }

    unsigned long long t0 = get_time_ms();

    for (size_t row = 0; row < n; ++row) {
        for (size_t col = 0; col < n; ++col) {
            double sum = 0.0;
            for (size_t k = 0; k < n; ++k) {
                sum += a[row * n + k] * b[k * n + col];
            }
            c[row * n + col] = sum;
        }
    }

    unsigned long long elapsed_ms = get_time_ms() - t0;

    double checksum = 0.0;
    for (size_t ci = 0; ci < total_elements; ci += 1024) {
        checksum += c[ci];
    }

    free(a);
    free(b);
    free(c);

    printf("C_MATMUL_RESULT: %llu ms (checksum: %lld)\n", elapsed_ms, (long long)checksum);
    return 0;
}
