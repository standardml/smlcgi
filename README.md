SML/CGI is a *completely* dumb CGI library.  CGI libraries have existed for SML forever, so this is really just an up-to-date version of the same thing.  It attempts to replicate some of the functionality of smlweb (http://smlweb.sf.net) without relying on SML/NJ integration.

Installation
============

Running `make` in the top-level source directory will build the template compiler.  No building of the library is necessary.  However, the following things are required:

* CMlib > 1.0.0
* MLton or SML/NJ

The easiest way to obtain SML/CGI is to use Smackage:

    smackage get smlcgi
    smackage make smlcgi
    smackage make smlcgi install

This will install all the necessary dependencies.

Usage
=====
Using the library is as simple as including cgi.mlb in your application.

A minimal application might be:

    val _ = startResponse "text/html"
    val _ = print "Hello, world!\n"

Template Compiler
=================

SML/CGI also includes the world's most naive template compiler.  A template is a plain text file with inline SML code delimited by `<% ... %>` blocks.  Anything inside such a block must be a valid top-level SML statement.  If you just wish to echo a string, you can use the syntax `<%% foobar %>`, which will wrap `foobar` in an appropriate call to `print`.

The `CGI` structure is open by default in templates.

A minimal template might be:

    <% val _ = startResponse "text/html" %>
    Hello, <%% "world!" %>

A template `hello.mlt` is compiled to two files: `hello.cgi.sml` and `hello.cgi.mlb`, and finally to a CGI-ready binary with the two commands:

    smlcgic hello.mlt
    mlton hello.cgi.mlb

If `hello.cgi` is placed in an appropriate CGI-enabled directory, then it should be accessible via the web.

Query strings
=============

The CGI structure provides the function: `getParam : string -> string` for retrieving query string values, e.g.:

    val _ = print (getParam "greeting" ^ ", world\n")

No effort is made to sanitise incoming data, and URIs escape sequences are decoded with little checking.  Beware.

