# TODO
[X] Add RESTful links to account on GET /account/:id
[X] Add more fields to Account model: e-mail address, banned, etc.
[X] Create forbidBanned middleware to 403 all requests from banned accounts
[X] Create crUd of account relation
[X] Create cruD of account relation
[ ] Add new GET /account/insecure route for accounts that need password change
[ ] Clean up the session object provided in the POST /session response
[ ] Allow deleting expired sessions via DELETE /session
[ ] Create restmud-robot to drive some requests (i.e.: regular DELETE /session)
[ ] Create restmud-telnet bridge to allow telnet logins
[ ] Create status relation and return JSON ~= Mud Server Status Protocol (MSSP)
[ ] Update restmud-telnet bridge to provide MSSP
[ ] Create Character model and relations to Account
[ ] Create CRUD on character relation
[ ] Add character links to account on GET /account/:id

## Wish List
[ ] Write complete Session unit tests in SessionTestDB in the test-db suite
