#include <vector>
#include <string>
#include <algorithm>
#include <numeric>
#include <stdint.h>

extern "C" {
    int64_t cpp_sort_and_median(int64_t* data, int64_t len) {
        std::vector<int64_t> v(data, data + len);
        std::sort(v.begin(), v.end());
        for (int64_t i = 0; i < len; ++i) {
            data[i] = v[i];
        }
        return v[len / 2];
    }

    int cpp_join_strings_len(const char* prefix, const char* suffix) {
        std::string s = prefix;
        s += "::";
        s += suffix;
        return static_cast<int>(s.length());
    }
}
