#include <iostream>
#include <set>
#include <vector>
#include "parser.hpp"

extern int yylex();
extern Node *root; 

int main() {
  // fetch symbols from parser with yylex
  if (!yylex()) {
    // print beginning of graphviz spec
    std::cout << "digraph G {" << std::endl;
    // print nodes recursively
    print_node(root, "n0", 0);
    // print end of graphviz spec
    std::cout << "}" << std::endl;
  }
}
