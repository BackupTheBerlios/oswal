%{
# include <stdio.h>
# include <string.h>
# include <stdlib.h>
# include "cfg_data.h"
# include <limits.h>
# define MAX_HEADERS 0x100
# define PATH_MAX 1024

struct module_def *current = NULL;
int foo = PATH_MAX;
char *headers[ MAX_HEADERS ], path[ PATH_MAX ];
int n_headers = 0;

extern struct module_def *cfg_modules;
extern char *cfg_template, *cfg_module_template;
extern int cfg_n_modules;

void new_module_def( char *description );

# define YYSTYPE char *

%}

%start cfg_file
%token TEMPLATE MODULE_TEMPLATE LOCATION MODULE HEADER STRING EQUALS
%token OB CB

%%

cfg_file: 
	template
	module_template
	modules

template:
	TEMPLATE OB LOCATION EQUALS STRING CB
	{
		if( realpath( $5, path ) == NULL )
			cfg_file_error(
			"Template path could not be resolved." );
		/* FIXME: we should also check whether it is readable */
		cfg_template = strdup( path );
	}

module_template:
	MODULE_TEMPLATE OB LOCATION EQUALS STRING CB
	{
		if( realpath( $5, path ) == NULL )
			cfg_file_error( 
			"Module template path could not be resolved." );
		/* FIXME: we should also check whether it is readable */
		cfg_module_template = strdup( path );
		cfg_n_modules = 0;
	}

modules:
	| modules module
	{
		cfg_n_modules++;
	}

module:
	MODULE STRING OB module_defs CB
	{
		new_module_def( $2 );
	}

module_defs:
	| module_defs module_def

module_def:
	LOCATION EQUALS STRING
	{
		if( realpath( $3, path ) == NULL )
			cfg_file_error( "Module not found." );
	}
	| HEADER EQUALS STRING
	{
		if( n_headers < MAX_HEADERS )
			headers[ n_headers++ ] = strdup( $3 );
	}

%%

void new_module_def( char *description )
{
	struct module_def *d = ( struct module_def * )malloc( sizeof(
		struct module_def ) );
	int i, s;
	char *h, *g;
	if( cfg_modules == NULL )
		current = cfg_modules = d;
	else
	{
		current -> next = d;
		current = d;
	}
	d -> next = NULL;
	d -> description = strdup( description );
	d -> path = strdup( path );
	for( i = 0, s = 0; i < n_headers; i++ )
		s += strlen( headers[ i ] );
	h = ( char * )malloc( s + n_headers );
	for( i = 0, g = h; i < n_headers; i++ )
	{
		if( i > 0 )
			*( g - 1 ) = '\n';
		s = strlen( headers[ i ] );
		strncpy( g, headers[ i ], s );
		free( headers[ i ] );
		g += s;
	}
	d -> headers = h;
}

int cfg_file_error( char *msg ) /* FIXME: XHTMLise */
{
	fprintf( stderr, "An error occured while parsing the "
		"configuration file: %s\n", msg );
	exit( 1 );
}

