# RadChess ♜

A complete, high-performance, native Linux terminal chess application written 100% in the **Rad** systems programming language, with zero external dependencies (no C/C++/Rust/Python runtime code, no Stockfish engine, and no internet connection required).

Built to demonstrate the full systems capability of Rad — from raw Linux syscalls, non-blocking network I/O, bitwise Zobrist hashing, and minimax search with transposition tables, to a 60 FPS box-drawing TUI with resilient terminal state guards.

---

## Features

### 1. Complete Chess Engine & FIDE Rules
- **Board Representation**: 64-square representation with 8-byte aligned square array, fast 0x88/index math, and a 1024-deep undo stack.
- **Move Generation**: Accurate pseudo-legal and legal move generators for pawns (single/double push, diagonal captures, en passant, promotions), knights, bishops, rooks, queens, and kings.
- **Special Rules**:
  - Full castling validation (verifying king path is not attacked or in check).
  - En passant target tracking and unmake restoration.
  - Pawn promotions (Queen, Rook, Bishop, Knight).
  - Check, double check, checkmate, and stalemate detection.
  - 50-move rule counter and automatic/claim detection.
  - Threefold repetition claim and fivefold repetition draw.
  - Insufficient material recognition (K vs K, K+B vs K, K+N vs K, K+B vs K+B same-color).
- **Notation & Export**:
  - FEN parser and generator (`to_fen`).
  - Standard Algebraic Notation (SAN) generation with piece disambiguation and check/checkmate suffixes (`+`, `#`).
  - Standard PGN match record generation.

### 2. Built-in Offline Chess AI
- **Search**: Negamax search with alpha-beta pruning and quiescence search (to prevent the horizon effect on captures).
- **Transposition Table**: 16,384-entry hash table with 64-bit Zobrist hashing (pieces, side-to-move, castling rights, and en passant files) and exact/alpha/beta cutoff flags.
- **Move Ordering**: MVV-LVA (Most Valuable Victim - Least Valuable Attacker) capture ordering combined with TT best-move prioritization.
- **Difficulty Levels**:
  - Level 1: *Beginner* (Depth 1, instantaneous response).
  - Level 2: *Easy* (Depth 2, tactical defense).
  - Level 3: *Medium* (Depth 3 with quiescence search).
  - Level 4: *Hard* (Depth 4 with iterative deepening and full PST evaluation).

### 3. LAN Multiplayer & Zero-Config Auto-Discovery
- **Auto-Discovery**: UDP multicast (`239.255.42.99:45871`) and broadcast (`255.255.255.255:45871`) beacons announcing room name, host IP, and time controls.
- **Transport**: Native Linux syscalls (`SYS_socket = 41`, `SYS_bind = 49`, `SYS_listen = 50`, `SYS_connect = 42`, `SYS_accept = 43`, `SYS_sendto = 44`, `SYS_recvfrom = 45`, `SYS_fcntl = 72`, `SYS_poll = 7`) in pure Rad with non-blocking I/O.
- **Protocol**: Colon-delimited deterministic text framing (`HELLO`, `WELCOME`, `MOVE`, `SYNC`, `DRAW_OFFER`, `DRAW_ACCEPT`, `DRAW_DECLINE`, `RESIGN`, `REMATCH_OFFER`, `REMATCH_ACCEPT`, `PING`, `PONG`).
- **Game Authority**: Authoritative host game loop with authoritative clocks and move validation.

### 4. Interactive Terminal User Interface (TUI)
- **Visual Design**: High-density box-drawing borders (`╔═╗`, `│`, `└─┘`), captured piece trays, turn indicators, move log, and dual chess clocks (Rapid 10m, Blitz 5m, Bullet 1m, Unlimited).
- **Themes**:
  - 5 Terminal Palettes: Modern Slate, Classic Wood, Emerald Forest, Midnight, Cyberpunk.
  - Piece Glyphs: Unicode pieces (♔ ♕ ♖ ♗ ♘ ♙ / ♚ ♛ ♜ ♝ ♞ ♟) with ASCII fallback (K, Q, R, B, N, P / k, q, r, b, n, p).
- **Global Terminal Restoration Guard**:
  - Pure Rad signal trampoline with `SYS_rt_sigaction = 13`.
  - Catches `SIGINT` (Ctrl+C), `SIGTERM`, `SIGQUIT`, `SIGHUP`, `SIGSEGV`, `SIGABRT`, `SIGBUS`, and `SIGILL`.
  - Automatically restores cooked terminal mode (`TCSETSF`), restores normal cursor visibility (`\x1b[?25h`), exits alternate screen (`\x1b[?1049l`), and prints a clean diagnostic without locking or corrupting the user's terminal.
  - Automatically integrated into compiler `atexit` and panic cleanup hooks.

---

## Controls

| Key | Action |
|:---|:---|
| **Arrow Keys** / **W A S D** / **H J K L** | Navigate menu options / move cursor across board |
| **Space** / **Enter** | Select square / confirm move / choose menu item |
| **Escape** | Deselect active square / go back to menu |
| **D** | Offer draw |
| **R** (hold or in-game menu) | Resign active match / offer rematch after game over |
| **P** | Export PGN match record |
| **Q** | Back to previous menu / Exit |
| **1 / 2 / 3 / 4** | Quick menu shortcuts |

---

## Building and Running

### Using the Rad Package Manager (`rad`)
```bash
cd rad_tests/rad_arcade/radchess
rad build
./target/debug/main
```

### Direct Compilation with `radc`
```bash
radc rad_tests/rad_arcade/radchess/src/main.rad -o bin/arcade/radchess -O2
./bin/arcade/radchess
```

---

## Test Suites

Run the included verification suites:

```bash
# 1. Perft Move Generation Suite (Verifies 197,281 nodes on depth 4, Kiwipete, Positions 3 & 4)
radc rad_tests/rad_arcade/radchess/tests/test_perft.rad -o bin/test_perft -O2 && ./bin/test_perft

# 2. Chess AI & Transposition Table Puzzle Test (Scholar's Mate verification)
radc rad_tests/rad_arcade/radchess/tests/test_ai.rad -o bin/test_ai -O2 && ./bin/test_ai

# 3. Game Simulation & PGN Export Suite (Fool's Mate checkmate & PGN export)
radc rad_tests/rad_arcade/radchess/tests/test_game.rad -o bin/test_game -O2 && ./bin/test_game

# 4. LAN Multiplayer Syscall & Beacon Test
radc rad_tests/rad_arcade/radchess/tests/test_net.rad -o bin/test_net -O2 && ./bin/test_net

# 5. Configuration Persistence Test (~/.config/radchess/config.ini)
radc rad_tests/rad_arcade/radchess/tests/test_config.rad -o bin/test_config -O2 && ./bin/test_config
```
