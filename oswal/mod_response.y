%{
# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <libxml/xmlmemory.h>
# include <libxml/parser.h>
# include "msgs.h"

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

/**
 * check whether a code fragment is valid
 * @param data the fragment
 * @return 0 iff the fragment is valid
 */
int erroneous_xml( char *data )
{
	int data_length = strlen( data ), 
		encoding_length = sizeof( "UTF-8" ) - 1;
	char document[ XHTML_FRAG_TEST_DOC_LENGTH + data_length +
		encoding_length ];
	xmlDocPtr xml_doc;
	/* libxml prints error messages to stderr; the correct way to
	 * prevent that seems to involve too much work, hence this:
	 */
	close( 2 );
	snprintf( document, sizeof( document ), XHTML_FRAG_TEST_DOC,
		"UTF-8", data );
	xml_doc = xmlParseMemory( document, sizeof( document ) );
	if( !xml_doc )
		return 1;
	xmlFreeDoc( xml_doc );
	return 0;
	/* eventually:
	return !xmlValidateDocument( xml_val_ctxt, xml_doc ); */
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
	printf( "<pre>" __FILE__ ":%d: %s</pre>", __LINE__, msg );
		/* FIXME: ... */
	exit( 1 );
}

