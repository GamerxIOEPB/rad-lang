# Chapter 15: Tooling & Editor Support

## 15.1 Official VS Code Extension: Rad Utils

The official Visual Studio Code extension for Rad is **Rad Utils** (located in [`editors/vscode-rad`](file:///home/abhinav/Projects/rad/editors/vscode-rad)). Rad Utils elevates Rad from basic syntax highlighting to a complete, first-class IDE experience powered directly by the self-contained `rad lsp` language server.

### Key Capabilities

1. **Integrated Language Server Protocol (`rad lsp`)**:
   - Spawns the native `rad lsp` engine over stdio automatically with zero external dependencies.
   - Provides live syntactic and semantic validation as you type.

2. **Real-Time Compiler Diagnostics & Error Highlighting**:
   - Immediate red squiggly underlines on syntax errors, type mismatches, and undeclared variable assignments (`E0001` through `E0030`).
   - Yellow squiggly underlines on unused mutability warnings (`W0001: variable does not need to be mutable`).
   - Hovering over highlighted problems displays the diagnostic message with actionable hints.
   - Problems panel integration with accurate source line and character ranges.

3. **Intelligent Autocompletion**:
   - Keyword completions (`fn`, `let`, `var`, `struct`, `impl`, `while`, `import`, `extern`, etc.).
   - Built-in primitive types (`i8`, `i16`, `i32`, `i64`, `u8`, `u16`, `u32`, `u64`, `f32`, `f64`, `bool`, `str`, `usize`, `isize`).
   - Local and module-level function and variable symbol suggestions.

4. **Hover Documentation**:
   - Hover over keywords, primitives, and function signatures to view concise type and role explanations.

5. **Go-to-Definition**:
   - Jump directly from function calls to their top-level function declarations across the active file (`F12` or `Ctrl+Click`).

6. **Document Outline & Symbol Navigation**:
   - Populates VS Code's Outline view and Breadcrumbs with declared functions and structs.
   - Jump between symbols using `Ctrl+Shift+O`.

7. **Native Code Formatting (`rad fmt`)**:
   - Format documents on demand (`Shift+Alt+F`) or automatically on save.
   - Enforces Rad's standard 4-space indentation, Egyptian braces, clean operator spacing, and blank line rules.

8. **Rich Code Snippets**:
   - Snippet expansion for `fn`, `main`, `struct`, `impl`, `if`, `ifelse`, `while`, `for`, `println`, `print`, `extern`, and more.

---

### Installing Rad Utils

#### From VSIX Package:
Download or locate the compiled `rad-utils-0.2.3.vsix` package and install it via the VS Code CLI:

```bash
code --install-extension rad-utils-0.2.3.vsix
```

Alternatively, in VS Code:
1. Open the Extensions view (`Ctrl+Shift+X`).
2. Click the `...` (Views and More Actions) menu in the top right.
3. Select **Install from VSIX...**
4. Choose `rad-utils-0.2.3.vsix`.

---

### Extension Settings

You can customize the extension behavior in VS Code settings (`settings.json`):

| Setting | Default | Description |
| :--- | :--- | :--- |
| `rad.lsp.path` | `"rad"` | Path to the `rad` CLI binary (uses `$PATH` by default) |
| `rad.lsp.arguments` | `["lsp"]` | Command arguments passed when launching the language server |
| `rad.lsp.trace.server` | `"off"` | Trace communication between VS Code and `rad lsp` (`off`, `messages`, `verbose`) |
| `rad.format.enable` | `true` | Enable document formatting via `rad fmt` |

#### Example `settings.json`:
```json
{
  "[rad]": {
    "editor.defaultFormatter": "GamerxIOEPB.rad-utils",
    "editor.formatOnSave": true,
    "editor.tabSize": 4,
    "editor.insertSpaces": true
  },
  "rad.lsp.path": "rad",
  "rad.format.enable": true
}
```

---

## 15.2 Native CLI Formatter (`rad fmt`)

Rad includes an in-process, high-performance source code formatter directly inside the `rad` CLI:

```bash
# Format files in-place
rad fmt src/main.rad

# Check if files conform to style without modifying (returns exit code 1 if unformatted)
rad fmt --check src/

# Preview formatted output directly to stdout without writing to disk
rad fmt --stdout src/main.rad
```

### Formatting Rules:
- **Indentation**: 4 spaces per block level (tabs converted to spaces).
- **Braces**: Egyptian-style braces (`fn foo() {` on same line; `}` on new line).
- **Operators**: Spaced binary operators (`a + b`, `x = y * 2`), snug unary operators (`!flag`, `-value`).
- **Delimiters**: Snug commas, colons, and semicolons followed by single space (`x: i32, y: i32`).
- **Blank Lines**: Compresses runs of consecutive empty lines down to a maximum of 2 blank lines.
- **Comments**: Preserves both line (`//`) and block (`/* */`) comments with correct indentation.
- **Idempotency**: Formatting already formatted code produces byte-identical output.

---

## 15.3 Tree-Sitter Grammar

For editors supporting Tree-Sitter (such as Neovim, Emacs, Helix, and Zed), Rad provides an official Tree-Sitter parser grammar in [`editors/tree-sitter-rad`](file:///home/abhinav/Projects/rad/editors/tree-sitter-rad):

- `grammar.js`: Precise formal syntax specification.
- `queries/highlights.scm`: Syntax tree highlighting queries.
- `queries/indents.scm`: Automatic indentation rules.
- `queries/locals.scm`: Scope and local identifier definition queries.

### Using with Neovim:
You can register Rad with `nvim-treesitter` to get instant, accurate AST-based syntax highlighting and indentation:

```lua
-- In your init.lua / nvim configuration:
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.rad = {
  install_info = {
    url = "https://github.com/GamerxIOEPB/rad-lang",
    files = {"editors/tree-sitter-rad/src/parser.c"},
    branch = "main",
  },
  filetype = "rad",
}
```
