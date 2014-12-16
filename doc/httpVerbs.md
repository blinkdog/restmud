# httpVerbs.md
From [Wikipedia](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods)

## GET
Requests a representation of the specified resource. Requests using GET should
only retrieve data and should have no other effect. (This is also true of some
other HTTP methods.)[1] The W3C has published guidance principles on this
distinction, saying, "Web application design should be informed by the above
principles, but also by the relevant limitations."[13] See safe methods below.

## HEAD
Asks for the response identical to the one that would correspond to a GET
request, but without the response body. This is useful for retrieving
meta-information written in response headers, without having to transport
the entire content.

## POST 
Requests that the server accept the entity enclosed in the request as a new
subordinate of the web resource identified by the URI. The data POSTed might
be, for example, an annotation for existing resources; a message for a
bulletin board, newsgroup, mailing list, or comment thread; a block of data
that is the result of submitting a web form to a data-handling process; or
an item to add to a database.[14]

## PUT
Requests that the enclosed entity be stored under the supplied URI. If the
URI refers to an already existing resource, it is modified; if the URI does
not point to an existing resource, then the server can create the resource
with that URI.[15]

## DELETE
Deletes the specified resource.

## TRACE
Echoes back the received request so that a client can see what (if any)
changes or additions have been made by intermediate servers.

## OPTIONS
Returns the HTTP methods that the server supports for the specified URL. This
can be used to check the functionality of a web server by requesting '*'
instead of a specific resource.

## CONNECT
Converts the request connection to a transparent TCP/IP tunnel, usually to
facilitate SSL-encrypted communication (HTTPS) through an unencrypted HTTP
proxy.[16][17] See HTTP CONNECT Tunneling.

## PATCH
Applies partial modifications to a resource.[18]

HTTP servers are required to implement at least the GET and HEAD methods[19]
and, whenever possible, also the OPTIONS method.[citation needed]
