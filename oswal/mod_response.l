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
# include <stdlib.h> /* for atoi */
# include <sys/time.h>
# include <string.h>
# include "mod_response.tab.h"
# include "def_read.h"

extern int from_module;

# define YY_INPUT(buf,result,max_size) \
	result = defensive_read( from_module, buf, max_size );
%}

%option noyywrap

DIGIT [0-9]

%x non_xml xml

%%
^STATUS[ ][0-9]+$ {
		mod_response_lval.integer =
			atoi( mod_response_text + sizeof( "STATUS" ) );
		BEGIN non_xml;
		return STATUS;
	}
<non_xml>[\n\r]+	;
<non_xml>[^\n\r]	BEGIN xml; yymore();
<xml>[\x01-\xff]* {
		mod_response_lval.string = strdup( mod_response_text );
		return XML;
	}

%%

