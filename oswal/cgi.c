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

# include <string.h>

char *get_content_type( char *accept )
{
	if( 	/* check the relevant content types 
		 * this is not the proper way to do it, but it should
		 * work anyway
		 */
			strstr( accept, "application/xhtml+xml" ) ||
			strstr( accept, "application/xml" ) ||
			strstr( accept, "text/xml" ) ||
			strstr( accept, "application/*" ) ||
			strstr( accept, "*/*" )
	  )
		return "application/xhtml+xml";
	else
		return "text/html";
}

