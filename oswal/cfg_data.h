# ifndef __CFG_FILE_H
# define __CFG_FILE_H

struct module_def
{
	struct module_def *next;
	char *description;
	char *path;
	char *headers;
};

# endif /* __CFG_FILE_H */

