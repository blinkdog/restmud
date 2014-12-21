# TODO
[X] Allow Session headers to also provide req.auth
[X] Test Sequelize where: field: gt: Sequelize.NOW in SessionTestDB
[X] Allow cRud of account via GET /account/:id
[ ] Add RESTful links to account on GET /account/:id
[ ] Add more fields to Account model: e-mail address
[ ] Create crUD of account relation
[ ] Add new GET /account/insecure route for accounts that need password change
[ ] Clean up the session object provided in the POST /session response
[ ] Allow deleting expired sessions via DELETE /session
[ ] Create restmud-robot to drive some requests (i.e.: regular DELETE /session)
[ ] Create forbidBanned middleware to 403 all requests from banned accounts
[ ] Create restmud-telnet bridge to allow telnet logins
[ ] Create status relation and return JSON ~= Mud Server Status Protocol (MSSP)
[ ] Create Character model and relations to Account
[ ] Create CRUD on character relation

## Wish List
[ ] Write complete Session unit tests in SessionTestDB in the test-db suite
