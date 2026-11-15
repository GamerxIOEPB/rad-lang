# Rad Type System Specification

Rad features a static, sound, and nominal type system designed for systems programming.

## 1. Primitive Scalar Types

| Type | Bit Width | Range / Values | Default Literal |
|---|---|---|---|
| `i8` | 8 | -128 .. 127 | `0i8` |
| `i16` | 16 | -32,768 .. 32,767 | `0i16` |
| `i32` | 32 | -2,147,483,648 .. 2,147,483,647 | `0` (default integer) |
| `i64` | 64 | -9,223,372,036,854,775,808 .. 9,223,372,036,854,775,807 | `0i64` |
| `u8` | 8 | 0 .. 255 | `0u8` |
| `u16` | 16 | 0 .. 65,535 | `0u16` |
| `u32` | 32 | 0 .. 4,294,967,295 | `0u32` |
| `u64` | 64 | 0 .. 18,446,744,073,709,551,615 | `0u64` |
| `usize` | 64 (x86-64) | 0 .. 2^64 - 1 | `0usize` |
| `isize` | 64 (x86-64) | -2^63 .. 2^63 - 1 | `0isize` |
| `f32` | 32 | IEEE 754 single precision | `0.0f32` |
| `f64` | 64 | IEEE 754 double precision | `0.0` (default float) |
| `bool` | 1 / 8 | `true`, `false` | `false` |
| `char` | 32 | Unicode scalar value | `'a'` |
| `str` | 64 (ptr) | Immutable null-terminated UTF-8 slice | `"text"` |

## 2. Pointers

- `*raw T`: Immutable raw pointer to `T`.
- `*raw var T`: Mutable raw pointer to `T`.
- Raw pointers can be cast using `expr as *raw T` or `expr as usize`.

## 3. Composite Types

### Structs
Nominally typed record types with typed fields:
```rad
struct Config {
    port: i32,
    enabled: bool,
    host: String,
}
```

### Enums
Algebraic Data Types (sum types):
```rad
enum Status {
    Idle,
    Running(i32),
    Failed(String),
}
```

## 4. Collections

- `Vec<T>`: Contiguous, dynamically resizable heap array.
  - Layout: `{ ptr: *raw T, cap: usize, len: usize }`.
- `String`: Dynamically resizable UTF-8 text buffer backed by `Vec<u8>`.
  - Methods: `push_str()`, `push_byte()`, `as_ptr()`, `len()`.
