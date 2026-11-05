; Scopes
[
  (function_item)
  (block)
  (if_expression)
  (while_expression)
  (for_expression)
  (match_expression)
] @scope

; Definitions
(function_item
  name: (identifier) @definition.function)

(struct_item
  name: (identifier) @definition.type)

(enum_item
  name: (identifier) @definition.type)

(trait_item
  name: (identifier) @definition.type)

(parameter
  name: (identifier) @definition.var)

(let_statement
  pattern: (identifier_pattern (identifier) @definition.var))

(var_statement
  pattern: (identifier_pattern (identifier) @definition.var))

; References
(identifier) @reference
