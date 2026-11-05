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

    let sum = a + b       // 29
    let diff = a - b      // 21
    let prod = a * b      // 100
    let quot = a / b      // 6
    let rem = a % b       // 1
    let neg = -a          // -25

    println("sum = {}, diff = {}, prod = {}, quot = {}, rem = {}", sum, diff, prod, quot, rem)
    return 0
}
```

---

## 5.2 Comparison Operators

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
        println("Passed with score: {score}")
    }
    return 0
}
```

---

## 5.3 Logical Operators

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

## 5.4 Operator Precedence

Operators in Rad are evaluated following standard mathematical and systems programming precedence rules (from highest to lowest binding power):

1. **Postfix**: Member access (`.`), Method call (`.method()`), Function call (`()`), Indexing (`[]`)
2. **Unary**: Negation (`-`), Logical NOT (`!`)
3. **Multiplicative**: `*`, `/`, `%`
4. **Additive**: `+`, `-`
5. **Relational / Comparison**: `<`, `<=`, `>`, `>=`
6. **Equality**: `==`, `!=`
7. **Logical AND**: `&&`
8. **Logical OR**: `||`
9. **Cast**: `as`
10. **Assignment**: `=`

Use parentheses `( ... )` to explicitly enforce evaluation order when combining complex expressions.

---

## 5.5 Explicit Type Casting (`as`)

Rad does not perform silent lossy implicit conversions between incompatible types. Conversions between numeric types, pointers, and memory representations require an explicit `as` cast:

```rad
fn main() -> i32 {
    let big: i64 = 1000
    let small: i32 = big as i32

    let val: u64 = 0xDEADBEEF
    let as_ptr: *raw u8 = val as *raw u8
    let back_to_num: usize = as_ptr as usize

    println("small = {}, ptr_addr = {}", small, back_to_num)
    return 0
}
```

### Common Cast Patterns:
- Converting numeric width: `val_i64 as i32`, `byte as i64`
- Casting pointers to integer addresses: `ptr as usize`
- Casting integer addresses to raw pointers: `addr as *raw u8`
- Casting byte pointers to string slices: `byte_ptr as str`
