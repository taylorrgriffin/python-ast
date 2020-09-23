all: parse

parser.cpp parser.hpp: parser.y
	bison -d -o parser.cpp parser.y

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l

parse: main.cpp parser.cpp scanner.cpp ast.cpp
	g++ main.cpp parser.cpp scanner.cpp ast.cpp -o parse -std=c++11

clean:
	rm -f parse scanner.cpp parser.cpp parser.hpp *.gv

test: parse test1 test2 test3

test1:
	./parse < ./tests/example_input/p1.py > p1.gv
	diff ./tests/example_output/p1.gv p1.gv
	rm p1.gv

test2:
	./parse < ./tests/example_input/p2.py > p2.gv
	diff ./tests/example_output/p2.gv p2.gv
	rm p2.gv

test3:
	./parse < ./tests/example_input/p3.py > p3.gv
	diff ./tests/example_output/p3.gv p3.gv
	rm p3.gv
