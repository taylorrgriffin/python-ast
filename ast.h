#include <algorithm>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <vector>

struct Node {
  std::string val;
  std::string label;
  std::string category;
  std::vector<Node*> children;
};

void print_node(Node *n, std::string, int);
Node *create_node(std::string label);
Node *create_node(std::string label, std::string val);