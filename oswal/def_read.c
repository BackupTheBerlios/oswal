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

