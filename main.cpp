#include <iostream>
#include <set>
#include <vector>
#include "parser.hpp"
#include "commandParser.h"

extern int yylex();
extern Node *root; 

int main(int argc, char** argv) {
  CommandParser command(argc, argv);

  // parse command-line options
  std::string bg_color = command.getCmdOption("-bg");
  std::string node_color = command.getCmdOption("-color");
  std::string edge_color = command.getCmdOption("-edges");
  std::string orientation = command.getCmdOption("-orientation");
  if (orientation.empty()) {
    // set default orientation to 'vertical'
    orientation = "vertical";
  }

  // fetch symbols from parser with yylex
  if (!yylex()) {

    // beginning of graphviz spec
    std::cout << "digraph G {" << std::endl;

    // graph styling
    std::cout << "  graph [center=1";
    if (orientation != "vertical") {
      std::cout << " rankdir=LR";
    }
    if (!bg_color.empty()) {
      std::cout << " bgcolor=\"" << bg_color << "\"";
    }
    std::cout << "]" << std::endl;

    // node styling
    std::cout << "  node [fontname=\"Courier\"";
    if (!node_color.empty()) {
      std::cout << " color=\"" << node_color << "\" style=\"filled\"";
    }
    std::cout << "]" << std::endl;

    // edge styling
    if (!edge_color.empty()) {
      std::cout << "  edge [color=\"" << edge_color << "\"]";
    }

    // print nodes recursively
    print_node(root, "n0", 0);
    
    // end of graphviz spec
    std::cout << "}" << std::endl;
  }
}
