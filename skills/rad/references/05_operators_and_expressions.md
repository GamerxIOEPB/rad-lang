# Chapter 5: Operators & Expressions

## 5.1 Arithmetic Operators

Rad supports the standard set of binary and unary arithmetic operators:

| Operator | Name | Example | Description |
| :--- | :--- | :--- | :--- |
| `+` | Addition | `a + b` | Calculates the sum of `a` and `b` |
| `-` | Subtraction | `a - b` | Calculates the difference of `b` from `a` |
| `*` | Multiplication | `a * b` | Calculates the product of `a` and `b` |
| `/` | Division | `a / b` | Integer or floating-point quotient |
| `%` | Modulo | `a % b` | Remainder of integer division |
| `-` | Negation (unary) | `-x` | Negates the numeric operand |

### Example:
```rad
fn main() -> i32 {
    let a: i64 = 25
    let b: i64 = 4

    let sum  = a + b       // 29
    let diff = a - b      // 21
    let prod = a * b      // 100
    let quot = a / b      // 6
    let rem  = a % b       // 1
    let neg  = -a          // -25

    print("sum: ")
    println(sum)
    print("quot: ")
    println(quot)
    print("rem: ")
    println(rem)
    return 0
}
```

---

## 5.2 Bitwise Operators

For systems programming, bitmask manipulation, and protocol framing, Rad provides complete bitwise operators:

| Operator | Name | Example | Description |
| :--- | :--- | :--- | :--- |
| `&` | Bitwise AND | `a & b` | Bits present in both operands |
| `\|` | Bitwise OR | `a \| b` | Bits present in either operand |
| `^` | Bitwise XOR | `a ^ b` | Bits present in exactly one operand |
| `<<` | Left Shift | `a << 2` | Shifts bits left by specified count |
| `>>` | Right Shift | `a >> 2` | Shifts bits right by specified count |

### Example:
```rad
fn main() -> i32 {
    let flags: u32 = 0b0010_1010u32
    let mask:  u32 = 0b0000_1111u32

    let masked = flags & mask
    let combined = flags | 0b0001_0000u32
    let shifted = flags << 2

    print("masked: ")
    println(masked as i32)
    print("shifted: ")
    println(shifted as i32)
    return 0
}
```

---

## 5.3 Comparison Operators

Comparison operators evaluate expressions and return a `bool` (`true` or `false`):

| Operator | Description | Example |
| :--- | :--- | :--- |
| `==` | Equal to | `a == b` |
| `!=` | Not equal to | `a != b` |
| `<` | Less than | `a < b` |
| `<=` | Less than or equal to | `a <= b` |
| `>` | Greater than | `a > b` |
| `>=` | Greater than or equal to | `a >= b` |

### Example:
```rad
fn main() -> i32 {
    let score: i64 = 85

    let is_passing: bool = score >= 50
    let is_perfect: bool = score == 100

    if is_passing && !is_perfect {
        println("Passed the test!")
    }
    return 0
}
```

---

## 5.4 Logical Operators

Rad provides standard short-circuiting Boolean logic operators:

| Operator | Name | Description |
| :--- | :--- | :--- |
| `&&` | Logical AND | Returns `true` only if both operands are `true` (short-circuits) |
| `\|\|` | Logical OR | Returns `true` if either operand is `true` (short-circuits) |
| `!` | Logical NOT | Inverts the boolean operand |

### Example:
```rad
fn main() -> i32 {
    let has_key = true
    let is_admin = false
    let is_emergency = true

    if (has_key || is_admin) && !is_emergency {
        println("Standard access granted")
    } else if is_emergency {
        println("Emergency override active!")
    }
    return 0
}
```

---

## 5.5 Operator Precedence

Operators in Rad are evaluated following standard mathematical and systems programming precedence rules (from highest to lowest binding power):

1. **Postfix**: Member access (`.`), Method call (`.method()`), Function call (`()`), Indexing (`[]`)
2. **Unary**: Negation (`-`), Logical NOT (`!`), Bitwise NOT (`~`)
3. **Multiplicative**: `*`, `/`, `%`
4. **Additive**: `+`, `-`
5. **Shift**: `<<`, `>>`
6. **Bitwise AND**: `&`
7. **Bitwise XOR**: `^`
8. **Bitwise OR**: `|`
9. **Relational / Comparison**: `<`, `<=`, `>`, `>=`
10. **Equality**: `==`, `!=`
11. **Logical AND**: `&&`
12. **Logical OR**: `||`
13. **Cast**: `as`
14. **Assignment**: `=`

Use parentheses `( ... )` to explicitly enforce evaluation order when combining complex expressions.

---

## 5.6 Explicit Type Casting (`as`)

Rad strictly prevents implicit lossy conversions. Conversions between numeric types, pointers, and memory representations require an explicit `as` cast:

```rad
fn main() -> i32 {
    let big: i64 = 1000
    let small: i32 = big as i32

    let val: u64 = 0xDEADBEEFu64
    let as_ptr: *raw u8 = val as *raw u8
    let back_to_num: usize = as_ptr as usize

    print("small: ")
    println(small)
    print("ptr addr: ")
    println(back_to_num as i64)
    return 0
}
```

### Common Cast Patterns:
- Numeric width changes: `val_i64 as i32`, `byte as i64`
- Pointers to integer addresses: `ptr as usize`
- Integer addresses to raw pointers: `addr as *raw u8`
- Byte pointers to string references: `byte_ptr as str`
