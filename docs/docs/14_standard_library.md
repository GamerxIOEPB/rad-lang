# Chapter 14: Standard Library Reference

The Rad Standard Library is organized into three distinct tiers based on dependency boundaries:

```
library/
├── core/   # Fundamental math, option, result, memory traits (no heap required)
├── alloc/  # Dynamic memory allocation, strings, and collections (heap enabled)
└── std/    # Pure native OS systems: terminal, keyboard, console, time, io, fs
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

- **`String`**: Dynamically resizable heap string buffer with UTF-8 byte manipulation, appending, and length queries.
- **`Vec<T>`**: Contiguous heap array buffer with amortized O(1) growth, pushing, popping, and indexing.

---

## 14.3 Standard Library (`library/std`) — Pure Native Systems Infrastructure

Starting in Rad 0.2.0, the standard library provides comprehensive native systems modules implemented entirely in pure Rad using direct Linux system-call intrinsics—with **zero dependencies on C, libc, ncurses, or SDL**.

### 1. Terminal Control (`library/std/src/terminal.rad`)
Provides complete ANSI and POSIX terminal management:
- **Raw Mode**: Enables raw unbuffered keyboard input via `tcgetattr`/`tcsetattr` kernel ioctls.
- **Alternate Screen Buffer**: Switches cleanly between primary and alternate terminal screens (`\x1b[?1049h`).
- **Cursor Manipulation**: Hide, show, move to `(row, col)`, save and restore cursor position.
- **Coloring**: Foreground and background styling using 16 standard ANSI colors and 24-bit TrueColor RGB.
- **Kitty Keyboard Protocol**: Progressively activates full key event detection, including release events (`\x1b[>3u`).

```rad
import std::terminal

fn main() -> i32 {
    terminal::enter_alternate_screen()
    terminal::enable_raw_mode()
    terminal::hide_cursor()

    terminal::set_fg(terminal::Color::Cyan)
    terminal::move_cursor(5, 10)
    print("Welcome to Native Rad Terminal UI!")

    terminal::reset_color()
    terminal::show_cursor()
    terminal::disable_raw_mode()
    terminal::leave_alternate_screen()
    return 0
}
```

### 2. Keyboard & Input Handling (`library/std/src/keyboard.rad`)
Parses non-blocking terminal input into structured `KeyEvent` records:
- **Key Codes**: Arrow keys (`Up`, `Down`, `Left`, `Right`), `Enter`, `Escape`, `Backspace`, `Tab`, `Space`, and alphanumeric characters.
- **Release Event Detection**: Full support for Kitty keyboard protocol release codes (`evt.is_release`, `evt.is_key`), preventing typematic keyboard repeat delays in action games.
- **Modifiers**: Detects `Ctrl`, `Alt`, and `Shift` key combinations.

```rad
import std::keyboard

fn main() -> i32 {
    var kb = keyboard::Keyboard::new()
    
    while true {
        let evt = kb.poll_event()
        if evt.has_event {
            if evt.key == keyboard::KeyCode::Escape {
                break
            }
            if evt.is_key(keyboard::KeyCode::Up) && !evt.is_release {
                println("Moving UP")
            }
        }
    }
    return 0
}
```

### 3. Console & Double-Buffered Canvas (`library/std/src/console.rad`)
Double-buffered terminal canvas for rendering tear-free animations, game frames, and interactive dashboards:
- **`ConsoleBuffer`**: In-memory character grid with color attributes.
- **Box Drawing**: Rectangles, borders, centered text, and horizontal progress bars.
- **Differential Flush**: Minimizes terminal escape emissions by flushing only modified cells.

### 4. Monotonic Time & Timers (`library/std/src/time.rad`)
High-resolution timing implemented via direct Linux `clock_gettime(CLOCK_MONOTONIC)` and `nanosleep` kernel system calls:

```rad
import std::time

fn main() -> i32 {
    let t0 = time::now_ns()

    // Precise sub-millisecond sleep
    time::sleep_ms(16) // ~60 frames per second pacing

    let elapsed_ns = time::now_ns() - t0
    print("Elapsed nanoseconds: ")
    println(elapsed_ns)
    return 0
}
```

### 5. File System & Process Management
- **`fs.rad`**: Direct kernel open, read, write, and close operations without libc wrappers.
- **`process.rad`**: Child process spawning, argument passing, environment inspection, and waitpid exit status queries.
