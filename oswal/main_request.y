%{
/* Copyright 2005 Ewgenij Starostin
 *
 * This file is part of OSWAL.
 * 
 * OSWAL is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * OSWAL is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with OSWAL; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 */

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

