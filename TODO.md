# TODO
[X] Clean up the session object provided in the POST /session response
[X] Allow deleting expired sessions via DELETE /session
[ ] Create restmud-robot to drive some requests (i.e.: regular DELETE /session)
[ ] Add admin field to Account model
[ ] Add new GET /account/insecure route for accounts that need password change
[ ] Create restmud-telnet bridge to allow telnet logins
[ ] Create status relation and return JSON ~= Mud Server Status Protocol (MSSP)
[ ] Update restmud-telnet bridge to provide MSSP
[ ] Create Character model and relations to Account
[ ] Create CRUD on character relation
[ ] Add character links to account on GET /account/:id

## Wish List
[ ] Write complete Session unit tests in SessionTestDB in the test-db suite
