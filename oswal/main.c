# include <sys/time.h>
# include <string.h>
# include <stdio.h>
# include "cfg_data.h"

# define BUF_SIZE 0x10000

char *cfg_file = "oswal.conf";
extern FILE *cfg_file_in;
struct module_def *cfg_modules;
char *cfg_loader_path = "loader", *cfg_template, *cfg_module_template;
int cfg_n_modules, *p_index;
char **buf, **ptr;
fd_set fds;

void read_whats_there( int fd );
void get_pointers( int fd, char **p_buf, char ***p_ptr );
void compose_xhtml();

int main( int argc, char *argv[] )
{
	int nfds, done_reading = 0, i;
	cfg_file_in = fopen( cfg_file, "r" );
	cfg_file_parse();
	p_index = ( int * )malloc( sizeof( int ) * cfg_n_modules );
	buf = ( char ** )malloc( sizeof( char * ) * cfg_n_modules );
	ptr = ( char ** )malloc( sizeof( char * ) * cfg_n_modules );
	FD_ZERO( &fds );
	for( nfds = -1, i = 0; cfg_modules; i++ )
	{
		int fork_success = 0, to_loader[ 2 ], from_loader[ 2 ];
		/* do stuff */
		if( pipe( to_loader ) )
			puts( "argh" );
		if( pipe( from_loader ) )
			puts( "argh" );
		switch( fork() )
		{
		case -1:	/* error (oops ...) */
			break;
		case 0:		/* child */
			close( 0 );
			dup( to_loader[ 0 ] );
			close( 1 );
			dup( from_loader[ 1 ] );
			execl( cfg_loader_path, cfg_loader_path, NULL );
			puts( "oops" ); /* FIXME */
			exit( 1 );
		default:	/* parent */
			fork_success++;
		}
		if( !fork_success )
			continue;
		write( to_loader[ 1 ], cfg_modules -> path,
			strlen( cfg_modules -> path ) );
		write( to_loader[ 1 ], "\n", 1 );
		write( to_loader[ 1 ], cfg_modules -> headers,
			strlen( cfg_modules -> headers ) );
		write( to_loader[ 1 ], "\n", 1 );
		close( to_loader[ 0 ] );
		close( to_loader[ 1 ] );
		close( from_loader[ 1 ] );
		FD_SET( from_loader[ 0 ], &fds );
		cfg_modules = cfg_modules -> next;
		p_index[ i ] = from_loader[ 0 ];
		buf[ i ] = ( char * )malloc( sizeof( char ) * BUF_SIZE
			);
		ptr[ i ] = buf[ i ];
		if( nfds < from_loader[ 0 ] )
			nfds = from_loader[ 0 ];
	}
	nfds++;
	while( !done_reading )
	{
		fd_set set = fds, zero;
		struct timeval timeout = { tv_sec: 10, tv_usec: 0 };
		int n, i, j;
		FD_ZERO( &zero );
		for( i = 0; i < sizeof( fd_set ); i++ )
			if( ( ( char * )&set )[ i ] !=
				( ( char * )&zero )[ i ] )
				break;
		if( i == sizeof( fd_set ) )
			break;
		switch( ( n =
			select( nfds, &set, NULL, NULL, &timeout ) ) )
		{
		case -1:	/* error */
			/* TODO */
		case 0:		/* timeout */
			done_reading++;
			break;
		default:	/* work :( */
			for( i = 0, j = 0; i < n; j++ )
				if( FD_ISSET( j, &set ) )
				{
					read_whats_there( j );
					i++;
				}
		}
	}
	/*puts( "HTTP/1.1 200 OK\n" );*/
	compose_xhtml();
	return 0;
}

void read_whats_there( int fd )
{
	char *b, **p, *q;
	get_pointers( fd, &b, &p );
	q = *p;
	*p += read( fd, *p, BUF_SIZE - 1 - ( *p - b ) ); /* FIXME */
	if( *p == q )
		FD_CLR( fd, &fds );
	**p = '\0';
}

void get_pointers( int fd, char **p_buf, char ***p_ptr )
{
	int i;
	for( i = 0; i < cfg_n_modules; i++ )
		if( p_index[ i ] == fd )
			break;
	if( i == cfg_n_modules )
	{
		*p_buf = NULL;
		*p_ptr = NULL;
	}
	else
	{
		*p_buf = buf[ i ];
		*p_ptr = &ptr[ i ];
	}
}

void compose_xhtml() /* FIXME (everything) */
{
	int i;
	FILE *t, *m_t;
	char the_whole_thing[ 0x100000 ], template[ 0x10000 ],
		template2[ 0x10000 ], tmp[ 0x20000 ], *tmp2 = NULL;
	t = fopen( cfg_template, "r" );
	m_t = fopen( cfg_module_template, "r" );
	i = fread( template, 1, sizeof( template ) - 1, t );
	template[ i ] = '\0';
	fclose( t );
	i = fread( template2, 1, sizeof( template2 ) - 1, m_t );
	template2[ i ] = '\0';
	fclose( m_t );
	for( i = 0, strcpy( the_whole_thing, template ); i <
		cfg_n_modules; i++ )
	{
		if( tmp2 )
			free( tmp2 );
		tmp2 = strdup( the_whole_thing );
		snprintf( tmp, sizeof( tmp ), template2, buf[ i ],
			"%s" );
		snprintf( the_whole_thing, sizeof( the_whole_thing ),
			tmp2, tmp );
	}
	if( !tmp2 )
		strcpy( the_whole_thing, template ); /* FIXME */
	else
	{
		free( tmp2 );
		tmp2 = strdup( the_whole_thing );
		snprintf( the_whole_thing, sizeof( the_whole_thing ),
			tmp2, "" );
	}
	puts( the_whole_thing );
}

