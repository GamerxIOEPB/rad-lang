# Rad Structs & Custom Types Specification

Rad provides nominal product types (`struct`) and nominal sum types (`enum`).

## 1. Struct Declarations

```rad
struct Vec3 {
    x: f64,
    y: f64,
    z: f64,
}
```

Instantiation requires initializing all declared fields:

```rad
let v = Vec3 {
    x: 1.0,
    y: 2.0,
    z: 3.0,
};
```

Field access uses dot syntax:
```rad
let vx = v.x;
```

## 2. In-Memory Memory Layout

In the self-hosted Rad compiler (`radc`):
- All struct fields align on 64-bit (8-byte) boundaries.
- Struct pointer fields contain pointers to heap-allocated data or inline 64-bit values.
- Interoperable C structs can use `#[repr(C)]` for standard C ABI alignment.

## 3. Enums (Tagged Unions)

Enums represent values that can take one of multiple variant shapes:

```rad
enum ConnectionState {
    Disconnected,
    Connecting(u32),
    Connected(String),
}
```

Variants with payloads store a discriminator tag alongside variant data.
Exhaustiveness checking verifies all variants in `match` statements.
