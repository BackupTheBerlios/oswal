CC = gcc -Wall -ansi -g
%.o : %.l %.y
	flex -o$*.lex.c -P$*_ $*.l
	bison -d -p $*_ -b $* $*.y
	$(CC) -c -o $@ $*.lex.c $*.tab.c
foo.xyzzy: main_request.o mod_response.o cfg_file.o
%.o : %.c
	$(CC) -c -o $@ $<
main.o: main.c
loader.o: loader.c
main: main.o cfg_file.o
loader: loader.o main_request.o mod_response.o def_read.o
all: main loader

