# Chapter 9: Pointers, Memory & Casting

## 9.1 Raw Pointers (`*raw T`)

Rad provides low-level raw pointers that represent direct hardware memory addresses:

- `*raw T`: A pointer to memory holding values of type `T`.
- `*raw u8`: A raw byte pointer (analogous to `uint8_t*` or `char*` in C).
- `*raw *raw u8`: Multi-level raw pointer (used for `argv` arrays and string tables).

---

## 9.2 Pointer Indexing & Dereferencing

Pointers in Rad can be indexed directly using bracket syntax (`ptr[index]`), functioning like an unbounded memory view:

```rad
fn print_bytes(ptr: *raw u8, len: usize) {
    var i: usize = 0usize
    while i < len {
        let b: u8 = ptr[i] // Read byte at offset i
        print("Byte: ")
        println(b as i32)
        i = i + 1usize
    }
}
```

### Writing Through Pointer Indexing
```rad
fn zero_buffer(buf: *raw u8, len: usize) {
    var i: usize = 0usize
    while i < len {
        buf[i] = 0u8 // Write byte at offset i
        i = i + 1usize
    }
}
```

---

## 9.3 Dynamic Memory Allocation (`malloc`, `free`)

Because Rad programs link against the canonical Musl target sysroot (`libc.a`), the standard heap allocation primitives are direct zero-cost calls:

```rad
extern "C" {
    fn malloc(size: usize) -> *raw u8;
    fn free(ptr: *raw u8) -> void;
}

fn main() -> i32 {
    // 1. Allocate 64 bytes on the heap
    let size: usize = 64usize
    let buffer: *raw u8 = malloc(size)

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
    print("Buffer string: ")
    println(buffer as str)

    // 4. Free allocated memory
    free(buffer)
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

## 9.4 Pointer Arithmetic & Address Offsets

Pointer arithmetic in Rad is performed transparently using index offsets (`ptr[offset]`) or by converting the pointer to an integer address with `as usize`, performing byte-level arithmetic, and casting back:

```rad
fn main() -> i32 {
    let msg: str = "Rad Systems Programming"
    let p_msg: *raw u8 = msg as *raw u8

    // Skip the first 4 bytes ("Rad ") by pointer address arithmetic:
    let addr: usize = (p_msg as usize) + 4usize
    let p_sub: *raw u8 = addr as *raw u8

    print("Original: ")
    println(msg)
    print("Sub-slice: ")
    println(p_sub as str)
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

1. **Always Match `malloc` with `free`**: For heap allocations created with `malloc()`, ensure they are freed when no longer needed to prevent memory leaks.
2. **Prefer Built-In `String` and `Vec`**: In application code, prefer the standard heap collections `String` and `Vec<T>`, which automatically manage their own buffers, dynamic reallocation, and growth.
3. **Check for Null Pointers**: Validate pointer addresses against zero (`(ptr as usize) == 0usize`) when receiving pointers from OS APIs or C libraries.
