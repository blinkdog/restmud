# api.md
Documentation of the REST API for restmud

## /
HATEOAS entry point for the restmud application

### GET /
Obtain HATEOAS links for the application:

    {
      "links": [
        {
          "rel": "ping",
          "href": "http://restmud.example.com/ping"
        },
        {
          "rel": "self",
          "href": "http://restmud.example.com/"
        }
      ]
    }

### HEAD /
Not exactly sure why I implemented this one. It's there if you want it.

## /ping
Ping the service, to see if it is responding to requests.

### HEAD /ping
HEAD is the only supported method, because there is no body text.
