%{
# include <stdio.h>
# include <stdlib.h> /* for atoi */
# include <sys/time.h>
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
			atoi( mod_response_text + sizeof( "STATUS " ) -
			1 );
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

