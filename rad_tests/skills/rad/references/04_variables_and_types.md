# Chapter 4: Variables, Mutability & Types

## 4.1 Variables & Mutability

In Rad, variables are declared using either `let` or `var`.

### Immutable Variables (`let`)
By default, variables introduced with `let` are immutable. Once initialized, their value cannot be changed:

```rad
fn main() -> i32 {
    let x: i64 = 42
    // x = 50  <-- Error: assignment to immutable variable
    println("x is: {x}")
    return 0
}
```

### Mutable Variables (`var`)
When a variable needs to be reassigned or mutated, declare it using `var`:

```rad
fn main() -> i32 {
    var count: i64 = 0
    count = count + 1
    count = count * 2
    println("count is: {count}")
    return 0
}
```

### Type Inference
Rad infers the type of a variable from its initializer expression when omitted:

```rad
let message = "Hello from Rad" // inferred as str
let active = true             // inferred as bool
var counter = 100i64          // inferred as i64 from suffix
```

However, explicit type annotations (`name: Type`) are recommended for public functions and clear code documentation.

---

## 4.2 Primitive Data Types

Rad provides an explicit, machine-level set of scalar data types.

### 1. Integer Types
Rad provides signed and unsigned integers across standard bit widths:

| Type | Signed | Bit Width | Description / Range | Literal Example |
| :--- | :--- | :--- | :--- | :--- |
| `i8` | Yes | 8 | -128 to 127 | `10i8` |
| `i16` | Yes | 16 | -32,768 to 32,767 | `1000i16` |
| `i32` | Yes | 32 | -2,147,483,648 to 2,147,483,647 (default int) | `42`, `42i32` |
| `i64` | Yes | 64 | -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807 | `100i64` |
| `isize` | Yes | Pointer width | Target architecture signed pointer size (64-bit on x86_64) | `5isize` |
| `u8` | No | 8 | 0 to 255 (byte) | `255u8` |
| `u16` | No | 16 | 0 to 65,535 | `60000u16` |
| `u32` | No | 32 | 0 to 4,294,967,295 | `100000u32` |
| `u64` | No | 64 | 0 to 18,446,744,073,709,551,615 | `1000000u64` |
| `usize` | No | Pointer width | Target architecture unsigned pointer size (64-bit on x86_64) | `0usize` |

### 2. Floating-Point Types
- `f32`: Single-precision 32-bit IEEE 754 floating point.
- `f64`: Double-precision 64-bit IEEE 754 floating point.

### 3. Boolean Type (`bool`)
The `bool` type represents logical truth values:
- `true`
- `false`

```rad
let is_running: bool = true
let is_finished: bool = false
```

### 4. String Literals (`str`)
The `str` type represents a null-terminated pointer to an immutable sequence of UTF-8 bytes:

```rad
let greeting: str = "Welcome to Rad Systems"
```

String literals support standard escape sequences:
- `\n`: Newline
- `\t`: Tab
- `\r`: Carriage return
- `\"`: Double quote
- `\\`: Backslash
- `\0`: Null terminator byte

---

## 4.3 Raw Pointer Types

For low-level systems programming, operating system interactions, and C ABI interop, Rad provides raw pointers:

- `*raw T`: Immutable raw pointer to type `T`.
- `*raw var T`: Mutable raw pointer to type `T`.
- `*raw *raw u8`: Multi-level raw pointer (such as `argv: *raw *raw u8`).

```rad
// Pointer declaration and casting
let ptr: *raw u8 = greeting as *raw u8
let first_byte: u8 = ptr[0usize]
```

---

## 4.4 Constants (`const`)

Constants are compile-time immutable values evaluated before code generation. They are declared at file scope with the `const` keyword:

```rad
const MAX_BUFFER_SIZE: i64 = 4096
const DEFAULT_TIMEOUT_MS: i64 = 5000
const PROTOCOL_VERSION: i32 = 1

fn main() -> i32 {
    println("Max buffer: {}", MAX_BUFFER_SIZE)
    return 0
}
```

---

## 4.5 Comments

Rad supports both single-line and multi-line block comments:

```rad
// This is a single-line comment

/*
 * This is a multi-line
 * block comment.
 */

fn main() -> i32 {
    let a = 10 // Inline comment
    return 0
}
```
