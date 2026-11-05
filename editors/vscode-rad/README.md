# Rad Programming Language Extension for Visual Studio Code

Official Visual Studio Code and editor extension for the **Rad Programming Language**.

## Features

- **Full Syntax Highlighting**: Comprehensive TextMate grammar covering Rad keywords, types, control flow, functions, attributes, and formatting.
- **Language Server Protocol (LSP)**: Automatic connection to `rad lsp` providing diagnostics, symbol definition, hover info, and canonical code formatting.
- **Bracket Matching & Auto-closing**: Automatic closing of braces, brackets, parentheses, and quotes.

## Getting Started

1. Ensure `rad` is installed and available in your `PATH`.
2. Open any `.rad` file in VS Code.
3. The extension will automatically activate and start the Rad Language Server.

## Configuration

- `rad.lsp.path`: Path to the `rad` compiler executable (default: `"rad"`).
- `rad.lsp.arguments`: Command-line arguments to start the language server (default: `["lsp"]`).
