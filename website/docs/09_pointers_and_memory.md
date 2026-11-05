# Chapter 9: Pointers, Memory & Casting

## 9.1 Raw Pointers (`*raw T`)

Rad provides low-level raw pointers that represent direct hardware memory addresses:

- `*raw T`: An immutable pointer to memory holding values of type `T`.
- `*raw var T`: A mutable pointer through which the underlying memory can be modified.
- `*raw u8`: A raw byte pointer (analogous to `const char*` or `const uint8_t*` in C).
- `*raw var u8`: A mutable raw byte pointer (analogous to `char*` or `uint8_t*` in C).

---

## 9.2 Pointer Indexing & Dereferencing

Pointers in Rad can be indexed directly using bracket syntax (`ptr[index]`), functioning like an unbounded array view:

```rad
fn print_bytes(ptr: *raw u8, len: usize) {
    var i: usize = 0usize
    while i < len {
        let b: u8 = ptr[i] // Read byte at offset i
        println("Byte #{}: {}", i, b)
        i = i + 1usize
    }
}
```

### Mutating Through Pointer Indexing
```rad
fn zero_buffer(buf: *raw var u8, len: usize) {
    var i: usize = 0usize
    while i < len {
        buf[i] = 0u8 // Write byte at offset i
        i = i + 1usize
    }
}
```

---

## 9.3 Dynamic Memory Allocation (`malloc`, `realloc`, `free`)

Because Rad programs link against the C standard library (`libc.a`), the standard heap allocation primitives are built directly into the compiler:

```rad
fn main() -> i32 {
    // 1. Allocate 64 bytes on the heap
    let size: usize = 64usize
    let buffer: *raw var u8 = malloc(size) as *raw var u8

    if (buffer as usize) == 0usize {
        println("Memory allocation failed!")
        return 1
    }

    // 2. Write data into the allocated buffer
    var i: usize = 0usize
    while i < 10usize {
        buffer[i] = (65usize + i) as u8 // Write ASCII 'A', 'B', 'C', ...
        i = i + 1usize
    }
    buffer[10usize] = 0u8 // Null-terminate

    // 3. Print buffer as a string slice
    println("Buffer string: {}", buffer as str)

    // 4. Free allocated memory
    free(buffer as *raw u8)
    println("Memory freed successfully.")

    return 0
}
```

Output:
```text
Buffer string: ABCDEFGHIJ
Memory freed successfully.
```

---

## 9.4 Pointer Arithmetic & Offsets

Pointer arithmetic in Rad is performed transparently using index offsets (`ptr[offset]`) or by converting the pointer to an address integer with `as usize`, performing byte-level arithmetic, and casting back:

```rad
fn main() -> i32 {
    let msg: str = "Rad Systems Programming"
    let p_msg: *raw u8 = msg as *raw u8

    // Skip the first 4 bytes ("Rad ") by pointer arithmetic:
    let addr: usize = (p_msg as usize) + 4usize
    let p_sub: *raw u8 = addr as *raw u8

    println("Original: {}", msg)
    println("Sub-slice: {}", p_sub as str)
    return 0
}
```

Output:
```text
Original: Rad Systems Programming
Sub-slice: Systems Programming
```

---

## 9.5 Memory Safety Best Practices

1. **Always Match `malloc` with `free`**: For heap allocations created with `malloc()`, ensure they are freed with `free()` when no longer needed to prevent memory leaks.
2. **Prefer Built-In `String` and `Vec`**: In application code, prefer the standard heap collections `String` and `Vec`, which manage their own buffers, reallocation, and growth automatically.
3. **Check for Null Pointers**: Validate pointer addresses against zero (`(ptr as usize) == 0usize`) when receiving pointers from OS APIs or C libraries.
