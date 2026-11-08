# Chapter 10: Strings, Collections & Formatting

## 10.1 The Built-In `String` Type

Rad provides a heap-allocated, dynamically resizable `String` type built directly into the compiler's standard library and code generator.

### Creating Strings
- **`String::new()`**: Creates a new empty dynamic string with initial preallocated heap capacity.
- **`String::from_str(s: str)`**: Creates a dynamic string initialized with a copy of an existing string literal or slice.

```rad
fn main() -> i32 {
    var s1 = String::new()
    var s2 = String::from_str("Hello, Rad!")

    println(s2.as_ptr())
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
    var greeting = String::from_str("Welcome")
    greeting.push_str(" to the Rad Language")
    greeting.push_byte(33u8) // '!'

    print("Text: ")
    println(greeting.as_ptr())
    print("Byte count: ")
    println(greeting.len())
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

Rad provides a dynamically resizable heap vector (`Vec<T>`) for sequential collections:

### Creating Vectors
- **`Vec::new()`**: Allocates a new vector with initial default capacity.

### Vector Operations
- **`v.push(item: T)`**: Appends an element to the end of the vector, doubling capacity when full.
- **`v.pop() -> T`**: Removes and returns the last element from the vector.
- **`v.get(index: usize) -> T`**: Retrieves the element at the specified index.
- **`v.len`**: Struct field containing the current number of elements in the vector.
- **`v.cap`**: Struct field containing the allocated capacity.
- **`v.ptr`**: Raw pointer to the element array (`*raw T`).

```rad
fn main() -> i32 {
    var numbers: Vec<i32> = Vec::new()

    // Append items
    numbers.push(10)
    numbers.push(20)
    numbers.push(30)

    print("Vector length: ")
    println(numbers.len)

    // Access elements via get():
    print("numbers[0]: ")
    println(numbers.get(0usize))
    print("numbers[1]: ")
    println(numbers.get(1usize))

    // Pop the last element:
    let last = numbers.pop()
    print("Popped item: ")
    println(last)
    print("Remaining count: ")
    println(numbers.len)

    return 0
}
```

Output:
```text
Vector length: 3
numbers[0]: 10
numbers[1]: 20
Popped item: 30
Remaining count: 2
```

---

## 10.3 Standard Output Printing (`print`, `println`)

Rad provides built-in `print()` and `println()` functions that accept strings, integers, and primitive values:

```rad
fn main() -> i32 {
    let title: str = "Player Status"
    let score: i64 = 4500
    let alive: bool = true

    println(title)
    print("Score: ")
    println(score)

    if alive {
        println("Status: ALIVE")
    }
    return 0
}
```

Output:
```text
Player Status
Score: 4500
Status: ALIVE
```

---

## 10.4 Standard C Formatting (`printf`)

For complex C-style format specifiers (`%08x`, `%.2f`, `%p`), you can call the standard libc `printf` function directly:

```rad
extern "C" {
    fn printf(fmt: str, ...) -> i32;
}

fn main() -> i32 {
    let hex_val: i64 = 255
    printf("Hexadecimal: 0x%04X\n", hex_val)
    return 0
}
```
