CC = gcc -Wall -ansi -g 
CFLAGS = `xml2-config --cflags`
LDFLAGS = `xml2-config --libs`
CCF = $(CC) $(CFLAGS)
all: main loader
%.lex.o : %.l %.y
	flex -o$*.lex.c -P$*_ $*.l
	bison -d -p $*_ -b $* $*.y
	$(CCF) -c -o $*.lex.o $*.lex.c
	$(CCF) -c -o $*.tab.o $*.tab.c
%.lex.o : %.l
	flex -o$*.lex.c -P$*_ $*.l
	$(CCF) -c -o $*.lex.o $*.lex.c
%.tab.o : %.l %.y
	flex -o$*.lex.c -P$*_ $*.l
	bison -d -p $*_ -b $* $*.y
	$(CCF) -c -o $*.lex.o $*.lex.c
	$(CCF) -c -o $*.tab.o $*.tab.c
%.o : %.c
	$(CCF) -c -o $@ $<
main: main.o cfg_file.lex.o cfg_file.tab.o template.lex.o cgi.o
loader: loader.o main_request.lex.o main_request.tab.o \
	mod_response.lex.o mod_response.tab.o def_read.o
clean:
	-rm -f *.o *.tab.c *.tab.h *.lex.c main loader

