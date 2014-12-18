# api.md
Documentation of the REST API for restmud

## Relation: HATEOAS (/)
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

## Relation: account
CRUD operation on an account. Not implemented yet.

## Relation: accounts
CRUD operations on all accounts. Well, C for now; RUD later (after
authentication is implemented).

### GET accounts
This provides a list of all the accounts on the system. For security reasons,
this is restricted to those who have authenticated with the administrator role.

### POST accounts
Create a new account on the system. JSON of the following form should be
provided in the POST body:

    {
      "username": "mario"
      "password": "ilovepeach"
    }

On success, the response body will be an account link containing the URI of
the newly created account resource:

    {
      "rel": "account",
      "href": "http://restmud.example.com/account/42"
    }

## Relation: ping
Ping the service, to see if it is responding to requests.

### HEAD ping
HEAD is the only supported method, because there is no body text.

## Relation: session
Eventually used to provide session tokens to clients. Not implemented yet.

## Relation: source
The URI used to provide the Corresponding Source as required by Section 13
of the GNU Affero General Public License. This URI may provide the
Corresponding Source itself, or it may point to a repository (i.e.: a
GitHub URI) where the Corresponding Source can be obtained at no charge.
