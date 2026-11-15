# Chapter 11: C & C++ Interoperability

## 11.1 The Rad C ABI Philosophy

Rad does not treat C as an afterthought or an awkward foreign interface. Rad is designed with **mechanical sympathy** for the C ABI:

- Primitive integers (`i32`, `i64`, `u8`, `usize`) directly map to C hardware types (`int32_t`, `int64_t`, `uint8_t`, `size_t`).
- Pointers (`*raw u8`, `*raw T`) use standard 64-bit machine pointer representation.
- Functions adhere strictly to the System V AMD64 ABI calling convention on Linux.
- Executables statically link against the canonical Musl libc (`libc.a`).

As a result, calling C functions from Rad—or calling Rad functions from C—incurs **zero runtime conversion overhead, zero boxing, and zero marshaling layers**.

---

## 11.2 Declaring Foreign C Functions (`extern "C"`)

To declare C library functions or functions implemented in external C object files, use the `extern "C"` block:

```rad
extern "C" {
    fn puts(s: str) -> i32;
    fn getenv(name: str) -> str;
    fn system(cmd: str) -> i32;
    fn malloc(size: usize) -> *raw u8;
    fn free(ptr: *raw u8) -> void;
}

fn main() -> i32 {
    let user = getenv("USER")
    if (user as usize) != 0usize {
        print("Current user: ")
        println(user)
    }

    // Call libc system() directly:
    system("uname -a")
    return 0
}
```

---

## 11.3 Struct Memory Layout & C Interoperability

Rad structs have standard C memory layout without hidden padding or metadata headers. A Rad struct can be passed directly by pointer to C functions:

### 1. In C Header / Implementation (`matrix.c`):
```c
// matrix.c
#include <stdint.h>

struct Vector2D {
    int64_t x;
    int64_t y;
};

int64_t vector_dot(const struct Vector2D* a, const struct Vector2D* b) {
    return (a->x * b->x) + (a->y * b->y);
}
```

### 2. In Rad (`main.rad`):
```rad
// main.rad
struct Vector2D {
    x: i64,
    y: i64,
}

extern "C" {
    fn vector_dot(a: *raw Vector2D, b: *raw Vector2D) -> i64;
}

fn main() -> i32 {
    let v1 = Vector2D { x: 3, y: 4 }
    let v2 = Vector2D { x: 2, y: 5 }

    let dot = vector_dot(&v1 as *raw Vector2D, &v2 as *raw Vector2D)
    print("Vector dot product: ")
    println(dot)
    return 0
}
```

---

## 11.4 Compiling & Linking C Code with Rad

When your project includes custom C algorithms, hardware device drivers, or third-party C libraries:

### Step 1: Compile C Object with `rad-clang`
Use Rad's bundled C compiler:
```bash
rad-clang -c matrix.c -o matrix.o
```

### Step 2: Compile and Link with `radc`
Pass the compiled `.o` file directly to `radc`:
```bash
radc main.rad matrix.o -o my_app
./my_app
```

Output:
```text
Vector dot product: 26
```

---

## 11.5 Compiling C++ with `rad-clang++`

Rad bundles `rad-clang++` alongside `rad-clang`, complete with bundled C++ standard library headers.

To compile C++ translation units:
```bash
rad-clang++ -c helper.cpp -o helper.o
```

When linking C++ objects that use the standard C++ library (`std::string`, `std::vector`, `std::cout`), pass `-lstdc++` or `-lc++`:
```bash
radc main.rad helper.o -o my_cpp_app
```
