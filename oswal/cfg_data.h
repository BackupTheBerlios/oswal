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

