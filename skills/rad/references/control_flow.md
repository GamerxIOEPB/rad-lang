# Rad Control Flow Specification

Rad provides structured control flow primitives with strict block scoping and explicit conditions.

## 1. Conditional Branches: `if` / `else if` / `else`

Condition expressions must evaluate to `bool`. Parentheses are optional; curly braces `{}` are mandatory.

```rad
if count > 100 {
    println("Large batch");
} else if count > 0 {
    println("Standard batch");
} else {
    println("Empty batch");
}
```

## 2. While Loops

Executes body statements as long as the condition evaluates to `true`:

```rad
var i = 0usize;
while i < len {
    process(arr.ptr[i]);
    i = i + 1usize;
}
```

## 3. Infinite Loops: `loop`

Repeats indefinitely until terminated by an explicit `break` or `return`:

```rad
loop {
    let packet = receive();
    if packet.is_disconnect() {
        break;
    }
}
```

## 4. `break` and `continue`

- `break`: Immediately exits the innermost enclosing `while` or `loop`.
- `continue`: Skips remainder of current iteration and proceeds to condition or next loop start.

## 5. Early Returns

`return [expr];` immediately exits the current function, executing all RAII cleanup for locally owned variables in the call frame.
