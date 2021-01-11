#include <iostream>
#include <set>
#include <vector>
#include "parser.hpp"

extern int yylex();
extern Node *root; 

int main(int argc, char** argv) {
  // set default colorscheme and direction
  bool vertical = true;
  bool dark_mode = false;

  // fetch symbols from parser with yylex
  if (!yylex()) {

    // check for --color and --dir commandline options
    if (argc > 2) {
      if (argv[1] == std::string("--color") && argv[2] == std::string("dark")) {
        dark_mode = true;
      }
      else if (argv[1] == std::string("--dir") && argv[2] == std::string("horizontal")) {
        vertical = false;
      }
    }
    if (argc > 4) {
      if (argv[3] == std::string("--color") && argv[4] == std::string("dark")) {
        dark_mode = true;
      }
      else if (argv[3] == std::string("--dir") && argv[4] == std::string("horizontal")) {
        vertical = false;
      }
    }

    // print beginning of graphviz spec
    std::cout << "digraph G {" << std::endl;

    // define graph styling
    std::cout << "  graph [center=1";
    if (!vertical) {
      std::cout << " rankdir=LR";
    }
    if (dark_mode) {
      std::cout << " bgcolor=\"#18191a\"";
    }
    std::cout << "]" << std::endl;

    // define node styling
    std::cout << "  node [fontname=\"Courier\"";
    if (dark_mode) {
      std::cout << " color=\"#FFFFFF\" style=\"filled\"";
    }
    std::cout << "]" << std::endl;

    // define edge styling
    if (dark_mode) {
      std::cout << "  edge [color=\"#FFFFFF\"]";
    }

    // print nodes recursively
    print_node(root, "n0", 0);
    // print end of graphviz spec
    std::cout << "}" << std::endl;
  }
}
