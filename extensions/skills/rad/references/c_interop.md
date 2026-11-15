# Rad C Interoperability Specification

Rad compiles directly to native static ELF binaries and links seamlessly with standard C ABI libraries, musl libc, and custom C archives (`.a`, `.o`).

## 1. Declaring Foreign C Functions

Use `extern "C"` to declare external C symbols:

```rad
extern "C" {
    fn puts(s: str) -> i32;
    fn printf(fmt: str, ...) -> i32;
    fn malloc(size: usize) -> *raw u8;
    fn free(ptr: *raw u8);
    fn system(cmd: str) -> i32;
    fn fopen(path: str, mode: str) -> *raw u8;
    fn fclose(fp: *raw u8) -> i32;
}
```

## 2. Calling C Functions

C functions are invoked like native Rad functions. Ensure strings passed to C functions are null-terminated:

```rad
fn main() {
    puts("Hello from C puts!");
    printf("Formatted int: %d\n", 42);
}
```

## 3. Exporting Rad Functions to C

Use `#[export_name = "..."]` or `pub extern "C"` to export a Rad symbol with standard C ABI calling convention:

```rad
pub extern "C" fn rad_compute_sum(a: i32, b: i32) -> i32 {
    return a + b;
}
```

## 4. C Struct Layout (`#[repr(C)]`)

For interoperability with C struct definitions, `#[repr(C)]` guarantees standard C padding and alignment rules.
