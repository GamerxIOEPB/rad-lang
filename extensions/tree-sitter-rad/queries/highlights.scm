; Keywords
[
  "fn"
  "async"
  "unsafe"
  "extern"
] @keyword.function

[
  "struct"
  "enum"
  "trait"
  "impl"
  "type"
] @keyword.type

[
  "let"
  "var"
  "take"
  "ref"
  "mut"
  "pub"
] @keyword

[
  "if"
  "else"
  "match"
] @keyword.conditional

[
  "while"
  "for"
  "in"
] @keyword.repeat

[
  "return"
  "defer"
] @keyword.return

[
  "import"
  "from"
] @keyword.import

"as" @keyword.operator
".await" @keyword.coroutine

; Types
(primitive_type) @type.builtin

(custom_type
  (path (identifier) @type))

(type_parameter
  (identifier) @type.parameter)

(struct_item
  name: (identifier) @type)

(enum_item
  name: (identifier) @type)

(enum_variant
  name: (identifier) @constant)

(trait_item
  name: (identifier) @type)

; Functions
(function_item
  name: (identifier) @function)

(call_expression
  function: (identifier) @function.call)

(call_expression
  function: (path (identifier) @function.call))

(method_call_expression
  method: (identifier) @function.method)

; Parameters & Variables
(parameter
  name: (identifier) @variable.parameter)

(struct_field
  name: (identifier) @property)

(field_expression
  field: (identifier) @property)

(field_initializer
  name: (identifier) @property)

(identifier) @variable

; Literals
(integer_literal) @number
(float_literal) @number.float
(string_literal) @string
(raw_string_literal) @string
(format_string_literal) @string.special
(char_literal) @character
(boolean_literal) @boolean

; Attributes
(attribute) @attribute

; Operators
[
  "="
  "+="
  "-="
  "*="
  "/="
  "%="
  "=="
  "!="
  "<"
  "<="
  ">"
  ">="
  "+"
  "-"
  "*"
  "/"
  "%"
  "&&"
  "||"
  "!"
  "&"
  "|"
  "^"
  "<<"
  ">>"
  "->"
  "=>"
] @operator

; Punctuation
[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

[
  ","
  "."
  ":"
  "::"
  ";"
] @punctuation.delimiter

; Comments
(comment) @comment
