%{
# include <stdio.h>
# include "cfg_data.h"

void push( struct node *x );
void pop();

struct file
{
	struct node *n;
	int c;
	FILE *in;
	YY_BUFFER_STATE s;
};

extern struct node *root_template;
extern int cfg_n_modules;
struct file **files = NULL;
int n = -1, files_size = 0, c_buf = 0;
extern char **buf; /* modules' outputs */
%}

%option noyywrap

%%

[^%]	write( 1, yytext, 1 );
"%"[^%cd] write( 1, yytext, 2 );
"%%"	{
		write( 1, "%", 1 );
	}
"%d"	{
		write( 1, files[ n ] -> n -> description, 
			strlen( files[ n ] -> n -> description ) );
	}
"%c"	{
		if( files[ n ] -> n -> n_children )
		{
			files[ n ] -> c = 1;
			push( files[ n ] -> n -> children[ 0 ] );
		}
	}
<<EOF>>	{
		if( files[ n ] -> n == root_template )
		{
			free( files );
			yyterminate();
		}
		pop();
		if( files[ n ] -> c < files[ n ] -> n -> n_children )
			push( files[ n ] -> n -> children[ files[ n ]
				-> c++ ] );
	}
%%

void push( struct node *x )
{
	if( !x )
	{ /* module */
		if( c_buf < cfg_n_modules )
		{
			write( 1, buf[ c_buf ], 
				strlen( buf[ c_buf ] ) );
			c_buf++;
		}
		return;
	}
	/* else: template */
	if( n + 1 == files_size )
		files = realloc( files, ( files_size = ( files_size
			<< 2 ) + 1 ) * sizeof( struct file * ) );
	n++;
	files[ n ] = ( struct file * )malloc( sizeof( struct file ) );
	files[ n ] -> n = x;
	files[ n ] -> c = files[ n ] -> n -> n_children;
	yyin = ( files[ n ] -> in = fopen( files[ n ] -> n -> location,
		"r" ) );
	yy_switch_to_buffer( files[ n ] -> s = 
		yy_create_buffer( yyin, YY_BUF_SIZE ) );
}

void pop()
{
	free( files[ n ] );
	yy_switch_to_buffer( files[ --n ] -> s );
	yyin = files[ n ] -> in;
}

/*int yywrap()
{
	return 0;
}*/

void template_init()
{
	push( root_template );
}

