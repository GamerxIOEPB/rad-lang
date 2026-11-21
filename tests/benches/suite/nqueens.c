#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static unsigned long long get_time_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (unsigned long long)ts.tv_sec * 1000ULL + (unsigned long long)(ts.tv_nsec / 1000000ULL);
}

static long long solve_nqueens(int n, int row, int* cols, int* diag1, int* diag2) {
    if (row == n) return 1LL;
    long long count = 0;
    for (int col = 0; col < n; ++col) {
        int d1 = row - col + n;
        int d2 = row + col;
        if (cols[col] == 0 && diag1[d1] == 0 && diag2[d2] == 0) {
            cols[col] = 1;
            diag1[d1] = 1;
            diag2[d2] = 1;

            count += solve_nqueens(n, row + 1, cols, diag1, diag2);

            cols[col] = 0;
            diag1[d1] = 0;
            diag2[d2] = 0;
        }
    }
    return count;
}

int main(void) {
    int n = 14;
    int cols[16] = {0};
    int diag1[32] = {0};
    int diag2[32] = {0};

    unsigned long long t0 = get_time_ms();
    long long solutions = solve_nqueens(n, 0, cols, diag1, diag2);
    unsigned long long elapsed_ms = get_time_ms() - t0;

    printf("C_NQUEENS_RESULT: %llu ms (solutions: %lld)\n", elapsed_ms, solutions);
    return 0;
}
