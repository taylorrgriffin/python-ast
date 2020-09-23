#include <iostream>
#include <algorithm>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <vector>

#include "ast.h"

// create node from statement, assign it a label
Node *create_node(std::string label)
{
  Node *result = new Node;
  result->label = label;
  return result;
}

// create node from statement, assign it a label and value
Node *create_node(std::string label, std::string val)
{
    Node *result = new Node;
    result->label = label;
    result->val = val;
    return result;
}

// recursively print graphviz spec for a node and all it's children
void print_node(Node *n, std::string prefix, int lineno) {
  // handle block nodes
  if (n != NULL && (*n).label == "Block") {
    // print block label
    std::cout << "  " << prefix << " [label=\"Block\"];" << std::endl;
    // process all children of block
    for (Node *child: (*n).children) {
      // print transition
      std::cout << "  " << prefix << " -> ";
      // set next prefix
      std::string next_prefix = prefix + "_" + std::to_string(lineno);
      // print child node
      print_node(child, next_prefix, lineno);
      lineno++;
    }
  }

  // handle all non-block nodes
  if (n != NULL && !(*n).category.empty()) {
    std::string cat = (*n).category;
    // Terminals
    if (cat == "Identifier") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [shape=box,label=\"Identifier: " << (*n).label << "\"];" << std::endl;
    }
    else if (cat == "Float") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [shape=box,label=\"Float: " << std::noshowpoint << std::stof((*n).label) << "\"];" << std::endl;
    }
    else if (cat == "Integer") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [shape=box,label=\"Integer: " << (*n).label << "\"];" << std::endl;
    }
    else if (cat == "Boolean") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [shape=box,label=\"Boolean: " << (*n).label << "\"];" << std::endl;
    }
    // Break statement
    else if (cat == "Break") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [label=\"Break\"];" << std::endl;
    }
    // If statement
    else if (cat == "If") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [label=\"If\"];" << std::endl;
      int num = 0;
      for (Node *child: (*n).children) {
        // process condition first
        if (num == 0) {
          // print transition
          std::cout << "  " << prefix << " -> ";
          print_node(child, prefix + "_cond", lineno);
          num++;
        }
        // then process block
        else if (num == 1) {
          // print transition
          std::cout << "  " << prefix << " -> " << prefix << "_if;" << std::endl;
          print_node(child, prefix + "_if", 0);
          num++;
        }
        else {
          if (child != NULL) {
            std::cout << "  " << prefix << " -> " << prefix << "_else;" << std::endl;
            print_node(child, prefix + "_else", 0);
          }
        }
      }
    }
    // While loop
    else if (cat == "While") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [label=\"While\"];" << std::endl;
      int num = 0;
      for (Node *child: (*n).children) {
        // process condition first
        if (num == 0) {
          // print transition
          std::cout << "  " << prefix << " -> ";
          print_node(child, prefix + "_cond", lineno);
          num++;
        }
        // then process block
        else if (num == 1) {
          // print transition
          std::cout << "  " << prefix << " -> " << prefix << "_while;" << std::endl;
          print_node(child, prefix + "_while", 0);
          num++;
        }
      }
    }
    // Expression statement
    else if (cat == "Expression") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [label=\"" << (*n).label << "\"];" << std::endl;
      int num = 0;
      for (Node *child: (*n).children) {
        // print transition
        std::cout << "  " << prefix << " -> ";
        // process lhs first
        if (num == 0) {
          print_node(child, prefix + "_lhs", lineno);
          num++;
        }
        // then process rhs
        else {
          print_node(child, prefix + "_rhs", lineno);
        }
      }
    }
    // Assignment statement
    else if (cat == "Assignment") {
      // print prefix
      std::cout << prefix << ";" << std::endl;
      // print label
      std::cout << "  " << prefix << " [label=\"Assignment\"];" << std::endl;
      int num = 0;
      for (Node *child: (*n).children) {
        // print transition
        std::cout << "  " << prefix << " -> ";
        // process lhs first
        if (num == 0) {
          print_node(child, prefix + "_lhs", lineno);
          num++;
        }
        // then process rhs
        else {
          print_node(child, prefix + "_rhs", lineno);
        }
      }
    }
  }
}