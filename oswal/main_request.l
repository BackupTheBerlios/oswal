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
# define YYSTYPE char *
# include "main_request.tab.h"
# include "def_read.h"

# define YY_INPUT(buf,result,max_size) \
	result = defensive_read( 0, buf, max_size );
%}

%option noyywrap

%%

^(\/[^/\n]+)+$ {
		main_request_lval = strdup( main_request_text );
		return PATH;
	}
^[A-Za-z]+:.*\n {
		main_request_lval = strdup( main_request_text );
		return HEADER;
	}
[\r\n]+			;

%%

