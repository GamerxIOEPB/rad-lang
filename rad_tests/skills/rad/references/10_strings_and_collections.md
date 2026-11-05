# Chapter 10: Strings, Collections & Formatting

## 10.1 The Built-In `String` Type

Rad provides a heap-allocated, dynamically resizable `String` type built directly into the compiler's code generator.

### Creating Strings
- **`String.new()`**: Creates a new empty dynamic string with initial preallocated heap capacity.
- **`String.from_str(s: str)`**: Creates a dynamic string initialized with a copy of an existing string literal or slice.

```rad
fn main() -> i32 {
    var s1 = String.new()
    var s2 = String.from_str("Hello, Rad!")

    println("s2 = {}", s2.as_ptr())
    return 0
}
```

### Mutating Strings
- **`s.push_str(src: str)`**: Appends a null-terminated string slice to the end of `s`. Automatically reallocates buffer capacity if needed.
- **`s.push_byte(byte: u8)`**: Appends a single byte (character) to `s`.
- **`s.len()`**: Returns the current byte length of the string (excluding the null terminator).
- **`s.as_ptr()`**: Returns a null-terminated raw byte pointer (`*raw u8` / `str`) to the internal buffer, suitable for printing or passing to C APIs.

```rad
fn main() -> i32 {
    var greeting = String.from_str("Welcome")
    greeting.push_str(" to the Rad Language")
    greeting.push_byte(33u8) // '!'

    println("Text: {}", greeting.as_ptr())
    println("Byte count: {}", greeting.len())
    return 0
}
```

Output:
```text
Text: Welcome to the Rad Language!
Byte count: 28
```

---

## 10.2 The Built-In `Vec` Type

Rad provides a dynamically resizable heap vector (`Vec`) for sequential collections:

### Creating Vectors
- **`Vec.new()`**: Allocates a new vector with initial capacity.

### Vector Operations
- **`v.push(item: i64)`**: Appends an element to the end of the vector, doubling capacity when full.
- **`v.pop() -> i64`**: Removes and returns the last element from the vector (returns `0` if empty).
- **`v.len`**: Struct field containing the current number of elements in the vector.
- **`v.cap`**: Struct field containing the allocated capacity.
- **`v.ptr`**: Raw pointer to the element array (`*raw i64` or `*raw u8`).

```rad
fn main() -> i32 {
    var numbers = Vec.new()

    // Append items
    numbers.push(10)
    numbers.push(20)
    numbers.push(30)

    println("Vector length: {}", numbers.len)

    // Access elements via raw pointer:
    let p: *raw i64 = numbers.ptr as *raw i64
    println("numbers[0] = {}, numbers[1] = {}", p[0usize], p[1usize])

    // Pop the last element:
    let last = numbers.pop()
    println("Popped item: {}, remaining count: {}", last, numbers.len)

    return 0
}
```

Output:
```text
Vector length: 3
numbers[0] = 10, numbers[1] = 20
Popped item: 30, remaining count: 2
```

---

## 10.3 Formatted Printing with `println()`

Rad's `println()` function provides two complementary formatting modes:

### 1. Positional `{}` Placeholders
Pass a format template string followed by the arguments to print:

```rad
let name: str = "Alice"
let age: i32 = 30
let city: str = "Zurich"

println("Name: {}, Age: {}, City: {}", name, age, city)
```

### 2. Variable Interpolation (`{var_name}`)
When passing a single template string, Rad automatically expands `{variable}` patterns:

```rad
let width: i64 = 1920
let height: i64 = 1080

println("Resolution: {width} x {height}")
```

Output:
```text
Resolution: 1920 x 1080
```

---

## 10.4 Standard C Formatting (`printf`)

For complex C-style format specifiers (`%08x`, `%.2f`, `%p`), you can call the standard libc `printf` function directly:

```rad
fn main() -> i32 {
    let hex_val: i64 = 255
    printf("Hexadecimal: 0x%04X\n", hex_val)
    return 0
}
```
