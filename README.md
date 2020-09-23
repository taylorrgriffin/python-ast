# Python to Abstract Syntax Tree

This project accepts code written with simple python syntax and creates a graphviz specification representing the source program. The produced graphviz spec can be used to generate an visualization of the abstract syntax tree.

The program first utilizes a flex scanner to ensure the input consists of entirely valid symbols. If the symbols are all valid, a bison parser ensures that the input follows all syntatical rules. Lastly, if the first two conditions are met, the graphviz specification is assembled and printed to stdout.

Please note, this program is not compatible will all python syntax, merely a subset that we will refer to as "Simple Python Syntax". Note that this limitation is by design. This program is intended to be used in a greater python compiler, and a different component in the compiler would be responsible for reducing more advanced python syntax into simple syntax. For more, see the section below on Syntax.

Check it out in action at [taylorgriffin.io](http://taylorgriffin.io/projects/python-ast)!

## Requirements

* [g++](https://gcc.gnu.org/)
* [Bison](http://www.gnu.org/software/bison/bison.html) (v3.7.2 or later)
* [flex](https://github.com/westes/flex) (v2.5.35 or later)
* [GraphViz](https://graphviz.org/download/) (for AST visualization)

## Usage

Build program from source
```
make
```

Generate GraphViz spec from python file `example.py`
```
./parse < example.py > example.gv
```

Generate AST visualization from Graphviz spec `example.gv`
```
dot -Tpng -oexample.png example.gv
```

## Syntax

The following syntatic structures are supported:

* Assignments
* Arithmetic
* If statements
* While loops
* Break statements

## Testing

The program can be tested by executing the following command:
```
make test
```

If the tests fail, the process will exit with an error. If you run the command and see no errors, then the program is working as expected.

## Acknowledgments

This project was originally developed as an assignment for the Compilers course at Oregon State University (CS480). Poritions of the code were provided by the instructor, [Rob Hess](https://github.com/robwhess).