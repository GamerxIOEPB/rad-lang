# Rad Arcade

**Rad Arcade** is a suite of real-world, high-performance terminal games written **100% in pure Rad**, exercising the native standard library terminal, keyboard, console, and time modules.

**Zero External Dependencies**:
- **No C / C++ runtime wrappers** (`tcgetattr`, `ioctl`, `poll`, `nanosleep`, etc.)
- **No libc terminal wrappers**
- **No ncurses**
- **No SDL**
- Direct Linux kernel communication exclusively via compiler-provided `syscall0` .. `syscall6` intrinsics.

---

## Architecture & Standard Library Modules

The arcade games are powered by native standard library infrastructure under `library/std/src/`:

| Module | Location | Capabilities |
| :--- | :--- | :--- |
| **Syscall** | `library/std/src/os/linux/syscall.rad` | Raw x86-64 / AArch64 Linux system calls (`sys_read`, `sys_write`, `sys_ioctl`, `sys_poll`, `sys_clock_gettime`, `sys_nanosleep`, `sys_exit`). |
| **Terminal** | `library/std/src/terminal.rad` | Raw mode (`termios` via `TCGETS` / `TCSETSF`), alternate screen buffer (`\e[?1049h`), cursor visibility (`\e[?25l`), window dimensions (`TIOCGWINSZ`), RAII terminal restoration. |
| **Keyboard** | `library/std/src/keyboard.rad` | Non-blocking event loop using `sys_poll`, escape sequence state machine (CSI, SS3, Lone Escape timeout disambiguation, Kitty protocol support). |
| **Console** | `library/std/src/console.rad` | Double-buffered cell matrix (`Cell { ch, fg, bg }`), ANSI TrueColor / 256 / 16 color support, batch diff rendering for flicker-free 60 FPS output. |
| **Time** | `library/std/src/time.rad` | Monotonic clock (`CLOCK_MONOTONIC`), `Duration`, `Instant`, `sleep_ms`, and `FrameTimer` (fixed-interval frame pacing with delta time calculation). |

---

## Included Games

### 1. Tetris (`rad_tests/rad_arcade/tetris/`)
- **Description**: Classic falling-block puzzle game with SRS-style rotation, 7 standard tetrominoes (I, O, T, S, Z, J, L), line clears, leveling, and preview box.
- **Controls**:
  - `Left` / `A`: Move Left
  - `Right` / `D`: Move Right
  - `Up` / `W`: Rotate Piece
  - `Down` / `S`: Soft Drop
  - `Space`: Hard Drop
  - `P`: Pause
  - `Q` / `Esc`: Quit

### 2. Dungeon Crawler (`rad_tests/rad_arcade/dungeon/`)
- **Description**: Procedural roguelike featuring BSP dungeon generation, ray-traced field of view (FOV), wandering monsters (Goblins, Orcs, Trolls), player stats, potions, gold, and multi-floor stairwells.
- **Controls**:
  - `Arrows` / `WASD`: Move & Bump-to-Attack
  - `H`: Drink Health Potion
  - `>`: Descend Stairs
  - `P`: Pause
  - `Q` / `Esc`: Quit

### 3. Space Invaders (`rad_tests/rad_arcade/invaders/`)
- **Description**: Classic arcade shooter with marching alien waves, destructible shield bunkers, alien bomb drops, player laser cannon, and progressive wave acceleration.
- **Controls**:
  - `Left` / `A`: Move Cannon Left
  - `Right` / `D`: Move Cannon Right
  - `Space` / `Up` / `W`: Fire Laser
  - `P`: Pause
  - `R`: Restart (Game Over)
  - `Q` / `Esc`: Quit

### 4. 3D Raycaster (`rad_tests/rad_arcade/raycaster/`)
- **Description**: Full 3D Wolfenstein-style DDA raycasting engine featuring textured wall shading based on depth and orientation, floor gradient, and a live overhead 2D minimap overlay. Powered by pure-Rad Taylor series trigonometry (`rad_sin`, `rad_cos`) with zero math library dependencies.
- **Controls**:
  - `W` / `Up`: Move Forward (with wall collision detection)
  - `S` / `Down`: Move Backward
  - `A` / `Left`: Turn Left
  - `D` / `Right`: Turn Right
  - `Q` / `E`: Strafe Left / Right
  - `M`: Toggle 2D Minimap
  - `Q` / `Esc`: Quit

### 5. Snake (`rad_tests/rad_arcade/snake/`)
- **Description**: High-speed retro snake featuring ring buffer body segmentation, randomized food placement, boundary and self-collision detection, and progressive speed curves.
- **Controls**:
  - `Arrows` / `WASD`: Change Direction
  - `P`: Pause
  - `R`: Restart (Game Over)
  - `Q` / `Esc`: Quit

### 6. Pong (`rad_tests/rad_arcade/pong/`)
- **Description**: Real-time table tennis with smooth 60 FPS ball physics, paddle deflection angle calculations, and dynamic rally acceleration. Supports both single-player vs tracking AI and local two-player modes.
- **Controls**:
  - `W` / `S`: Player 1 Paddle Up / Down
  - `Up` / `Down`: Player 2 Paddle Up / Down (in 2-Player mode)
  - `T`: Toggle AI vs Two-Player Mode
  - `P`: Pause
  - `R`: Restart Match
  - `Q` / `Esc`: Quit

### 7. Breakout (`rad_tests/rad_arcade/breakout/`)
- **Description**: Classic brick-breaker arcade featuring 5 tiers of colored bricks (50 total bricks), paddle trajectory control, multi-ball launch states, and lives tracking.
- **Controls**:
  - `A` / `D` or `Left` / `Right`: Move Paddle
  - `Space`: Launch Ball
  - `P`: Pause
  - `R`: Restart Match
  - `Q` / `Esc`: Quit

---

## How to Build & Run

All games can be compiled directly using the self-hosted Rad compiler (`radc`):

```bash
# Compile and run any game:
radc library/std/src/os/linux/syscall.rad \
     library/std/src/terminal.rad \
     library/std/src/keyboard.rad \
     library/std/src/console.rad \
     library/std/src/time.rad \
     rad_tests/rad_arcade/tetris/main.rad \
     -o rad_tests/rad_arcade/tetris/tetris

./rad_tests/rad_arcade/tetris/tetris
```
