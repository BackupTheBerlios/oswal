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

