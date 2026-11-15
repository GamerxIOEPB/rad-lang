#include <cmath>
#include <stdint.h>

struct Vec3D {
    double x;
    double y;
    double z;
};

struct MeshBounds {
    Vec3D min_pt;
    Vec3D max_pt;
};

extern "C" {
    void cpp_vec3_cross(const Vec3D* a, const Vec3D* b, Vec3D* out) {
        if (!a || !b || !out) return;
        out->x = a->y * b->z - a->z * b->y;
        out->y = a->z * b->x - a->x * b->z;
        out->z = a->x * b->y - a->y * b->x;
    }

    double cpp_vec3_dot(const Vec3D* a, const Vec3D* b) {
        if (!a || !b) return 0.0;
        return a->x * b->x + a->y * b->y + a->z * b->z;
    }

    void cpp_compute_triangle_bounds(const Vec3D* p0, const Vec3D* p1, const Vec3D* p2, MeshBounds* out_bounds) {
        if (!p0 || !p1 || !p2 || !out_bounds) return;
        const Vec3D* pts[3] = {p0, p1, p2};
        out_bounds->min_pt = *p0;
        out_bounds->max_pt = *p0;

        for (int i = 1; i < 3; ++i) {
            if (pts[i]->x < out_bounds->min_pt.x) out_bounds->min_pt.x = pts[i]->x;
            if (pts[i]->y < out_bounds->min_pt.y) out_bounds->min_pt.y = pts[i]->y;
            if (pts[i]->z < out_bounds->min_pt.z) out_bounds->min_pt.z = pts[i]->z;

            if (pts[i]->x > out_bounds->max_pt.x) out_bounds->max_pt.x = pts[i]->x;
            if (pts[i]->y > out_bounds->max_pt.y) out_bounds->max_pt.y = pts[i]->y;
            if (pts[i]->z > out_bounds->max_pt.z) out_bounds->max_pt.z = pts[i]->z;
        }
    }
}
