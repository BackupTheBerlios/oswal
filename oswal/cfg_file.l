%{
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

