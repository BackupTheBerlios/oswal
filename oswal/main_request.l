%{
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

