#include <stdint.h>

struct Point3D {
    int64_t x;
    int64_t y;
    int64_t z;
};

extern "C" {
    int64_t cpp_point_magnitude_sq(const Point3D* pt) {
        return pt->x * pt->x + pt->y * pt->y + pt->z * pt->z;
    }

    void cpp_translate_point(Point3D* pt, int64_t dx, int64_t dy, int64_t dz) {
        pt->x += dx;
        pt->y += dy;
        pt->z += dz;
    }
}
