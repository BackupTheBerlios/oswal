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

# include <string.h>
# define YYSTYPE char *
# include "cfg_file.tab.h"
%}

%option noyywrap caseless
%x string comment

%%

(#|\/\/).*$	; /* single-line comments */
"/*"	{
		BEGIN comment;
	}
<comment>"*/" {
		BEGIN INITIAL;
	}
<comment>[^*]*		;
<comment>\*$		;
<comment>\*/[^/]	;
\"	{
		BEGIN string;
	}
<string>\" {
		BEGIN INITIAL;
	}
<string>[^"]* {
		cfg_file_lval = strdup( cfg_file_text );
		return STRING;
	}
template { /* keywords */
		return TEMPLATE;
	}
document {
		return DOCUMENT;
	}
fragment {
		return FRAGMENT;
	}
module[-_]template {
		return MODULE_TEMPLATE;
	}
location {
		return LOCATION;
	}
module {
		return MODULE;
	}
header {
		return HEADER;
	}
= {
		return EQUALS;
	}
"{" {
		return OB;
	}
"}" {
		return CB;
	}
[ \n\t\r]*	; /* eat whitespace */

%%

