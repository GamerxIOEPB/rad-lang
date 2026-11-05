/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: 'rad',

  extras: $ => [
    /\s/,
    $.comment,
  ],

  word: $ => $.identifier,

  conflicts: $ => [
    [$._type, $._expression],
    [$.tuple_type, $.tuple_expression],
    [$.parameter, $._expression],
  ],

  rules: {
    source_file: $ => repeat($._item),

    comment: $ => token(choice(
      seq('//', /.*/),
      seq('/*', /[^*]*\*+([^/*][^*]*\*+)*/, '/')
    )),

    identifier: $ => /[a-zA-Z_][a-zA-Z0-9_]*/,

    // Literals
    _literal: $ => choice(
      $.integer_literal,
      $.float_literal,
      $.string_literal,
      $.raw_string_literal,
      $.format_string_literal,
      $.char_literal,
      $.boolean_literal,
    ),

    integer_literal: $ => token(seq(
      choice(
        /[0-9][0-9_]*/,
        /0x[0-9a-fA-F_]+/,
        /0b[01_]+/,
        /0o[0-7_]+/
      ),
      optional(choice('i8', 'i16', 'i32', 'i64', 'isize', 'u8', 'u16', 'u32', 'u64', 'usize'))
    )),

    float_literal: $ => token(seq(
      /[0-9][0-9_]*\.[0-9_]+([eE][+-]?[0-9_]+)?/,
      optional(choice('f32', 'f64'))
    )),

    string_literal: $ => token(seq(
      '"',
      repeat(choice(
        /[^"\\\n]+/,
        /\\./
      )),
      '"'
    )),

    raw_string_literal: $ => token(seq(
      'r',
      optional(/#+/),
      '"',
      repeat(/[^"]/),
      '"',
      optional(/#+/)
    )),

    format_string_literal: $ => token(seq(
      'f"',
      repeat(choice(
        /[^"\\{\n]+/,
        /\\./,
        seq('{', /[^}\n]+/, '}')
      )),
      '"'
    )),

    char_literal: $ => token(seq(
      "'",
      choice(/[^'\\\n]/, /\\./),
      "'"
    )),

    boolean_literal: $ => choice('true', 'false'),

    // Attributes
    attribute: $ => seq(
      choice('#[', '#!['),
      $.identifier,
      optional(seq('(', commaSep($.attribute_arg), ')')),
      ']'
    ),

    attribute_arg: $ => choice(
      $.identifier,
      $._literal
    ),

    // Top-Level Items
    _item: $ => choice(
      $.function_item,
      $.struct_item,
      $.enum_item,
      $.trait_item,
      $.impl_item,
      $.type_alias_item,
      $.extern_block,
      $.import_item,
      $.statement
    ),

    visibility_modifier: $ => 'pub',

    function_item: $ => seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      optional('async'),
      optional('unsafe'),
      optional(seq('extern', optional($.string_literal))),
      'fn',
      field('name', $.identifier),
      optional($.type_parameters),
      field('parameters', $.parameter_list),
      optional(seq('->', field('return_type', $._type))),
      choice(field('body', $.block), ';')
    ),

    type_parameters: $ => seq(
      '<',
      commaSep1($.type_parameter),
      '>'
    ),

    type_parameter: $ => seq(
      $.identifier,
      optional(seq(':', field('bound', $._type)))
    ),

    parameter_list: $ => seq(
      '(',
      commaSep($.parameter),
      ')'
    ),

    parameter: $ => seq(
      optional(choice('var', 'take', 'ref')),
      field('name', $.identifier),
      optional(seq(':', field('type', $._type)))
    ),

    struct_item: $ => seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      'struct',
      field('name', $.identifier),
      optional($.type_parameters),
      choice(
        seq('{', commaSep($.struct_field), optional(','), '}'),
        ';'
      )
    ),

    struct_field: $ => seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      field('name', $.identifier),
      ':',
      field('type', $._type)
    ),

    enum_item: $ => seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      'enum',
      field('name', $.identifier),
      optional($.type_parameters),
      '{',
      commaSep($.enum_variant),
      optional(','),
      '}'
    ),

    enum_variant: $ => seq(
      repeat($.attribute),
      field('name', $.identifier),
      optional(choice(
        seq('(', commaSep($._type), ')'),
        seq('{', commaSep($.struct_field), '}')
      ))
    ),

    trait_item: $ => seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      'trait',
      field('name', $.identifier),
      optional($.type_parameters),
      '{',
      repeat($._trait_member),
      '}'
    ),

    _trait_member: $ => choice(
      $.function_item
    ),

    impl_item: $ => seq(
      'impl',
      optional($.type_parameters),
      optional(seq(field('trait', $._type), 'for')),
      field('type', $._type),
      '{',
      repeat($.function_item),
      '}'
    ),

    type_alias_item: $ => seq(
      optional($.visibility_modifier),
      'type',
      field('name', $.identifier),
      optional($.type_parameters),
      '=',
      field('type', $._type),
      optional(';')
    ),

    extern_block: $ => seq(
      'extern',
      optional($.string_literal),
      '{',
      repeat($.function_item),
      '}'
    ),

    import_item: $ => seq(
      optional($.visibility_modifier),
      choice('import', seq('from', $.path, 'import')),
      choice(
        $.path,
        seq('{', commaSep1($.identifier), '}')
      ),
      optional(';')
    ),

    path: $ => prec(1, sep1($.identifier, choice('.', '::'))),

    // Types
    _type: $ => choice(
      $.primitive_type,
      $.custom_type,
      $.pointer_type,
      $.reference_type,
      $.array_type,
      $.tuple_type,
      $.function_type
    ),

    primitive_type: $ => choice(
      'i8', 'i16', 'i32', 'i64', 'isize',
      'u8', 'u16', 'u32', 'u64', 'usize',
      'f32', 'f64',
      'bool', 'char', 'str', 'void'
    ),

    custom_type: $ => seq(
      $.path,
      optional($.type_arguments)
    ),

    type_arguments: $ => seq(
      '<',
      commaSep1($._type),
      '>'
    ),

    pointer_type: $ => seq(
      '*raw',
      optional(choice('const', 'var')),
      $._type
    ),

    reference_type: $ => seq(
      '&',
      optional('mut'),
      $._type
    ),

    array_type: $ => seq(
      '[',
      field('element', $._type),
      optional(seq(';', field('size', $._expression))),
      ']'
    ),

    tuple_type: $ => seq(
      '(',
      commaSep($._type),
      ')'
    ),

    function_type: $ => seq(
      'fn',
      '(',
      commaSep($._type),
      ')',
      optional(seq('->', field('return_type', $._type)))
    ),

    // Statements
    statement: $ => choice(
      $.let_statement,
      $.var_statement,
      $.expression_statement,
      $.return_statement,
      $.defer_statement,
      $.assignment_statement
    ),

    let_statement: $ => seq(
      'let',
      field('pattern', $._pattern),
      optional(seq(':', field('type', $._type))),
      optional(seq('=', field('value', $._expression))),
      optional(';')
    ),

    var_statement: $ => seq(
      'var',
      field('pattern', $._pattern),
      optional(seq(':', field('type', $._type))),
      optional(seq('=', field('value', $._expression))),
      optional(';')
    ),

    assignment_statement: $ => seq(
      field('left', $._expression),
      choice('=', '+=', '-=', '*=', '/=', '%='),
      field('right', $._expression),
      optional(';')
    ),

    expression_statement: $ => seq(
      $._expression,
      optional(';')
    ),

    return_statement: $ => seq(
      'return',
      optional($._expression),
      optional(';')
    ),

    defer_statement: $ => seq(
      'defer',
      choice($.block, $._expression),
      optional(';')
    ),

    block: $ => seq(
      '{',
      repeat($.statement),
      optional($._expression),
      '}'
    ),

    // Expressions
    _expression: $ => choice(
      $._literal,
      $.identifier,
      $.path,
      $.unary_expression,
      $.binary_expression,
      $.call_expression,
      $.method_call_expression,
      $.field_expression,
      $.index_expression,
      $.cast_expression,
      $.struct_expression,
      $.array_expression,
      $.tuple_expression,
      $.if_expression,
      $.while_expression,
      $.for_expression,
      $.match_expression,
      $.unsafe_block,
      $.await_expression,
      $.parenthesized_expression,
      $.block
    ),

    parenthesized_expression: $ => seq('(', $._expression, ')'),

    unary_expression: $ => prec(8, seq(
      choice('-', '!', '*', '&'),
      $._expression
    )),

    binary_expression: $ => choice(
      prec.left(1, seq($._expression, '||', $._expression)),
      prec.left(2, seq($._expression, '&&', $._expression)),
      prec.left(3, seq($._expression, choice('==', '!='), $._expression)),
      prec.left(4, seq($._expression, choice('<', '<=', '>', '>='), $._expression)),
      prec.left(5, seq($._expression, choice('+', '-'), $._expression)),
      prec.left(6, seq($._expression, choice('*', '/', '%'), $._expression)),
      prec.left(7, seq($._expression, choice('&', '|', '^', '<<', '>>'), $._expression))
    ),

    cast_expression: $ => prec(9, seq(
      $._expression,
      'as',
      $._type
    )),

    call_expression: $ => prec(10, seq(
      field('function', $._expression),
      field('arguments', $.argument_list)
    )),

    method_call_expression: $ => prec(10, seq(
      field('receiver', $._expression),
      '.',
      field('method', $.identifier),
      field('arguments', $.argument_list)
    )),

    field_expression: $ => prec(10, seq(
      field('receiver', $._expression),
      '.',
      field('field', choice($.identifier, /[0-9]+/))
    )),

    index_expression: $ => prec(10, seq(
      field('receiver', $._expression),
      '[',
      field('index', $._expression),
      ']'
    )),

    await_expression: $ => prec(11, seq(
      $._expression,
      '.',
      'await'
    )),

    argument_list: $ => seq(
      '(',
      commaSep($._expression),
      ')'
    ),

    struct_expression: $ => seq(
      field('name', $.path),
      optional($.type_arguments),
      '{',
      commaSep($.field_initializer),
      optional(','),
      '}'
    ),

    field_initializer: $ => seq(
      field('name', $.identifier),
      ':',
      field('value', $._expression)
    ),

    array_expression: $ => seq(
      '[',
      choice(
        commaSep($._expression),
        seq($._expression, ';', $._expression)
      ),
      ']'
    ),

    tuple_expression: $ => seq(
      '(',
      commaSep($._expression),
      ')'
    ),

    if_expression: $ => seq(
      'if',
      field('condition', $._expression),
      field('consequence', $.block),
      optional(seq('else', field('alternative', choice($.if_expression, $.block))))
    ),

    while_expression: $ => seq(
      'while',
      field('condition', $._expression),
      field('body', $.block)
    ),

    for_expression: $ => seq(
      'for',
      field('pattern', $._pattern),
      'in',
      field('iterable', $._expression),
      field('body', $.block)
    ),

    match_expression: $ => seq(
      'match',
      field('value', $._expression),
      '{',
      repeat($.match_arm),
      '}'
    ),

    match_arm: $ => seq(
      field('pattern', $._pattern),
      optional(seq('if', field('guard', $._expression))),
      '=>',
      choice($.block, seq($._expression, optional(',')))
    ),

    unsafe_block: $ => seq(
      'unsafe',
      $.block
    ),

    // Patterns
    _pattern: $ => choice(
      $.wildcard_pattern,
      $.identifier_pattern,
      $.struct_pattern,
      $.enum_pattern,
      $.literal_pattern,
      $.tuple_pattern
    ),

    wildcard_pattern: $ => '_',
    identifier_pattern: $ => seq(optional(choice('var', 'ref')), $.identifier),
    literal_pattern: $ => $._literal,

    struct_pattern: $ => seq(
      $.path,
      '{',
      commaSep($.struct_pattern_field),
      '}'
    ),

    struct_pattern_field: $ => seq(
      field('field', $.identifier),
      optional(seq(':', field('pattern', $._pattern)))
    ),

    enum_pattern: $ => seq(
      $.path,
      optional(seq('(', commaSep($._pattern), ')'))
    ),

    tuple_pattern: $ => seq(
      '(',
      commaSep($._pattern),
      ')'
    ),
  }
});

function commaSep(rule) {
  return optional(commaSep1(rule));
}

function commaSep1(rule) {
  return sep1(rule, ',');
}

function sep1(rule, separator) {
  return seq(rule, repeat(seq(separator, rule)));
}
