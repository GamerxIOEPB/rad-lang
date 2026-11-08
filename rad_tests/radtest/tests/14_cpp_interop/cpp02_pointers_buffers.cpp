#include <cstring>
#include <stdint.h>

extern "C" {
    void cpp_fill_buffer(char* buf, int len) {
        for (int i = 0; i < len - 1; ++i) {
            buf[i] = 'A' + (i % 26);
        }
        buf[len - 1] = '\0';
    }

    int64_t cpp_sum_array(const int64_t* arr, int64_t count) {
        int64_t total = 0;
        for (int64_t i = 0; i < count; ++i) {
            total += arr[i];
        }
        return total;
    }
}
