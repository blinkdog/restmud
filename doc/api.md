# api.md
Documentation of the REST API for restmud

## Headers

### Authorization
restmud uses [HTTP Basic authentication](https://en.wikipedia.org/wiki/Basic_access_authentication)
to accept client credentials on requests that require them.

While is it possible for clients to provide credentials every request, this is
not recommended. Verifying provided credentials can be a slow operation, and
this will show up as additional latency in every request. Clients interested
in minimal latency (i.e.: no lag) will want to use the `Session` header.

### Session
restmud uses a custom Session header to re-accept previously verified
credentials. This is always a [UUID](http://en.wikipedia.org/wiki/UUID).
An example might look like:

    Session: d9cb9f00-15e1-4cb7-972d-9251a4bbf275

The UUID is obtained from the `session` relation. The URI of the session
relation can be found at the HATEOAS root /. Use a POST request that includes
an Authorization header to create a session resource. The session resource
will provide the UUID and indicate how long it will be considered valid.

Providing a Session header with a request is the recommended way of
authenticating most requests. Verifying sessions is much faster than verifying
credentials, and lowers the latency of those requests. (i.e.: no lag)

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
CRUD operations on accounts. Well, C for now; RUD later (after
authentication is implemented).

### GET account
This provides a list of all the accounts on the system. For security reasons,
this is restricted to those who have authenticated with the administrator role.

### POST account
Create a new account on the system. JSON of the following form should be
provided in the POST body:

    {
      "username": "mario",
      "password": "ilovepeach"
    }

On success, the response body will be an account link containing the URI of
the newly created account resource:

    {
      "rel": "account",
      "href": "http://restmud.example.com/account/42"
    }

### GET account/:id
Obtain the data for an account resource. Proper authorization is required to
view the data of the account (i.e.: a valid session for that account)

    GET /account/1

Might return 200 OK:

    {
      "id": 1,
      "username": "Mario"
    }

### PUT account/:id
Update the data in the account resource. Proper authorization is required to
update the data of the account (i.e.: a valid session for that account)

The new information should be supplied as an object in JSON format in the
body of the request. The fields that can be updated are:

    {
      "email": "valid.email.address@example.com",
      "password": "fireflowersforpeach"
    }

### DELETE account/:id
Delete the account resource. Proper authorization is required to
delete the account (i.e.: a valid session for that account)

Will return 200 OK upon a successful DELETE. Further requests will
be bounced with a 401 Unauthorized.

Accounts that have been banned will 403 Forbidden, even on a DELETE
request. This is to prevent someone from deleting and then recreating
their account in order to evade the ban.

### GET account/insecure
Requires admin authorization. Obtain the collection of insecure accounts.
Insecure accounts are those defined as having a pbkdf2 iteration count or
key-length less than the currently configured values.

Because we do not store the user's password, we cannot update their account
in case we decide to use longer keys or more iterations. This route
allows an administrator to pull a list of those accounts that are "behind
the security curve". Then perhaps send them an e-mail, asking them to
please update their password and thus gain the higher security.

Response is a JSON array of account resources that are considered insecure.

## Relation: ping
Ping the service, to see if it is responding to requests.

### HEAD ping
HEAD is the only supported method, because there is no body text.

## Relation: status
Will be used to provide status information about the server.
Not implemented yet.

## Relation: session
Used to authenticate and establish client sessions.

### POST session
Create a new session on the system. The POST request should contain an
Authorization header with account credentials. 

If the provided credentials are valid, the response body will be a
session resource. Right now, that usually looks like this:

    {
      "id": 16,
      "uuid": "06ade853-d8d3-466c-98e1-420a24020a73",
      "expiresAt": "2014-12-20T20:58:16.615Z",
      "links": [
        {
          "rel": "self",
          "href": "http://restmud.example.com/session/16"
        },
        {
          "rel": "account",
          "href": "http://restmud.example.com/account/1"
        }
      ]
    }

The important field is `uuid`, as it will need to be provided in a
`Session` header, in order to mark the request as belonging to an
authenticated session.

### DELETE session
Remove expired sessions from the database. Oddly, this route is not
authenticated. Expired session resources are no longer useful, and
this method is simply taking out the trash.

## Relation: source
The URI used to provide the Corresponding Source as required by Section 13
of the GNU Affero General Public License. This URI may provide the
Corresponding Source itself, or it may point to a repository (i.e.: a
GitHub URI) where the Corresponding Source can be obtained at no charge.
