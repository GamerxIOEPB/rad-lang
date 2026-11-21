# Rad Standard Library Specification (`std`)

The Rad Standard Library is organized into three tiered layers: `core`, `alloc`, and `std`. It provides high-performance, zero-overhead primitives for low-level systems programming, networking, data serialization, cryptographic operations, graphics, and concurrency without external dependencies.

---

## 1. Core & Alloc Foundation

### `core` (Freestanding / `#![no_core]`)
Available across all targets (including bare-metal kernels and embedded targets):
- **Numerical Primitives**: Fixed-width integers (`i8`..`i64`, `u8`..`u64`), pointer-sized integers (`isize`, `usize`), floating-point numbers (`f32`, `f64`).
- **Memory Intrinsics**: `memcpy`, `memmove`, `memset`.
- **Bitwise & Arithmetic Operations**: Overflow-checked arithmetic, shifts (`shl`, `shr`), and bitwise masks.

### `alloc` (Heap-Enabled Data Structures)
- **`Vec<T>`**: Dynamically resizable array backed by the global allocator.
  - `Vec.new() -> Vec<T>`
  - `vec.push(item: T)`
  - `vec.pop() -> Option<T>`
  - `vec.get(idx: usize) -> Option<T>`
  - `vec.len: usize`, `vec.cap: usize`, `vec.ptr: *raw T`
- **`String`**: UTF-8 encoded heap-allocated string buffer.
  - `String.new() -> String`
  - `String.from_str(s: str) -> String`
  - `str.push_str(s: str)`
  - `str.push_byte(b: u8)`
  - `str.as_ptr() -> *raw u8`
  - `str.len() -> usize`
- **`HashMap<K, V>`**: High-performance hash table using Robin Hood open addressing.

---

## 2. Desktop GUI & Windowing (`std/gui`)

100% pure Rad implementation of Wayland and X11 display protocols:
- **Display Servers**: Auto-detects Wayland (`$WAYLAND_DISPLAY`, `$XDG_RUNTIME_DIR`) and X11 (`$DISPLAY`).
- **Window Management**: `Window::open(title: str, w: i32, h: i32) -> Window`.
- **Software Rasterizer**: Anti-aliased circles, rounded rectangles, Bézier curves, dynamic drop shadows, and typography bitmap font cache.
- **UI Toolkit**:
  - `ui_panel(x, y, w, h, title, theme)`
  - `ui_card(x, y, w, h, theme)`
  - `ui_button(x, y, w, h, label, is_hover, is_down)`
  - `ui_slider(x, y, w, h, val, min, max, theme) -> f32`
  - `ui_checkbox(x, y, size, label, checked, theme)`
  - `ui_toggle(x, y, w, h, state, theme)`
  - `ui_progress_bar(x, y, w, h, progress, theme)`
  - `ui_badge(x, y, text, bg, fg)`
- **Event Handling**: Unified event loop yielding `WindowEvent` (`WINDOW_EVENT_KEY_DOWN`, `WINDOW_EVENT_KEY_UP`, `WINDOW_EVENT_MOUSE_MOVE`, `WINDOW_EVENT_MOUSE_DOWN`, `WINDOW_EVENT_CLOSE`).
- **Keycode Mappings**: Unifies Linux evdev keycodes (`KEY_ESC = 1`, `KEY_Q = 16`, `KEY_SPACE = 57`, `KEY_T = 20`, `KEY_A = 30`, `KEY_S = 31`) with X11 keycodes (`9`, `24`, `65`, `28`, `38`, `39`).

---

## 3. Hardware GPU Compute & Vulkan Pipeline (`std/gpu`)

Direct native Vulkan API bindings with zero C libraries:
- **Vulkan Driver**: `VulkanContext::init()`, `VkPhysicalDeviceInfo`, swapchain creation (`VkSwapchainKHR`).
- **SPIR-V Emitter**: Pure-Rad binary bytecode assembler emitting valid SPIR-V bytecode (`0x07230203`).
- **Compute Kernels (`GpuComputeKernel`)**:
  - `dispatch_matmul_i64(a, b, m, k, n)`: General matrix multiplication on GPU workgroups.
  - `dispatch_sha256(data)`: Parallel cryptographic hashing on GPU compute units.
  - `dispatch_curve_raster(p0, p1, p2, p3, steps)`: Hardware-accelerated Bézier curve tessellation.

---

## 4. Formal SMT Verification & Escape Analysis (`std/smt`, `std/mir`)

Compile-time formal proofs and zero-cost allocation promotion:
- **`MemorySafetyVerifier` (`std/smt`)**:
  - Generates SMT-LIB2 first-order logic formulas.
  - Proves absence of array out-of-bounds indexing (`0 <= i < len`).
  - Proves 64-bit arithmetic overflow freedom.
- **Escape Analysis & Stack Promotion (`std/mir`)**:
  - `pass_escape_analysis`: Analyzes flow-sensitive pointer lifetimes and return escapes.
  - `pass_stack_promotion`: Automatically lowers non-escaping `MIR_HEAP_ALLOC` allocations (`Vec`, `String`, structs) to zero-cost stack frames (`MIR_ALLOCA`).

---

## 5. Package Management & SAT Dependency Solver (`std/pkg`)

- **SemVer 2.0 Engine**: Semantic version parsing (`major.minor.patch-prerelease+build`) and caret/tilde compatibility testing.
- **SAT SemVer Solver**: Boolean satisfiability solver computing optimal dependency versions and outputting deterministic `rad.lock` manifests.
- **Cryptographic Package Registry**: Ed25519 digital signature signing and SHA-256 content-addressable package distribution.
- **Distributed Build Cache**: Caches compiled object outputs indexed by content hash.

---

## 6. Language Server Protocol (`std/lsp`)

Standardized Language Server Protocol daemon implementation over `stdio` using JSON-RPC 2.0:
- **Capabilities**:
  - `textDocument/didOpen`, `didChange`, `didClose`: Document synchronization.
  - `textDocument/hover`: Hover documentation and type signatures.
  - `textDocument/definition`: Cross-module symbol navigation.
  - `textDocument/completion`: Auto-completion for keywords, types, and functions.
  - `textDocument/rename`: Workspace-wide refactoring edits.
  - `textDocument/publishDiagnostics`: Live compiler diagnostics piped into editors.

---

## 7. Networking, Web & Cryptography

- **`std/http` & `std/async_http`**: High-throughput HTTP/1.1 client and multi-threaded server.
- **`std/tls`**: Native TLS 1.3 protocol handshake and secure record layer encryption.
- **`std/crypto`**: SHA-256, SHA-512, Ed25519 signatures, ChaCha20-Poly1305, AES-GCM.
- **`std/dom`**: Server-side rendering (SSR) of virtual DOM elements to HTML5.

---

## 8. Data Serialization & Storage

- **`std/json`**: High-speed JSON tokenizer, AST parser, and stringifier.
- **`std/toml`**: TOML configuration parser supporting tables, arrays, and inline values.
- **`std/arrow` & `std/parquet`**: Apache Arrow columnar data structures and Parquet binary storage.
- **`std/kv`**: Embedded ACID-compliant key-value persistent storage.
- **`std/sql`**: Embedded SQLite3 database driver and SQL query engine.
- **`std/compress`**: High-performance DEFLATE, Zstandard, and Gzip compression.

---

## 9. Advanced Systems Primitives

- **`std/actor`**: Actor model concurrency with typed mailboxes and asynchronous dispatch.
- **`std/task`**: Cooperative green task scheduler and asynchronous channel queues.
- **`std/arc`**: Atomic reference counting with deterministic RAII destructor drops.
- **`std/effect`**: Algebraic effect handlers and delimited continuations.
- **`std/raft`**: Distributed RAFT consensus state machine for fault-tolerant clustering.
- **`std/cluster`**: Node discovery, heartbeat exchange, and peer membership management.
- **`std/zk_snark`**: Zero-knowledge proof verification using pairing-friendly elliptic curves.
- **`std/wasm`**: In-process WebAssembly binary bytecode interpreter and stack VM.
- **`std/simd`**: Architecture-specific 128-bit and 256-bit SIMD vector lane operations.
- **`std/kernel`**: Bare-metal x86_64 multiboot header generation, GDT setup, and page table initialization.
- **`std/elf`, `std/macho`, `std/pe`**: Native binary executable header parsers and loaders.
