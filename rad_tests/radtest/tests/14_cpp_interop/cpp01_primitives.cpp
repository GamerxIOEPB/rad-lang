extern "C" {
    int cpp_add_i32(int a, int b) {
        return a + b;
    }
    long long cpp_mul_i64(long long a, long long b) {
        return a * b;
    }
    double cpp_hypot_f64(double x, double y) {
        return x * x + y * y;
    }
    int cpp_bool_logic(int cond1, int cond2) {
        return (cond1 && !cond2) ? 1 : 0;
    }
}
