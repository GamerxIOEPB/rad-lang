# Chapter 6: Control Flow

## 6.1 Conditional Branching (`if`, `else if`, `else`)

Rad uses `if` expressions to execute blocks of code based on a Boolean condition:

```rad
fn main() -> i32 {
    let temperature: i64 = 28

    if temperature > 35 {
        println("Heat warning!")
    } else if temperature > 20 {
        println("Pleasant warm weather.")
    } else if temperature > 10 {
        println("Cool weather.")
    } else {
        println("Cold weather alert!")
    }

    return 0
}
```

### Key Rules:
- The condition expression must strictly evaluate to a `bool`.
- Parentheses around conditions are optional (`if x > 0` or `if (x > 0)`).
- The curly braces `{ ... }` around the body and else blocks are **mandatory**, eliminating classic C "dangling else" vulnerabilities.

---

## 6.2 While Loops (`while`)

Rad provides the `while` loop for repeated execution while a Boolean condition evaluates to `true`:

```rad
fn main() -> i32 {
    var counter: i64 = 0

    while counter < 5 {
        print("Iteration: ")
        println(counter)
        counter = counter + 1
    }

    println("Loop completed.")
    return 0
}
```

Output:
```text
Iteration: 0
Iteration: 1
Iteration: 2
Iteration: 3
Iteration: 4
Loop completed.
```

---

## 6.3 Loop Control (`break` & `continue`)

### The `break` Statement
`break` immediately terminates and exits the enclosing loop:

```rad
fn main() -> i32 {
    var i: i64 = 0

    while true {
        if i >= 4 {
            break // Exits loop when i reaches 4
        }
        print("i = ")
        println(i)
        i = i + 1
    }

    println("Broke out of loop.")
    return 0
}
```

### The `continue` Statement
`continue` skips the remainder of the current loop iteration and proceeds immediately to the next condition evaluation:

```rad
fn main() -> i32 {
    var i: i64 = 0

    while i < 10 {
        i = i + 1
        if i % 2 == 0 {
            continue // Skip even numbers
        }
        print("Odd number: ")
        println(i)
    }

    return 0
}
```

Output:
```text
Odd number: 1
Odd number: 3
Odd number: 5
Odd number: 7
Odd number: 9
```

---

## 6.4 Nested Loops & Grid Traversal

Nested loops are common for 2D matrix, game board, and console buffer rendering:

```rad
fn render_grid(width: i32, height: i32) {
    var y = 0
    while y < height {
        var x = 0
        while x < width {
            if x == 0 || x == width - 1 || y == 0 || y == height - 1 {
                print("#")
            } else {
                print(".")
            }
            x = x + 1
        }
        println("")
        y = y + 1
    }
}

fn main() -> i32 {
    render_grid(8, 4)
    return 0
}
```

Output:
```text
########
#......#
#......#
########
```

---

## 6.5 Infinite Loops & Game Loops

Interactive game loops, service polling, and event listeners use `while true` with explicit exit conditions:

```rad
fn run_engine() {
    var running: bool = true
    var frame_count: i64 = 0

    while running {
        frame_count = frame_count + 1
        if frame_count >= 1000 {
            running = false
            break
        }
    }
}
```

---

## 6.6 Block Scope & Statement Separation Rules

Every block `{ ... }` in Rad (function bodies, `if`/`else` branches, `while`/`loop` bodies, `match` arms) enforces explicit statement separation:

1. **Newline separation**: Semicolons are optional between statements located on distinct lines:
   ```rad
   let a = 1
   let b = 2
   ```

2. **Same-line semicolons**: If two or more statements share the same source line, they must be separated with `;`:
   ```rad
   let a = 1; let b = 2
   if condition { do_something() }; println("next")
   ```

3. **Rejection of unseparated same-line statements**:
   ```rad
   let a = 1 let b = 2 // Syntax Error: expected ';' or newline between statements on the same line
   ```

4. **Empty statements & trailing separators**:
   - Consecutive semicolons (`x = 1;; y = 2`) are tolerated as empty statements.
   - Semicolons before a closing brace `}` are optional (`{ foo(); }` and `{ foo() }` are both valid).

---

## 6.7 Pattern Matching (`match`)

Rad provides expressive pattern matching with the `match` construct. It supports literal values, enum variants with extracted payloads, tuple patterns, and conditional pattern guards:

### 1. Value Matching & Wildcard
```rad
let code = 200;
match code {
    200 => println("OK"),
    404 => println("Not Found"),
    500 => println("Internal Server Error"),
    _   => println("Unknown Status"),
}
```

### 2. Enum Variant & Payload Extraction
Match arms can unpack payloads from standard and custom enum variants:
```rad
enum Shape {
    Square,
    Circle(i64),
}

fn describe(shape: Shape) {
    match shape {
        Shape::Circle(radius) => println(f"Circle with radius: {radius}"),
        Shape::Square         => println("Square"),
        _                     => println("Other shape"),
    }
}
```

### 3. Tuple Patterns & Destructuring
Tuples can be matched and bound within match arms:
```rad
fn classify_point(p: (i64, i64)) {
    match p {
        (0i64, 0i64) => println("Origin"),
        (x, 0i64)    => println(f"On X-axis at {x}"),
        (0i64, y)    => println(f"On Y-axis at {y}"),
        (x, y)       => println(f"Quadrant point ({x}, {y})"),
    }
}
```

### 4. Pattern Match Guards (`if <expr>`)
Arms may specify guard conditions with `if` that must evaluate to `true` for the arm to be selected:
```rad
fn inspect_opt(o: Option<i64>) {
    match o {
        Option.Some(x) if x > 100i64 => println(f"Large: {x}"),
        Option.Some(x) if x > 0i64   => println(f"Positive: {x}"),
        Option.Some(x)               => println(f"Zero or negative: {x}"),
        Option.None                  => println("None"),
    }
}
```

### 5. Match Arm Rules
- Pattern guards have access to variables bound in the pattern arm (e.g., `x` above).
- If a wildcard `_` pattern is present, it must be the last arm (`E0030`).
- Match expressions can be used as statements or produce values in return and assignment positions.


