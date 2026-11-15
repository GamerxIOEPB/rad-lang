class Accumulator {
public:
    Accumulator(int init) : value_(init), count_(0) {}
    ~Accumulator() {
        value_ = -999;
    }

    void add(int delta) {
        value_ += delta;
        count_++;
    }

    int value() const {
        return value_;
    }

    int count() const {
        return count_;
    }

private:
    int value_;
    int count_;
};

extern "C" {
    Accumulator* cpp_accum_create(int init) {
        return new Accumulator(init);
    }

    void cpp_accum_add(Accumulator* acc, int delta) {
        if (acc) acc->add(delta);
    }

    int cpp_accum_value(const Accumulator* acc) {
        return acc ? acc->value() : 0;
    }

    int cpp_accum_count(const Accumulator* acc) {
        return acc ? acc->count() : 0;
    }

    void cpp_accum_destroy(Accumulator* acc) {
        delete acc;
    }
}
