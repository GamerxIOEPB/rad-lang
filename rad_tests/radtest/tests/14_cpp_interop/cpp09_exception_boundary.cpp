#include <stdexcept>
#include <string>

extern "C" {
    int cpp_safe_divide(int a, int b, int* out_res) noexcept {
        try {
            if (b == 0) {
                throw std::invalid_argument("division by zero");
            }
            if (out_res) *out_res = a / b;
            return 0;
        } catch (const std::exception& e) {
            return 1;
        } catch (...) {
            return 2;
        }
    }

    int cpp_parse_integer_safe(const char* s, int* out_val) noexcept {
        try {
            if (!s || *s == '\0') {
                throw std::runtime_error("empty string");
            }
            int val = std::stoi(std::string(s));
            if (out_val) *out_val = val;
            return 0;
        } catch (...) {
            return -1;
        }
    }
}
