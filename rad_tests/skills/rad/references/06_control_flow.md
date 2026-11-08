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
