%{
# include <stdio.h>
# include <stdlib.h>
# include <string.h>

# define MOD_OK 0
# define MOD_FAILURE 1

int status; /* did module return OK status? */
char *response_str; /* what we actually send back */

int erroneous_xml( char *data );
char *make_err_response( int s );

%}

%union
{
	char *string;
	int integer;
}

%start response

%token <integer> STATUS
%token <string> XML

%%

response:
STATUS
XML
	{
		if( $1 == MOD_OK && !erroneous_xml( $2 ) )
			response_str = $2;
		else
			response_str = make_err_response( $1 );
		puts( response_str );
	}

%%

int erroneous_xml( char *data ) /* FIXME: implement */
{
	/*return strchr( data, '<' ) != data;*/
	return 0;
}

char *make_err_response( int s )
{
	if( s == MOD_OK )
		return "<p>XML is fucked up.</p>";
	else
		return "<p>Module status indicates error.</p>";
}

int mod_response_error( char *msg )
{
	printf( __FILE__ ":%d: %s", __LINE__, msg );
	exit( 1 );
}

