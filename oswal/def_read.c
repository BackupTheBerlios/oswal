# include <unistd.h>
# include <sys/time.h>
# include <string.h>

int defensive_read( int fd, char *buf, int max_size )
{
	fd_set s;
	struct timeval t = { tv_sec: 1, tv_usec: 500000 };
	FD_ZERO( &s );
	FD_SET( fd, &s );
	if( select( fd + 1, &s, NULL, NULL, &t ) > 0 )
	{
		int i = read( fd, buf, max_size );
		return i < 0 ? 0 : i;
	}
	else
		return 0;
}

