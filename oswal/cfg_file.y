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

# include <stdio.h>
# include <string.h>
# include <stdlib.h>
# include "cfg_data.h"
# include <limits.h>
# define MAX_HEADERS 0x100
# define PATH_MAX 1024

struct module_def *current_module = NULL;
int foo = PATH_MAX;
char *headers[ MAX_HEADERS ], path[ PATH_MAX ];
int n_headers = 0;
struct node root = 
{
	.parent = NULL,
	.children = NULL,
	.n_children = 0,
	.description = "",
	.location = NULL
};
struct node *root_template = &root, *current = NULL;

extern struct module_def *cfg_modules;
extern char *cfg_template, *cfg_module_template;
extern int cfg_n_modules;

void new_module_def( char *description );

# define YYSTYPE char *

%}

%start cfg_file
%token TEMPLATE MODULE_TEMPLATE LOCATION MODULE HEADER STRING EQUALS
%token OB CB DOCUMENT FRAGMENT

%%

cfg_file:
	document

document:
	DOCUMENT OB template 
	{
		root.location = strdup( $3 );
		current = &root;
		cfg_n_modules = 0;
	}
	fragments CB

fragments:
	| fragments fragment

fragment:
	FRAGMENT STRING OB template
	{
		struct node m =
		{
			.parent = current,
			.children = NULL,
			.n_children = 0,
			.description = strdup( $2 ),
			.location = strdup( $4 )
		}, *n;
		current -> children = realloc( current -> children,
			++( current -> n_children ) * sizeof(
			struct node * ) );
		n = ( struct node * )malloc( sizeof( struct node ) );
		*n = m;
		current -> children[ current -> n_children - 1 ] = n;
		current = n;
	}
	fragments CB
	{
		current = current -> parent;
	}
	| module
	{
		current -> children = realloc( current -> children,
			++( current -> n_children ) * sizeof(
			struct node * ) );
		current -> children[ current -> n_children - 1 ] = NULL;
		cfg_n_modules++;
	}

module:
	{
		n_headers = 0;
	}
	MODULE STRING OB location headers CB
	{
		new_module_def( $2 );
	}

headers:
	| headers header

template:
	TEMPLATE EQUALS STRING
	{
		$$ = $3;
	}

location:
	LOCATION EQUALS STRING
	{
		if( realpath( $3, path ) == NULL )
			cfg_file_error( "Module not found." );
	}

header:
	HEADER STRING
	{
		if( n_headers < MAX_HEADERS )
			headers[ n_headers++ ] = strdup( $2 );
	}

%%

void new_module_def( char *description )
{
	struct module_def *d = ( struct module_def * )malloc( sizeof(
		struct module_def ) );
	int i, s;
	char *h, *g;
	if( cfg_modules == NULL )
		current_module = cfg_modules = d;
	else
	{
		current_module -> next = d;
		current_module = d;
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

