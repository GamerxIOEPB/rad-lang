# Chapter 15: Tooling & Editor Support

## 15.1 Visual Studio Code Extension

Rad provides a dedicated VS Code extension located in [`editors/vscode-rad`](file:///home/abhinav/Projects/rad/editors/vscode-rad):

### Features:
- **Syntax Highlighting**: Complete TextMate grammar covering keywords (`fn`, `let`, `var`, `struct`, `if`, `else`, `while`, `return`, `as`, `pub`, `break`, `continue`), primitive types, operators, numbers, and strings.
- **Bracket Matching & Auto-Closing**: Automatic bracket, parenthesis, and quote pairing.
- **Comment Toggling**: Single-line (`//`) and block (`/* */`) comment shortcuts.
- **Code Snippets**: Quick templates for functions, structs, while loops, and `main()`.

### Installation in VS Code:
Install the packaged `.vsix` file using the `code` CLI:

```bash
code --install-extension editors/vscode-rad/rad-lang-0.1.0.vsix
```

---

## 15.2 Tree-Sitter Grammar

For editors supporting Tree-Sitter (Neovim, Emacs, Helix, Zed), Rad provides an official Tree-Sitter parser grammar in [`editors/tree-sitter-rad`](file:///home/abhinav/Projects/rad/editors/tree-sitter-rad):

- `grammar.js`: Precise formal syntax specification.
- `queries/highlights.scm`: Syntax tree highlighting queries.
- `queries/indents.scm`: Automatic indentation logic.
- `queries/locals.scm`: Scope and local identifier definition queries.
