CC = gcc -Wall -ansi -g
all: main loader
%.lex.o : %.l %.y
	flex -o$*.lex.c -P$*_ $*.l
	bison -d -p $*_ -b $* $*.y
	$(CC) -c -o $*.lex.o $*.lex.c
	$(CC) -c -o $*.tab.o $*.tab.c
%.tab.o : %.l %.y
	flex -o$*.lex.c -P$*_ $*.l
	bison -d -p $*_ -b $* $*.y
	$(CC) -c -o $*.lex.o $*.lex.c
	$(CC) -c -o $*.tab.o $*.tab.c
%.o : %.c
	$(CC) -c -o $@ $<
main: main.o cfg_file.lex.o cfg_file.tab.o
loader: loader.o main_request.lex.o main_request.tab.o \
	mod_response.lex.o mod_response.tab.o def_read.o
clean:
	-rm -f *.o *.tab.c *.tab.h *.lex.c main loader

