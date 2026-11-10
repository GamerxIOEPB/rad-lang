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

Rad provides two core standard output printing built-ins:
- **`println(...)`**: Prints formatted output followed by a trailing newline (`\n`).
- **`print(...)`**: Prints formatted output **without** a trailing newline, and automatically flushes `stdout` immediately. This is ideal for terminal prompts and continuous output on a single line.

```rad
fn main() {
    print("Enter your name: ") // Flushes immediately without newline
    let name = input()
    println(f"Hello, {name}!") // Appends newline
}
```

Both `print` and `println` support single values, dynamic `String` instances, formatted strings with positional `{}` placeholders, and Python-style f-strings `f"..."`.

### 1. Printing Dynamic `String` Instances
You can pass heap-allocated `String` instances directly into `print()` and `println()` without needing to manually call `.as_ptr()`:

```rad
fn main() {
    let s = String::from_str("Hello, World!")
    println(s)
}
```

### 2. F-String Interpolation (`f"..."`)
Rad provides Python-style f-strings for concise variable and struct field interpolation directly inside string literals:

```rad
struct Player {
    name: str,
    score: i64,
}

fn main() {
    let p = Player { name: "Abhinav", score: 9500 }
    
    // In-string variable and field interpolation
    println(f"Player {p.name} reached score {p.score}!")
}
```

Output:
```text
Player Abhinav reached score 9500!
```

> [!NOTE]
> Only string literals prefixed with `f` (such as `f"Hello {name}"`) trigger expression interpolation. Plain string literals without `f` preserve `{...}` as literal brace characters.

### 3. Positional Placeholders (`"{}"`)
You can pass positional placeholder arguments matching `{}` tokens in the format string:

```rad
fn main() {
    let x = 10
    let y = 20
    println("Coordinates: ({}, {})", x, y)
}
```

Output:
```text
Coordinates: (10, 20)
```

### 4. Escape Sequences
Rad string literals support standard escape sequences:
- `\n` (newline, ASCII 10)
- `\t` (horizontal tab, ASCII 9)
- `\r` (carriage return, ASCII 13)
- `\0` (null terminator, ASCII 0)
- `\e` (escape character, ASCII 27 / `0x1B` for ANSI terminal styling)
- `\"` (escaped quotation mark)
- `\\` (escaped backslash)
- `\xNN` (hexadecimal byte value, e.g. `\x1B[1;32m` for colored terminal output)

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

---

## 10.5 Standard Input (`input`)

Rad features a built-in native `input()` function that reads a line of input from `stdin` until a newline (`\n`) or EOF is encountered. It returns the input as a dynamic heap-allocated `String` with trailing `\n` and `\r` characters stripped.

### Signatures:
- **`input() -> String`**: Reads from `stdin`.
- **`input(prompt: str) -> String`**: Displays the specified prompt without trailing newline, flushes `stdout`, and waits for user input.

```rad
fn main() {
    // 1. input() without prompt
    print("What is your name? ")
    let name = input()

    // 2. input(prompt) with integrated prompt
    let age_str = input("How old are you? ")

    println(f"Welcome, {name}! You are {age_str} years old.")
    println(f"Name length: {name.len()} characters")
}
```

Example terminal session:
```text
What is your name? Alice
How old are you? 25
Welcome, Alice! You are 25 years old.
Name length: 5 characters
```

The compiler automatically infers the variable type as `String` when initialized with `input()`, and the returned `String` can be passed directly to `print()`, `println()`, or manipulated with `.len()`, `.push_str()`, etc.
