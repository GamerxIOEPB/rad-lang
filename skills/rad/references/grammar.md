# Rad Grammar & Syntax Specification

This document formalizes the syntactic grammar of the Rad programming language in Extended Backus-Naur Form (EBNF).

## Lexical Grammar

```ebnf
Letter          = "A" ... "Z" | "a" ... "z" | "_" ;
Digit           = "0" ... "9" ;
HexDigit        = Digit | "a" ... "f" | "A" ... "F" ;
Identifier      = Letter , { Letter | Digit } ;

IntegerLiteral  = [ "-" ] , Digit , { Digit } , [ IntSuffix ] ;
IntSuffix       = "i8" | "i16" | "i32" | "i64" | "u8" | "u16" | "u32" | "u64" | "usize" | "isize" ;

FloatLiteral    = [ "-" ] , Digit , { Digit } , "." , Digit , { Digit } , [ FloatSuffix ] ;
FloatSuffix     = "f32" | "f64" ;

StringLiteral   = '"' , { StringChar | EscapeSeq } , '"' ;
EscapeSeq       = '\n' | '\t' | '\r' | '\"' | '\\' | '\0' ;
CharLiteral     = "'" , ( CharContent | EscapeSeq ) , "'" ;
```

## Syntactic Grammar

```ebnf
Program         = { TopLevelItem } , EOF ;

TopLevelItem    = [ "pub" ] , ( FunctionDef | StructDef | EnumDef | ConstDef | ImportDecl | ExternBlock ) ;

ImportDecl      = "import" , Identifier , ";" ;

ConstDef        = "const" , Identifier , ":" , Type , "=" , Expression , ";" ;

StructDef       = "struct" , Identifier , "{" , { StructField } , "}" ;
StructField     = Identifier , ":" , Type , [ "," ] ;

EnumDef         = "enum" , Identifier , "{" , { EnumVariant } , "}" ;
EnumVariant     = Identifier , [ "(" , TypeList , ")" ] , [ "," ] ;

FunctionDef     = "fn" , Identifier , "(" , [ ParameterList ] , ")" , [ "->" , Type ] , Block ;
ParameterList   = Parameter , { "," , Parameter } ;
Parameter       = [ "var" ] , Identifier , ":" , Type ;

Block           = "{" , { Statement } , "}" ;

Statement       = LetStatement
                | VarStatement
                | AssignStatement
                | IfStatement
                | WhileStatement
                | LoopStatement
                | ReturnStatement
                | BreakStatement
                | ContinueStatement
                | ExprStatement ;

LetStatement    = "let" , Identifier , [ ":" , Type ] , "=" , Expression , ";" ;
VarStatement    = "var" , Identifier , [ ":" , Type ] , "=" , Expression , ";" ;
AssignStatement = LValue , "=" , Expression , ";" ;
ReturnStatement = "return" , [ Expression ] , ";" ;
BreakStatement  = "break" , ";" ;
ContinueStatement = "continue" , ";" ;
ExprStatement   = Expression , ";" ;

IfStatement     = "if" , Expression , Block , [ "else" , ( IfStatement | Block ) ] ;
WhileStatement  = "while" , Expression , Block ;
LoopStatement   = "loop" , Block ;

LValue          = Identifier , { "." , Identifier | "[" , Expression , "]" } ;
```
