# Rad Standard Library Specification

The Rad Standard Library is organized into three tiered layers: `core`, `alloc`, and `std`.

## 1. `core` Layer (Freestanding / `#![no_core]`)

Available on all targets without an operating system or heap allocator:
- Numerical primitives (`i8`-`i64`, `f32`-`f64`, math operations).
- Boolean logic and comparisons.
- Bitwise operators (`shl`, `shr`, `and`, `or`, `xor`).
- Memory intrinsics (`memcpy`, `memmove`, `memset`).

## 2. `alloc` Layer (Heap-Enabled)

Provides dynamic data structures backed by the global allocator:
- `Vec<T>`: Dynamic growing array.
  - `Vec.new() -> Vec<T>`
  - `vec.push(item: T)`
  - `vec.pop() -> Option<T>`
  - `vec.get(idx: usize) -> Option<T>`
  - `vec.len: usize`, `vec.cap: usize`, `vec.ptr: *raw T`
- `String`: Dynamically resizable UTF-8 text string.
  - `String.new() -> String`
  - `String.from_str(s: str) -> String`
  - `str.push_str(s: str)`
  - `str.push_byte(b: u8)`
  - `str.as_ptr() -> *raw u8`
  - `str.len() -> usize`
- `HashMap<K, V>`: Fast hash map with Robin Hood hashing.

## 3. `std` Layer (Operating System Enabled)

Provides OS-level facilities:
- `std::io`: Console input and output (`println`, `print`, `eprintln`).
- `std::fs`: File system I/O (`File::open`, `File::create`, `read_to_string`).
- `std::env`: Environment variables (`var(name: str)`, `args()`).
- `std::process`: Subprocess execution and exit codes (`Command`, `exit(code: i32)`).
- `std::time`: High-resolution timers and timestamps (`Instant::now()`, `sleep(dur)`).
