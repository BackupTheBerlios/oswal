# ifndef __CFG_FILE_H
# define __CFG_FILE_H

struct module_def
{
	struct module_def *next;
	char *description;
	char *path;
	char *headers;
};

struct node
{
	struct node *parent;
	struct node **children;
	int n_children;
	char *description;
	char *location;
};

# endif /* __CFG_FILE_H */

