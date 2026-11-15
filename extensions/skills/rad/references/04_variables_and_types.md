# Chapter 4: Variables, Mutability & Types

## 4.1 Variables & Mutability

In Rad, variables are declared using either `let` or `var`.

### Immutable Variables (`let`)
By default, variables introduced with `let` are immutable. Once initialized, their value cannot be changed:

```rad
fn main() -> i32 {
    let x: i64 = 42
    // x = 50  <-- Compile error: assignment to immutable variable 'x'
    print("x is: ")
    println(x)
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
    print("count is: ")
    println(count)
    return 0
}
```

### Type Inference
Rad infers the type of a variable from its initializer expression when the type annotation is omitted:

```rad
let message = "Hello from Rad" // inferred as str
let active = true             // inferred as bool
var counter = 100i64          // inferred as i64 from suffix
let ratio = 3.14159           // inferred as f64
```

Explicit type annotations (`name: Type`) are encouraged for public module APIs and critical interfaces.

---

## 4.2 Primitive Data Types

Rad provides an explicit, machine-level set of scalar data types.

### 1. Integer Types
Rad provides signed and unsigned integers across standard bit widths:

| Type | Signed | Bit Width | Description / Range | Literal Example |
| :--- | :--- | :--- | :--- | :--- |
| `i8` | Yes | 8 | -128 to 127 | `10i8`, `-5i8` |
| `i16` | Yes | 16 | -32,768 to 32,767 | `1000i16` |
| `i32` | Yes | 32 | -2,147,483,648 to 2,147,483,647 (default integer) | `42`, `42i32` |
| `i64` | Yes | 64 | -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807 | `100i64` |
| `isize` | Yes | Pointer width | Signed pointer width (64-bit on x86_64) | `5isize` |
| `u8` | No | 8 | 0 to 255 (standard byte) | `255u8`, `0u8` |
| `u16` | No | 16 | 0 to 65,535 | `60000u16` |
| `u32` | No | 32 | 0 to 4,294,967,295 | `100000u32` |
| `u64` | No | 64 | 0 to 18,446,744,073,709,551,615 | `1000000u64` |
| `usize` | No | Pointer width | Unsigned pointer width (64-bit on x86_64) | `0usize`, `1024usize` |

### 2. Floating-Point Types
- `f32`: Single-precision 32-bit IEEE 754 floating point.
- `f64`: Double-precision 64-bit IEEE 754 floating point.

```rad
let pi: f64 = 3.141592653589793
let gravity: f32 = 9.81f32
```

### 3. Boolean Type (`bool`)
The `bool` type represents logical truth values:
- `true`
- `false`

```rad
let is_running: bool = true
let is_finished: bool = false

if is_running && !is_finished {
    println("Engine active")
}
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
- `\x1b`: ANSI escape byte (hex)

---

## 4.3 Explicit Type Casting (`as`)

Rad strictly prevents implicit lossy conversions. All conversions between integer sizes, signs, floats, and raw pointers must be explicitly declared using the `as` operator:

```rad
fn main() -> i32 {
    let a: i32 = 1000
    let b: i64 = a as i64        // Widening cast
    let c: u8  = (a as u8)       // Truncating cast
    let d: usize = 4096usize
    let ptr: *raw u8 = d as *raw u8 // Pointer cast

    print("b: ")
    println(b)
    print("c: ")
    println(c as i32)
    return 0
}
```

---

## 4.4 Raw Pointer Types

For low-level hardware interactions, system calls, and C ABI interop, Rad provides raw pointers:

- `*raw T`: Raw pointer to type `T`.
- `*raw *raw u8`: Multi-level raw pointer (such as `argv: *raw *raw u8`).

```rad
// Pointer declaration, array indexing and casting
let message: str = "Systems"
let ptr: *raw u8 = message as *raw u8
let first_byte: u8 = ptr[0usize] // 83 ('S')

print("First byte ASCII: ")
println(first_byte as i32)
```

---

## 4.5 Constants (`const`)

Constants are compile-time immutable values evaluated before code generation. They are declared at file scope with the `const` keyword:

```rad
const MAX_BUFFER_SIZE: i64 = 4096
const DEFAULT_TIMEOUT_MS: i64 = 5000
const PROTOCOL_VERSION: i32 = 1

fn main() -> i32 {
    print("Max buffer size: ")
    println(MAX_BUFFER_SIZE)
    return 0
}
```

---

## 4.6 Comments

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
