---
name: rad
description: Comprehensive development, authoring, and debugging guide for the Rad systems programming language and its self-contained toolchain.
---

# Rad Programming Language — AI Coding Skill

The **Rad programming language** is a modern, statically typed systems programming language designed for writing high-performance, predictable, and robust native software. Rad combines the mechanical sympathy and zero-overhead performance of C with the safety, clarity, and ergonomics of modern languages—without requiring a tracing garbage collector or complex lifetime borrow checkers.

This skill provides AI coding agents and human developers with complete, verified specifications, syntax rules, code patterns, and debugging workflows for the self-hosted Rad compiler (`radc`), the package manager (`rad`), and the bundled static PIE toolchain.

---

## 1. Toolchain Architecture

Rad is fully self-contained. Binaries produced by the toolchain are **static Position-Independent Executables (`static-pie`)** with zero external shared library dependencies (`no PT_INTERP`, `no DT_NEEDED`), linking directly with a bundled Musl libc sysroot.

### Primary Binaries:
1. **`rad`**: Native Package Manager & Project Orchestrator
   - Location: `~/.rad/bin/rad`
   - Commands: `rad new <name> [--lib]`, `rad init`, `rad build [--release]`, `rad run [--release]`, `rad check`, `rad clean`, `rad doctor`.
   - Manifest: `rad.toml` in the project root.
2. **`radc`**: Self-Hosted Compiler
   - Location: `~/.rad/bin/radc`
   - Architecture: Pratt recursive descent parser generating direct SSA LLVM IR.
   - CLI Flags: `-o <path>`, `-O0`, `-O2`, `-O3`, `--emit-llvm`, `--check`, `--target <triple>`, `--linker <cmd>`, `-V`/`--version`.
3. **Bundled Static PIE Backend (`rad-llc` & `rad-lld`)**:
   - Location: `~/.rad/bin/rad-llc`, `~/.rad/bin/rad-lld`
   - Target Sysroot: `~/.rad/lib/targets/x86_64-unknown-linux-musl/` (`rcrt1.o`, `crti.o`, `libc.a`, `libclang_rt.builtins-x86_64.a`, `crtn.o`).
4. **Bundled C & C++ Compilers (`rad-clang` & `rad-clang++`)**:
   - Location: `~/.rad/bin/rad-clang`, `~/.rad/bin/rad-clang++`
   - Clang headers: `~/.rad/lib/clang/23/include/`
   - Real binaries & runtime: `~/.rad/lib/llvm/`

---

## 2. Core Language Syntax & Rules

### 2.1 Program Structure & Entry Point
Every Rad program begins execution in `fn main()`:

```rad
// Option 1: Standard entry returning process exit code
fn main() -> i32 {
    println("Hello, World from Rad!")
    return 0
}

// Option 2: Void entry (defaults to exit code 0)
fn main() {
    println("Exits with code 0 automatically")
}

// Option 3: Command-line arguments entry
fn main(argc: i32, argv: *raw *raw u8) -> i32 {
    println("Program: {}", argv[0usize] as str)
    println("Arg count: {}", argc)
    return 0
}
```

> [!IMPORTANT]
> Semicolons at the end of statements are optional, but explicit `return` statements are **mandatory** when returning a value from a function. Rust-style trailing expressions without `return` evaluate to default zero/unit values.

---

### 2.2 Variables & Mutability
- **`let`**: Declares an immutable variable (cannot be reassigned).
- **`var`**: Declares a mutable variable.

```rad
let max_limit: i64 = 1000
var counter: i64 = 0

counter = counter + 1
counter = counter * 2
// max_limit = 2000  <-- Compiler Error: assignment to immutable variable
```

Type annotations are optional when the type can be inferred from the right-hand initializer:
```rad
let msg = "Hello from Rad" // inferred as str
let active = true          // inferred as bool
var count = 0i64           // inferred as i64 from suffix
```

---

### 2.3 Primitive Data Types & Literals

| Type | Bits | Description | Example Literal |
| :--- | :--- | :--- | :--- |
| `i8`, `i16`, `i32`, `i64` | 8, 16, 32, 64 | Signed integers (default integer is `i32`) | `42`, `100i64`, `-5i8` |
| `isize` | 64 | Architecture pointer-width signed integer | `10isize` |
| `u8`, `u16`, `u32`, `u64` | 8, 16, 32, 64 | Unsigned integers | `255u8`, `1000u64` |
| `usize` | 64 | Architecture pointer-width unsigned integer | `0usize`, `512usize` |
| `f32`, `f64` | 32, 64 | IEEE 754 floating-point numbers | `3.1415` |
| `bool` | 8 | Boolean truth values | `true`, `false` |
| `str` | 64 | Null-terminated byte slice pointer | `"Hello, Rad!\n"` |
| `*raw T` | 64 | Immutable raw pointer to `T` | `ptr as *raw u8` |
| `*raw var T`| 64 | Mutable raw pointer to `T` | `buffer as *raw var u8` |

---

### 2.4 Operators & Precedence

1. **Arithmetic**: `+`, `-`, `*`, `/`, `%`, `-` (unary negation)
2. **Comparison**: `==`, `!=`, `<`, `<=`, `>`, `>=`
3. **Logical**: `&&` (short-circuiting AND), `||` (short-circuiting OR), `!` (NOT)
4. **Member & Method**: `.` (`obj.field`, `obj.method()`)
5. **Array / Pointer Index**: `[]` (`ptr[i]`, `ptr[i] = val`)
6. **Explicit Cast**: `as` (`val as i32`, `ptr as usize`, `addr as *raw u8`)

---

### 2.5 Control Flow

#### Conditionals (`if`, `else if`, `else`)
Braces `{ ... }` around blocks are mandatory:

```rad
if score >= 90 {
    println("Grade: A")
} else if score >= 80 {
    println("Grade: B")
} else {
    println("Grade: C or below")
}
```

#### While Loops (`while`)
Rad uses `while` loops for bounded and unbounded repetition:

```rad
var i: i64 = 0
while i < 10 {
    i = i + 1
    if i == 5 {
        continue // Skip 5
    }
    if i > 8 {
        break // Stop at 8
    }
    println("i = {i}")
}
```

#### For Loops (`for .. in`)
Rad provides high-level `for` loops for ranges and collections:

```rad
// Range loop (0 inclusive up to 10 exclusive)
for i in 0..10 {
    println(i)
}

// Collection loop over slices or vectors
let items = [10, 20, 30, 40]
for x in items {
    println(x)
}
```

---

### 2.6 Array Literals, Slices & Memory Safety

#### Array Literals & Slices (`[]T`)
Array literals allocate memory and lower to 24-byte fat slices `{ ptr, cap, len }`:

```rad
var numbers = [64, 34, 25, 12, 22, 11, 90]
let count = numbers.len

// In-place bubble sort with type-safe swap intrinsic
for i in 0..count {
    for j in 0..(count - i - 1usize) {
        if numbers[j] > numbers[j + 1usize] {
            swap(numbers[j], numbers[j + 1usize])
        }
    }
}
```

#### Runtime Safety Traps
- **Bounds Checking**: Accessing `arr[i]` when `i >= arr.len` triggers `@__rad_panic_bounds` with clear panic message and status 1:
  `rad runtime panic: index out of bounds: index 5 >= len 3`
- **Zero Division Protection**: Division or modulo by zero traps via `@__rad_panic_div_zero`:
  `rad runtime panic: attempt to divide by zero`
- **Zero-Overhead Raw Pointers**: Hardware pointers (`*raw T`, `*raw var T`) bypass bounds checks for bare-metal performance.

#### Statement Separation Rules
- Newlines and semicolons are valid statement separators.
- Same-line statements **must** be separated by semicolons:
  ```rad
  println("Hello"); println("World") // Valid
  // println("Hello") println("World") // Syntax error: E0001
  ```

---

### 2.6 Structs & Methods

#### Defining & Instantiating Structs
```rad
struct Point {
    x: i64,
    y: i64,
}

fn main() -> i32 {
    // Instantiation
    var pt = Point { x: 3, y: 4 }
    
    // Field access & mutation
    println("Initial: x={}, y={}", pt.x, pt.y)
    pt.x = 30
    pt.y = 40
    println("Updated: x={}, y={}", pt.x, pt.y)
    return 0
}
```

#### Defining Methods (`self` Receiver)
Functions taking an explicit `self: *raw StructName` parameter can be called using dot notation `instance.method()`:

```rad
struct Vector2 {
    x: i64,
    y: i64,
}

// Method calculating length squared
fn length_sq(self: *raw Vector2) -> i64 {
    return self.x * self.x + self.y * self.y
}

// Mutating method
fn scale(self: *raw var Vector2, factor: i64) {
    self.x = self.x * factor
    self.y = self.y * factor
}

fn main() -> i32 {
    var v = Vector2 { x: 3, y: 4 }
    let lsq = v.length_sq() // Invoked via dot syntax
    println("Length squared: {lsq}")

    v.scale(2)
    println("Scaled: x={}, y={}", v.x, v.y)
    return 0
}
```

> [!CAUTION]
> Do not name user functions `@new` or `new()`. In `radc`, `new()` is an internal runtime function used for allocating built-in dynamic collections. Use descriptive constructor names such as `Point_new()`, `make_point()`, or `init()`.

---

### 2.7 Built-In Dynamic Collections

Rad's compiler includes built-in SSA code generation for dynamic strings (`String`) and dynamic arrays (`Vec`):

#### `String`
```rad
var s = String.new()             // Allocate empty dynamic string
var s2 = String.from_str("Rad")  // Initialize from string literal
s2.push_str(" Language")         // Append string slice
s2.push_byte(33u8)               // Append '!'
let length = s2.len()            // Current byte length
let raw_cstr = s2.as_ptr()       // Raw *raw u8 pointer
println("Content: {}, len: {}", raw_cstr, length)
```

#### `Vec`
```rad
var numbers = Vec.new()          // Allocate new dynamic vector
numbers.push(10)                 // Append element
numbers.push(20)
let count = numbers.len          // Current element count
let p: *raw i64 = numbers.ptr as *raw i64 // Base array pointer
let first = p[0usize]            // Indexing element
let popped = numbers.pop()       // Remove last element
```

---

### 2.8 Formatting & Printing

#### `println()` Formatting
Rad supports two formatting modes in `println()`:

1. **Positional Placeholders (`{}`)**:
   ```rad
   println("Coordinates: ({}, {})", x, y)
   ```
2. **Variable Interpolation (`{var_name}`)**:
   When passed a single format string, variables are expanded automatically:
   ```rad
   let user = "admin"
   let port = 8080
   println("Server running for {user} on port {port}")
   ```

#### Direct Libc Printing
Standard C printing functions are pre-declared:
```rad
puts("Direct C puts string")
printf("Formatted hex: 0x%08X, float: %.2f\n", 255, 3.1415)
```

---

### 2.9 Seamless C & C++ Interoperability

#### Direct Libc Functions
Standard C functions are declared internally in LLVM IR by `radc`:
- Memory: `malloc(size: usize) -> *raw var u8`, `realloc(...)`, `free(ptr: *raw u8)`
- I/O: `puts(s: str) -> i32`, `printf(fmt: str, ...) -> i32`, `fopen`, `fclose`, `fread`, `fwrite`, `fseek`, `ftell`
- OS: `system(cmd: str) -> i32`, `getenv(name: str) -> str`

#### Linking Custom C / C++ Code
1. Compile C/C++ source code to object files using bundled `rad-clang` / `rad-clang++`:
   ```bash
   rad-clang -c crypto.c -o crypto.o
   rad-clang++ -c engine.cpp -o engine.o
   ```
2. Compile and link in one step with `radc`:
   ```bash
   radc main.rad crypto.o engine.o -o my_app
   ```

---

## 3. Package Manager (`rad`) Reference

| Command | Description |
| :--- | :--- |
| `rad new <name>` | Create a new application package (`src/main.rad` and `rad.toml`) |
| `rad new <name> --lib` | Create a new library package (`src/lib.rad` and `rad.toml`) |
| `rad init` | Initialize a Rad package in the current directory |
| `rad check` | Fast syntax and type checking without compiling |
| `rad build` | Compile the project in debug mode (`target/debug/main`) |
| `rad build --release` | Compile with aggressive LLVM `-O3` optimizations (`target/release/main`) |
| `rad run [args]` | Build and execute the binary in one step |
| `rad clean` | Remove the `target/` build directory |
| `rad doctor` | Diagnostic check verifying `radc`, `rad-llc`, `rad-lld`, and target sysroot |

---

## 4. Common Diagnostics & Troubleshooting

| Error Message | Cause | Solution |
| :--- | :--- | :--- |
| `error[E0001]: expected '{', found ...` | Missing braces on function/if/while block, or bodyless prototype | Ensure every function has an implementation block `{ ... }`. Bodyless prototypes are not supported. |
| `error[E0002]: unresolved identifier '...'` | Variable or function name not found in scope | Check spelling, ensure variable is declared with `let` or `var` prior to use. |
| `llc: error: invalid redefinition of function 'new'` | Defining a custom function named `new` | Rename function to `make_<struct>()` or `<struct>_new()`. `@new` is reserved for string/vector allocators. |
| `llc: error: use of undefined value '@func'` | Calling an undeclared C function | Ensure C object file is passed on the `radc` command line. |
| `execv: No such file or directory` on `rad-clang` | Missing host compiler tool in `~/.rad/lib/llvm/` | Run `rad doctor` to verify bundled LLVM tools. |

---

## 5. Comprehensive Chapter Index

For complete in-depth tutorials and reference guides, consult the markdown chapters located in [`website/docs/`](file:///home/abhinav/Projects/rad/website/docs) or view them interactively in [`website/docs.html`](file:///home/abhinav/Projects/rad/website/docs.html):

1. [Chapter 1: What is Rad?](references/01_what_is_rad.md)
2. [Chapter 2: Installation & Toolchain Setup](references/02_installation.md)
3. [Chapter 3: Getting Started (Hello World)](references/03_getting_started.md)
4. [Chapter 4: Variables & Data Types](references/04_variables_and_types.md)
5. [Chapter 5: Operators & Expressions](references/05_operators_and_expressions.md)
6. [Chapter 6: Control Flow](references/06_control_flow.md)
7. [Chapter 7: Functions & Main Entry](references/07_functions.md)
8. [Chapter 8: Structs & Methods](references/08_structs_and_methods.md)
9. [Chapter 9: Pointers, Memory & Casting](references/09_pointers_and_memory.md)
10. [Chapter 10: Strings, Collections & I/O](references/10_strings_and_collections.md)
11. [Chapter 11: C & C++ Interoperability](references/11_c_interop.md)
12. [Chapter 12: Compiler (radc) & Linking Deep-Dive](references/12_compiler_cli.md)
13. [Chapter 13: Package Manager (rad) CLI](references/13_package_manager.md)
14. [Chapter 14: Standard Library Reference](references/14_standard_library.md)
15. [Chapter 15: Tooling & Editor Support](references/15_editor_support.md)
