%{
#include <iostream>
#include <vector>
// #include <set>

// #include "ast.h"
#include "parser.hpp"

extern int yylex();
void yyerror(YYLTYPE* loc, const char* err);
std::string translate_boolean_str(std::string* boolean_str);

/*
 * Here, target_program is a string that will hold the target program being
 * generated, and symbols is a simple symbol table.
 */
Node *root = create_node("Block");
std::string* target_program;
// std::set<std::string> symbols;
%}

/* Enable location tracking. */
%locations
%code requires{
#include "ast.h"
}

/*
 * All program constructs will be represented as strings, specifically as
 * their corresponding C/C++ translation.
 */
// %define api.value.type { std::string* }

%union {
  std::string* str;
  Node* node;
  std::vector<Node*> *collection;
}

/*
 * Because the lexer can generate more than one token at a time (i.e. DEDENT
 * tokens), we'll use a push parser.
 */
%define api.pure full
%define api.push-pull push
%define parse.error verbose

/*
 * These are all of the terminals in our grammar, i.e. the syntactic
 * categories that can be recognized by the lexer.
 */
%token<str> IDENTIFIER FLOAT INTEGER BOOLEAN

%token<node> INDENT DEDENT NEWLINE
%token<node> AND BREAK DEF ELIF ELSE FOR IF NOT OR RETURN WHILE
%token<node> ASSIGN PLUS MINUS TIMES DIVIDEDBY
%token<node> EQ NEQ GT GTE LT LTE
%token<node> LPAREN RPAREN COMMA COLON

%type<collection> statements
%type<node> statement expression negated_expression primary_expression assign_statement
%type<node> if_statement condition else_block elif_blocks block
%type<node> while_statement break_statement

/*
 * Here, we're defining the precedence of the operators.  The ones that appear
 * later have higher precedence.  All of the operators are left-associative
 * except the "not" operator, which is right-associative.
 */
%left OR
%left AND
%left PLUS MINUS
%left TIMES DIVIDEDBY
%left EQ NEQ GT GTE LT LTE
%right NOT

/* This is our goal/start symbol. */
%start program

%%

/*
 * Each of the CFG rules below recognizes a particular program construct in
 * Python and creates a new string containing the corresponding C/C++
 * translation.  Since we're allocating strings as we go, we also free them
 * as we no longer need them.  Specifically, each string is freed after it is
 * combined into a larger string.
 */

/*
 * This is the goal/start symbol.  Once all of the statements in the entire
 * source program are translated, this symbol receives the string containing
 * all of the translations and assigns it to the global target_program, so it
 * can be used outside the parser.
 */
program
  : statements { root->children = *$1; }
  ;

/*
 * The `statements` symbol represents a set of contiguous statements.  It is
 * used to represent the entire program in the rule above and to represent a
 * block of statements in the `block` rule below.  The second production here
 * simply concatenates each new statement's translation into a running
 * translation for the current set of statements.
 */
statements
  : statement {
     $$ = new std::vector<Node*>;
     $$->push_back($1);
    }
  | statements statement {
      $1->push_back($2);
      $$ = $1;
    }
  ;

/*
 * This is a high-level symbol used to represent an individual statement.
 */
statement
  : assign_statement { $$ = $1; };
  | if_statement { $$ = $1; }
  | while_statement { $$ = $1; }
  | break_statement { $$ = $1; }
  ;

/*
 * A primary expression is a "building block" of an expression.
 */
primary_expression
  : IDENTIFIER {
      Node *n = create_node(*$1);
      n->category = "Identifier";
      $$ = n;
    }
  | FLOAT {
      Node *n = create_node(*$1);
      n->category = "Float";
      $$ = n;
    }
  | INTEGER {
      Node *n = create_node(*$1);
      n->category = "Integer";
      $$ = n;
    }
  | BOOLEAN {
      Node *n = create_node(translate_boolean_str($1));
      n->category = "Boolean";
      $$ = n;
    }
  | LPAREN expression RPAREN { $$ = $2; }
  ;

/*
 * Symbol representing a boolean "not" operation.
 */
negated_expression: NOT primary_expression { };

/*
 * Symbol representing algebraic expressions.  For most forms of algebraic
 * expression, we generate a translated string that simply concatenates the
 * C++ translations of the operands with the C++ translation of the operator.
 */
expression
  : primary_expression { $$ = $1; }
  | negated_expression { $$ = $1; }
  | expression PLUS expression {
      Node *n = create_node("PLUS");
      n->category = "Expression";
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | expression MINUS expression {
      Node *n = create_node("MINUS");
      n->category = "Expression";
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | expression TIMES expression {
      Node *n = create_node("TIMES");
      n->category = "Expression";
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
  }
  | expression DIVIDEDBY expression {
      Node *n = create_node("DIVIDEDBY");
      n->category = "Expression";
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
  }
  | expression EQ expression {
      Node *n = create_node("EQ");
      n->category = "Expression";
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | expression NEQ expression {
      Node *n = create_node("NEQ");
      n->category = "Expression";
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | expression GT expression {
      Node *n = create_node("GT");
      n->category = "Expression";
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | expression GTE expression {
      Node *n = create_node("GTE");
      n->category = "Expression";
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | expression LT expression {
      Node *n = create_node("LT");
      n->category = "Expression";
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | expression LTE expression {
      Node *n = create_node("LTE");
      n->category = "Expression";
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  ;

/*
 * This symbol represents an assignment statement.  For each assignment
 * statement, we first make sure to insert the LHS identifier into the symbol
 * table, since it is potentially a new symbol.  Then, we generate a C++
 * translation for the whole assignment by combining the C++ translations of
 * the LHS and the RHS along with an equals sign and a semi-colon, to make sure
 * we have proper C++ punctuation.
 */
assign_statement
  : IDENTIFIER ASSIGN expression NEWLINE {
      Node *n = create_node("Assignment");
      Node *id = create_node(*$1);
      id->category = "Identifier";
      n->children.push_back(id);
      n->children.push_back($3);
      n->category = "Assignment";
      $$ = n;
    }
  ;

/*
 * A `block` represents the collection of statements associated with an
 * if, elif, else, or while statement.  The C++ translation for a block of
 * statements is wrapped in curly braces ({}) instead of INDENT and DEDENT.
 */
block
  : INDENT statements DEDENT {
    Node *n = create_node("Block");
    n->children = *$2;
    $$ = n;
    }
  ;

/*
 * This symbol represents a boolean condition, used with an if, elif, or while.
 * The C++ translation of a condition concatenates the C++ translations of its
 * operators with one of the C++ boolean operators && or ||.
 */
condition
  : expression { $$ = $1; }
  | condition AND condition {
      Node *n = create_node("AND");
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | condition OR condition {
      Node *n = create_node("OR");
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  ;

/*
 * This symbol represents an entire if statement, including optional elif
 * blocks and an optional else block.  The C++ translations for the blocks
 * are simply combined here into one larger translation, and the if condition
 * is wrapped in parentheses, as is required in C++.
 */
if_statement
  : IF condition COLON NEWLINE block elif_blocks else_block {
    Node *n = create_node("If");
    n->category = "If";
    n->children.push_back($2);
    n->children.push_back($5);
    n->children.push_back($6);
    n->children.push_back($7);
    $$ = n;
  }
  ;

/*
 * This symbol represents zero or more elif blocks to be attached to an if
 * statement.  When a new elif block is recognized, the Pythonic "elif" is
 * translated to the C++ "else if", and the condition is wrapped in parens.
 */
elif_blocks
  : %empty {
    $$ = NULL;
  }
  | elif_blocks ELIF condition COLON NEWLINE block {
    Node *n = create_node("Block");
    n->children.push_back($3);
    n->children.push_back($6);
  }
  ;

/*
 * This symbol represents an if statement's optional else block.
 */
else_block
  : %empty {
    $$ = NULL;
    }
  | ELSE COLON NEWLINE block {
    $$ = $4;
    };


/*
 * This symbol represents a while statement.  The C++ translation wraps the
 * while condition in parentheses.
 */
while_statement
  : WHILE condition COLON NEWLINE block {
      Node *n = create_node("While");
      n->category = "While";
      n->children.push_back($2);
      n->children.push_back($5);
      $$ = n;
    }
  ;

/*
 * This symbol represents a break statement.  The C++ translation simply adds
 * a semicolon.
 */
break_statement
  : BREAK NEWLINE {
    Node *n = create_node("Break");
    n->category = "Break";
    $$ = n;
    }
  ;

%%

/*
 * This is our simple error reporting function.  It prints the line number
 * and text of each error.
 */
void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error (line " << loc->first_line << "): " << err << std::endl;
}

/*
 * This function translates a Python boolean value into the corresponding
 * C++ boolean value.
 */
std::string translate_boolean_str(std::string* boolean_str) {
  if (*boolean_str == "True") {
    // return new std::string("1");
    return "1";
  } else {
    // return new std::string("0");
    return "0";
  }
}
