# Rad C++ Interoperability Specification

Rad provides native interoperability with C++ libraries using the bundled `rad-cxx-pack`, Itanium ABI name mangling, and direct static linking against `libstdc++.a` and `libunwind.a`.

## 1. Declaring Foreign C++ Functions

C++ functions can be declared using `extern "C++"`:

```rad
extern "C++" {
    fn cpp_vector_create() -> *raw u8;
    fn cpp_vector_push(v: *raw u8, val: i32);
    fn cpp_vector_size(v: *raw u8) -> usize;
    fn cpp_vector_destroy(v: *raw u8);
}
```

## 2. Using `rad-clang++`

When `rad-cxx-pack` is installed in `~/.rad/`, `rad-clang++` is available for compiling C++ source files directly into musl-compatible static object files:

```bash
rad-clang++ -c my_cpp_lib.cpp -o my_cpp_lib.o
```

## 3. Linking Rad and C++ Together

Compile Rad code and link with the C++ object file:

```bash
radc main.rad my_cpp_lib.o -o my_app
```

The linker cascade resolves `libstdc++.a`, `libunwind.a`, and `libc.a` into a single, self-contained static PIE binary.
