# Chapter 14: Standard Library Reference

The Rad Standard Library is organized into three distinct tiers based on dependency boundaries:

```
library/
├── core/   # Foundation math, panic, memory, and fundamental traits
├── alloc/  # Dynamic memory allocation, strings, and collections
└── std/    # System I/O, file system, process execution, time, and networking
```

---

## 14.1 Core Library (`library/core`)

The `core` library contains fundamental language operations that do not require dynamic heap allocation.

### Math Operations (`library/core/src/math.rad`)
```rad
pub fn min(a: i64, b: i64) -> i64
pub fn max(a: i64, b: i64) -> i64
pub fn abs(x: i64) -> i64
pub fn clamp(val: i64, min_val: i64, max_val: i64) -> i64
```

### Option Type (`library/core/src/option.rad`)
Represents optional values (present or absent):
```rad
pub struct Option {
    is_some: bool,
    value: i64,
}

pub fn some(val: i64) -> Option
pub fn none() -> Option
```

### Result Type (`library/core/src/result.rad`)
Represents either success or error:
```rad
pub struct Result {
    is_ok: bool,
    val: i64,
    err: i64,
}

pub fn ok(val: i64) -> Result
pub fn err(err_code: i64) -> Result
```

---

## 14.2 Alloc Library (`library/alloc`)

The `alloc` library provides dynamically sized types backed by heap allocation:

- **`string.rad`**: Heap-allocated UTF-8 string buffer utilities.
- **`vec.rad`**: Dynamic contiguous array buffer implementation.

---

## 14.3 Standard Library (`library/std`)

The `std` library exposes operating system functionality:

- **`io.rad`**: Standard streams (`stdin`, `stdout`, `stderr`), line reading, and buffered terminal output.
- **`fs.rad`**: File system operations (`read_file`, `write_file`, opening file descriptors).
- **`process.rad`**: Process spawning, exit status queries, and command execution.
- **`time.rad`**: System monotonic timestamps and duration sleeps.
- **`thread.rad`**: POSIX thread synchronization and threading primitives.
