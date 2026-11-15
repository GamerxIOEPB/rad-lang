# Rad Utils — Official Visual Studio Code Extension

**Rad Utils** is the official Visual Studio Code development extension for the **Rad Programming Language**.

It provides complete language support, real-time compiler diagnostics, code completion, navigation, document symbols, native formatting, and rich snippets.

---

## Features

- **Real-Time Compiler Diagnostics**: Live diagnostic reporting powered directly by `radc` via `rad lsp`. Underlines syntax errors, type mismatches, and unresolved identifiers with error codes (`E0001`–`E0030`).
- **Code Completion**: Contextual autocompletion for Rad keywords (`fn`, `struct`, `impl`, `let`, `var`, `if`, etc.) and built-in primitive types.
- **Hover Documentation**: Detailed documentation, syntax signatures, and usage examples for language keywords, built-ins (`println`, `print`), and types.
- **Go To Definition**: Jump directly to function and struct definitions across documents.
- **Document Symbols & Outline**: View all functions, structs, and methods in the VS Code Outline pane and Quick Outline (`Ctrl+Shift+O`).
- **Native Document Formatting**: Automatic 4-space indentation, Egyptian braces, operator and delimiter spacing via `rad fmt`. Supports format-on-save (`editor.formatOnSave: true`).
- **Syntax Highlighting**: Comprehensive TextMate grammar matching the official Rad v0.2.3 language specification.
- **Rich Snippets**: Quick scaffolding for functions (`fn`), main entry points (`main`), structs (`struct`), implementation blocks (`impl`), loops, and extern C declarations.

---

## Getting Started

1. Ensure the Rad toolchain (`rad` and `radc`) is installed and available in your `PATH` (e.g. via `curl -fsSL https://rad-lang.org/install.sh | bash` or local distribution).
2. Install the **Rad Utils** extension in VS Code.
3. Open any `.rad` file. Rad Utils will automatically activate and start the embedded Language Server.

---

## Extension Settings

| Setting | Default | Description |
| :--- | :--- | :--- |
| `rad.lsp.path` | `"rad"` | Path to the `rad` binary executable. |
| `rad.lsp.arguments` | `["lsp"]` | Command-line arguments passed to start the language server. |
| `rad.lsp.trace.server` | `"off"` | Traces communication between VS Code and `rad lsp` (`off`, `messages`, `verbose`). |
| `rad.format.enable` | `true` | Enable document formatting through `rad fmt`. |

---

## Extension Commands

- **Rad: Restart Language Server** (`rad.restartLsp`): Restarts the background Language Server client.
- **Rad: Show Toolchain Version** (`rad.showVersion`): Displays the currently configured Rad toolchain version.
- **Rad: Format Document** (`rad.formatFile`): Formats the active document using the native Rad formatter.

---

## Snippets

| Prefix | Description |
| :--- | :--- |
| `fn` | Function declaration |
| `main` | Standard `fn main()` entry point |
| `struct` | Struct declaration with fields |
| `impl` | Implementation block for methods |
| `if` / `ifelse` | Branching conditionals |
| `while` / `for` | While and numeric range loops |
| `println` / `print` | Standard output printing |
| `let` / `var` | Variable declarations |
| `extern` | External C block definition |
