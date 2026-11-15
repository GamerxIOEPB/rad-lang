# Rad Compiler Diagnostics & Error Reference

This catalog details error codes emitted by `radc` and techniques for resolving them.

## Error Codes

### `error[E0001]`: Syntax Delimiter / Parsing Error
- **Description**: The Pratt parser expected a specific delimiter (such as `}`, `)`, or `;`) but encountered a different token or `EOF`.
- **Example**:
  ```rad
  fn main() {
      let x = 10;
  // Missing closing brace '}'
  ```
- **Diagnostic**:
  ```text
  error[E0001]: expected '}', found 'EOF'
    --> src/main.rad:3:1
     |
  3  | 
     | ^
  ```
- **Remedy**: Verify balancing of braces, parentheses, brackets, and statement semicolons.

---

### `error[E0002]`: Unresolved Identifier
- **Description**: An expression references a variable or symbol that has not been declared in current lexical or parameter scope.
- **Example**:
  ```rad
  let y = unknown_variable;
  ```
- **Diagnostic**:
  ```text
  error[E0002]: unresolved identifier 'unknown_variable' in src/main.rad
  ```
- **Remedy**: Declare the variable with `let` or `var`, check spelling, or import the declaring module.

---

### `error[E0003]`: Type Mismatch
- **Description**: Attempted to assign a value of incompatible type without an explicit cast.
- **Example**:
  ```rad
  var x: i32 = "string literal";
  ```
- **Diagnostic**:
  ```text
  error[E0003]: type mismatch: cannot assign string literal to integer variable 'x' in src/main.rad
  ```
- **Remedy**: Adjust the variable type annotation or use an explicit type conversion (`as i32`).

---

### `error: source file is empty`
- **Description**: The input file provided to `radc` exists but contains zero bytes.
- **Remedy**: Add source declarations or remove the empty file from the compilation invocation.
