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

# ifndef __MSGS_H
# define __MSGS_H

/* a very basic XHTML document for testing whether a code fragment is
 * really XHTML
 * to fill in:
 * 1. encoding
 * 2. code
 */
# define XHTML_FRAG_TEST_DOC \
	"<?xml version=\"1.0\" encoding=\"%s\"?>" \
	"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" " \
	"\"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">" \
	"<html xmlns=\"http://www.w3.org/1999/xhtml\">" \
	"<head><title /></head><body><div>%s</div></body></html>"
# define XHTML_FRAG_TEST_DOC_LENGTH \
	( sizeof( XHTML_FRAG_TEST_DOC ) - 4 )

# endif /* __MSGS_H */

