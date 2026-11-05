# Chapter 11: C & C++ Interoperability

## 11.1 The Rad C ABI Philosophy

Rad does not treat C as an afterthought or an awkward foreign interface. Rad is designed with **mechanical sympathy** for the C ABI:

- Primitive integers (`i32`, `i64`, `u8`, `usize`) directly map to C hardware types (`int32_t`, `int64_t`, `uint8_t`, `size_t`).
- Pointers (`*raw u8`, `*raw var T`) use standard 64-bit machine pointer representation.
- Functions adhere strictly to the System V AMD64 ABI calling convention on Linux.
- Executables statically link against Musl libc (`libc.a`).

As a result, calling C functions from Rad—or calling Rad functions from C—incurs **zero runtime conversion overhead, zero boxing, and zero marshaling layers**.

---

## 11.2 Built-In C Standard Library Functions

The Rad compiler's code generator automatically declares and links the most common POSIX / C standard library routines into every generated binary:

| Function | Signature in Rad / LLVM | Purpose |
| :--- | :--- | :--- |
| `puts(s: str) -> i32` | `declare i32 @puts(ptr)` | Prints string followed by newline |
| `printf(fmt: str, ...) -> i32` | `declare i32 @printf(ptr, ...)` | Formatted C printing |
| `system(cmd: str) -> i32` | `declare i32 @system(ptr)` | Executes a shell command via `sh` |
| `malloc(bytes: usize) -> *raw var u8` | `declare ptr @malloc(i64)` | Allocates heap memory |
| `realloc(p: *raw u8, bytes: usize) -> *raw var u8` | `declare ptr @realloc(ptr, i64)` | Resizes allocated heap memory |
| `free(p: *raw u8)` | `declare void @free(ptr)` | Deallocates heap memory |
| `fopen(path: str, mode: str) -> *raw u8` | `declare ptr @fopen(ptr, ptr)` | Opens a file stream |
| `fclose(fp: *raw u8) -> i32` | `declare i32 @fclose(ptr)` | Closes a file stream |
| `fread(buf: *raw var u8, sz: i64, n: i64, fp: *raw u8) -> i64` | `declare i64 @fread(ptr, i64, i64, ptr)` | Reads binary data from stream |
| `fwrite(buf: *raw u8, sz: i64, n: i64, fp: *raw u8) -> i64` | `declare i64 @fwrite(ptr, i64, i64, ptr)` | Writes binary data to stream |
| `fseek(fp: *raw u8, off: i64, whence: i32) -> i32` | `declare i32 @fseek(ptr, i64, i32)` | Seeks stream position |
| `ftell(fp: *raw u8) -> i64` | `declare i64 @ftell(ptr)` | Returns stream offset |
| `getenv(name: str) -> str` | `declare ptr @getenv(ptr)` | Reads environment variable |

### Example: Reading an Environment Variable and Running a Subprocess
```rad
fn main() -> i32 {
    let user = getenv("USER")
    if (user as usize) != 0usize {
        println("Current Linux user: {}", user)
    }

    // Call libc system() directly:
    system("uname -a")
    return 0
}
```

---

## 11.3 Compiling & Linking C Code with Rad

When your project includes custom C algorithms, hardware device drivers, or third-party C libraries:

### Step 1: Write Your C Code
Create `native_math.c`:
```c
// native_math.c
#include <stdint.h>

int64_t native_fast_add(int64_t a, int64_t b) {
    return (a * 2) + (b * 2);
}
```

### Step 2: Compile C Object with `rad-clang`
Use Rad's bundled C compiler:
```bash
rad-clang -c native_math.c -o native_math.o
```

### Step 3: Call and Link in Rad
Create `main.rad`:
```rad
// main.rad
fn native_fast_add(a: i64, b: i64) -> i64 {
    // Linked symbol from native_math.o
    return 0
}

fn main() -> i32 {
    let res = native_fast_add(10, 20)
    println("Native math result: {res}")
    return 0
}
```

Compile and link everything in one command:
```bash
radc main.rad native_math.o -o my_app
./my_app
```

---

## 11.4 Compiling C++ with `rad-clang++`

Rad bundles `rad-clang++` alongside `rad-clang`, complete with bundled C++ standard library headers.

To compile C++ translation units:
```bash
rad-clang++ -c helper.cpp -o helper.o
```

When linking C++ objects that use the standard C++ library (`std::string`, `std::vector`, `std::cout`), link with `-lstdc++` or `-lc++`:
```bash
radc main.rad helper.o --linker "rad-clang++ -static" -o my_cpp_app
```
