# include <sys/time.h>
# include <string.h>
# include <stdio.h>
# include "cfg_data.h"

/* initial size of a buffer for the output of one module */
# define INIT_BUF_SIZE 0x400

char *cfg_file = "oswal.conf"; /* any good way to make it variable? */
extern FILE *cfg_file_in;
struct module_def *cfg_modules; /* list of modules */
char *cfg_loader_path = "loader", /* FIXME: should be variable */
     *cfg_template, *cfg_module_template;
int cfg_n_modules, /* number of modules */
    *p_index, *buf_sizes; /* lists ... */
char **buf, **ptr;	  /* ... for storing data about the buffers */
fd_set fds; /* initial list of file descriptors to read from */

void read_whats_there( int fd );
void get_pointers( int fd, int **buf_size, char ***p_buf, char ***p_ptr );
void compose_xhtml();

int main( int argc, char *argv[] )
{
	int nfds, done_reading = 0, i;
	cfg_file_in = fopen( cfg_file, "r" );
	cfg_file_parse();
	p_index = ( int * )malloc( sizeof( int ) * cfg_n_modules );
	buf_sizes = ( int * )malloc( sizeof( int ) * cfg_n_modules );
	buf = ( char ** )malloc( sizeof( char * ) * cfg_n_modules );
	ptr = ( char ** )malloc( sizeof( char * ) * cfg_n_modules );
	FD_ZERO( &fds );
	for( nfds = -1, i = 0; cfg_modules; i++ )
	{
		int fork_success = 0, to_loader[ 2 ], from_loader[ 2 ];
		/* create the pipes */
		if( pipe( to_loader ) )
			puts( "argh" ); /* FIXME: error handling */
		if( pipe( from_loader ) )
			puts( "argh" ); /* (see above) */
		/* fork */
		switch( fork() )
		{
		case -1:	/* error (oops ... (FIXME: message)) */
			break;
		case 0:		/* child */
			/* redirect input */
			close( 0 );
			dup( to_loader[ 0 ] );
			/* redirect output */
			close( 1 );
			dup( from_loader[ 1 ] );
			/* start the loader */
			execl( cfg_loader_path, cfg_loader_path, NULL );
			/* if we get here, something has certainly gone
			 * wrong
			 */
			puts( "oops" ); /* FIXME */
			exit( 1 );
		default:	/* parent */
			/* set success flag
			 * (otherwise, case -1 has occured, in which
			 * case, this module is skipped)
			 */
			fork_success++;
		}
		if( !fork_success )
			/* this one didn't work, try next one */
			continue;
		/* pass data to loader */
		/* 1. the module's path */
		write( to_loader[ 1 ], cfg_modules -> path,
			strlen( cfg_modules -> path ) );
		write( to_loader[ 1 ], "\n", 1 );
		/* 2. the headers */
		write( to_loader[ 1 ], cfg_modules -> headers,
			strlen( cfg_modules -> headers ) );
		/* 3. terminating newline (or is this better done while
		 * reading the headers? can it go wrong?)
		 */
		write( to_loader[ 1 ], "\n", 1 );
		/* close the pipes, except for that fd from which we'll
		 * read the loader output ...
		 */
		close( to_loader[ 0 ] );
		close( to_loader[ 1 ] );
		close( from_loader[ 1 ] );
		/* ... and add that one to our set */
		FD_SET( from_loader[ 0 ], &fds );
		/* list stuff */
		cfg_modules = cfg_modules -> next;
		p_index[ i ] = from_loader[ 0 ];
		buf_sizes[ i ] = INIT_BUF_SIZE;
		buf[ i ] = ( char * )malloc( sizeof( char ) *
			INIT_BUF_SIZE );
		ptr[ i ] = buf[ i ];
		/* update highest-numbered fd if necessary */
		if( nfds < from_loader[ 0 ] )
			nfds = from_loader[ 0 ];
	}
	nfds++; /* select(3) semantics */
	while( !done_reading )
	{
		fd_set set = fds, zero;
		/* the timeout applies to reading from *any* loader
		 * instance; thus for a timeout of m seconds and n
		 * instances, the total runtime of the entire loop is in
		 * O(m*n), which can be rather bad for practical
		 * purposes -> possible TODO: global timeout
		 * (otherwise, any well-designed httpd will terminate
		 * this thing the hard way)
		 */
		struct timeval timeout = { tv_sec: 10, tv_usec: 0 };
			/* TODO: set to a lower value */
		int n, i, j;
		FD_ZERO( &zero );
		/* very clumsy way to check if there is anything in the
		 * current set at all (which there isn't e. g. if the
		 * current configuration does not specify any modules)
		 *
		 * this is also a way of avoiding a timeout after all
		 * descriptors have been closed
		 */
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
	compose_xhtml();
	return 0;
}

/**
 * reasonably safe way of reading output from an fd
 * @param fd where to read from
 */
void read_whats_there( int fd )
{
	char **b, **p, *q; /* buffer start and current position */
	int *buf_size; /* size of this buffer */
	get_pointers( fd, &buf_size, &b, &p );
	/* enlarge buffer if necessary */
	if( *p - *b == *buf_size )
	{
		q = *b; /* save old buffer start */
		*b = realloc( *b, *buf_size = *buf_size << 1 );
		if( *b == NULL )
		{
			/* FIXME: error handling */
		}
		*p = *b + ( *p - q );
	}
	q = *p; /* save current position */
	*p += read( fd, *p, *buf_size - 1 - ( *p - *b ) ); /* FIXME */
	if( *p == q )
		FD_CLR( fd, &fds );
	**p = '\0';
}

/**
 * get various values from arrays by fd
 * @param fd the file descriptor for which to fetch values
 * @param buf_size buffer size
 * @param p_buf start of buffer
 * @param p_ptr position in buffer
 */
void get_pointers( int fd, int **buf_size, char ***p_buf, char ***p_ptr)
{
	int i;
	for( i = 0; i < cfg_n_modules; i++ )
		if( p_index[ i ] == fd )
			break;
	if( i == cfg_n_modules )
	{
		*buf_size = NULL;
		*p_buf = *p_ptr = NULL;
	}
	else
	{
		*buf_size = &buf_sizes[ i ];
		*p_buf = &buf[ i ];
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

