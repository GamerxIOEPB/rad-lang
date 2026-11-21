# rad-math

2D/3D vectors, 3x3 matrices, and geometry math for Rad applications and games.

## Features

- **Vec2**: 2D vector operations (dot, length, normalize, scale, distance, lerp, perp, rotate).
- **Vec3**: 3D vector operations (dot, cross product, length, normalize, scale).
- **Mat3**: 3x3 transform matrices (identity, translation, rotation, scaling, matrix-vector multiplication).
- **Rect**: 2D axis-aligned bounding box and collision detection.
- **Math Utilities**: angle conversions, clamp, lerp, and trigonometric operations.

## Example Usage

```rad
import "rad-math";

fn main() -> i32 {
    let p1 = Vec2.new(10.0, 20.0);
    let p2 = Vec2.new(30.0, 40.0);
    let d = p1.dist2(p2);

    let v1 = Vec3.new(1.0, 0.0, 0.0);
    let v2 = Vec3.new(0.0, 1.0, 0.0);
    let up = v1.cross3(v2);

    return 0;
}
```
