%{
# include <unistd.h>
# include <fcntl.h>
# include <string.h> /* for strlen */
# include <errno.h>
# include <stdio.h>

int to_module, from_module, pid;

# define ERR_MSG "<p>An error occured while querying the module:" \
	"<blockquote>%s</blockquote></p>"
/* a buffer of 256 KiB ought to be enough ... */
# define BUF_SIZE 0x40000

/* tell yacc what we're working on */
# define YYSTYPE char *

%}

%start request

%token PATH HEADER

%%

request:
PATH
	{
		int p1[ 2 ], p2[ 2 ], errfd;
# define load_in ( p1[ 0 ] )
# define mod_out ( p1[ 1 ] )
# define mod_in ( p2[ 0 ] )
# define load_out ( p2[ 1 ] )
		pipe( p1 );
		pipe( p2 );
		to_module = load_out;
		from_module = load_in;
		/* fork */
		switch( ( pid = fork() ) )
		{
		case -1:	/* error */
			main_request_error( strerror( errno ) );
			exit( 1 );
		case 0:		/* child */
			close( 0 );
			dup( mod_in );
			close( 1 );
			dup( mod_out );
			errfd = open( "/dev/null", O_WRONLY );
			close( 2 );
			dup( errfd );
			execl( $1, $1, NULL );
			main_request_error( strerror( errno ) );
			exit( 1 );
		default:	/* parent */
			break;
		}
		close( mod_out );
		close( mod_in );
	}
headers
	{
		close( to_module );
		mod_response_parse();
	}

headers:
|
headers
HEADER
	{
		write( to_module, $2, strlen( $2 ) );
	}

%%

int main_request_error( char *msg )
{
	printf( ERR_MSG, msg );
	exit( 1 );
}

