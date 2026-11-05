# Rad Compiler Internals (`radc`) Specification

`radc` is the self-hosted production compiler for Rad, implemented in modular Rad without external runtimes or build dependencies.

## 1. Modular Source Structure (`src/compiler/radc/src/`)

- `util.rad`: String, character, integer, and file system utilities (`read_file_string`, `int_to_str`).
- `token.rad`: Lexical scanner (`lex_source()`) tracking 1-indexed lines and columns.
- `ast.rad`: Abstract Syntax Tree definitions for Expressions, Statements, Functions, and Structs.
- `parser.rad`: Pratt recursive descent parser with formatted diagnostic error reporting.
- `codegen.rad`: Direct SSA LLVM IR emitter with uniform 64-bit struct word layout.
- `linker.rad`: Mode A 5-tier Linker Cascade with accurate exit status decoding.
- `main.rad`: CLI driver handling `--emit-llvm`, `--check`, `-O<level>`, `--target`, `-V`.

## 2. Compilation Pipeline

```text
Source Files (*.rad)
       │
       ▼
[Lexer (token.rad)]
       │ Tokens (line, col)
       ▼
[Parser (parser.rad)]
       │ AST Arena (exprs, stmts, functions, structs)
       ▼
[Codegen (codegen.rad)]
       │ Direct SSA LLVM IR (*.tmp.ll)
       ▼
[Mode A Linker Cascade (linker.rad)]
       │
       ├─ Tier 1: User-specified linker override (--linker)
       ├─ Tier 2: Bundled rad-llc + rad-lld with musl static sysroot (Default Static PIE)
       ├─ Tier 3: Clang fallback (-no-pie -lm -lpthread)
       ├─ Tier 4: GCC fallback (-no-pie -lm -lpthread)
       └─ Tier 5: Host llc + ld.lld / ld direct backend
       │
       ▼
Self-Contained Native Binary (Static PIE ELF)
```

## 3. Bootstrap Convergence

The compiler achieves bit-for-bit reproducibility via 3-stage bootstrap:
1. **Stage 0**: Rust bootstrap reference compiler compiles `radc/*.rad` -> `stage0_radc`.
2. **Stage 1**: `stage0_radc` compiles `radc/*.rad` -> `stage1_radc`.
3. **Stage 2**: `stage1_radc` compiles `radc/*.rad` -> `stage2_radc`.
4. Verification: `cmp -s stage1_radc stage2_radc` (100% byte-for-byte identical).
