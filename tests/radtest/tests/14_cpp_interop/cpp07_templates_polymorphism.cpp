template<typename T>
class MathOps {
public:
    static T clamp(T val, T low, T high) {
        if (val < low) return low;
        if (val > high) return high;
        return val;
    }
};

class Shape {
public:
    virtual ~Shape() {}
    virtual int area() const = 0;
    virtual int perimeter() const = 0;
};

class Rectangle : public Shape {
public:
    Rectangle(int w, int h) : w_(w), h_(h) {}
    int area() const override { return w_ * h_; }
    int perimeter() const override { return 2 * (w_ + h_); }
private:
    int w_, h_;
};

class Square : public Shape {
public:
    Square(int s) : s_(s) {}
    int area() const override { return s_ * s_; }
    int perimeter() const override { return 4 * s_; }
private:
    int s_;
};

extern "C" {
    int cpp_template_clamp(int val, int low, int high) {
        return MathOps<int>::clamp(val, low, high);
    }

    Shape* cpp_create_rect(int w, int h) {
        return new Rectangle(w, h);
    }

    Shape* cpp_create_square(int s) {
        return new Square(s);
    }

    int cpp_shape_area(const Shape* s) {
        return s ? s->area() : 0;
    }

    int cpp_shape_perimeter(const Shape* s) {
        return s ? s->perimeter() : 0;
    }

    void cpp_shape_destroy(Shape* s) {
        delete s;
    }
}
