# accountTest.coffee
# Copyright 2014 Patrick Meade.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#----------------------------------------------------------------------------

_ = require 'underscore'
should = require 'should'
request = require 'supertest'

restmud = require '../../lib/restmud'
{BASE64} = require '../../lib/validate'

app = restmud.create()

describe '/account', ->
  describe 'GET /account', ->
    it 'should return 401 Unauthorized', (done) ->
      request(app)
        .get('/account')
        .expect(401)
        .end (err, res) ->
          return done err if err
          done()

  describe 'POST /account', ->
    it 'should return 400 Bad Request if no body is present', (done) ->
      request(app)
        .post('/account')
        .expect(400)
        .end (err, res) ->
          return done err if err
          done()

    it 'should return 400 Bad Request if the body is not valid JSON', (done) ->
      request(app)
        .post('/account')
        .send('This is not JSON')
        .expect(400)
        .end (err, res) ->
          return done err if err
          done()

    it 'should return 409 Conflict if the username is missing', (done) ->
      request(app)
        .post('/account')
        .send({ password: "hunter2" })
        .expect(409)
        .end (err, res) ->
          return done err if err
          done()

    it 'should return 409 Conflict if the password is missing', (done) ->
      request(app)
        .post('/account')
        .send({ username: "Hasenpfeffer" })
        .expect(409)
        .end (err, res) ->
          return done err if err
          done()

    it 'should return 409 Conflict if the username is too short', (done) ->
      request(app)
        .post('/account')
        .send({ username: "Ur", password: "hunter2" })
        .expect(409)
        .end (err, res) ->
          return done err if err
          done()

    it 'should return 409 Conflict if the username is too long', (done) ->
      request(app)
        .post('/account')
        .send({ username: "MacGhilleseatheanaich", password: "hunter2" })
        .expect(409)
        .end (err, res) ->
          return done err if err
          done()

    it 'should return 409 Conflict if the username contains non-alpha', (done) ->
      request(app)
        .post('/account')
        .send({ username: "Bob123456", password: "hunter2" })
        .expect(409)
        .end (err, res) ->
          return done err if err
          done()

    it 'should return 201 Created after success', (done) ->
      mario =
        id: 1
        username: "Mario"
        password: "ilovepeach"
        updatedAt: "2014-12-18T03:07:27.302Z"
        createdAt: "2014-12-18T03:07:27.302Z"
      app.models =
        Account:
          create: (json) ->
            then: (cb) -> cb?(mario)
            catch: (cb) ->
      request(app)
        .post('/account')
        .send({ username: "Mario", password: "ilovepeach" })
        .expect(201)
        .end (err, res) ->
          return done err if err
          res.should.have.property 'body'
          res.body.should.be.ok
          res.body.should.have.properties ['rel', 'href']
          res.body.rel.should.equal 'account'
          done()

    it 'should return 409 Conflict on a database error', (done) ->
      dbErrorJson = '''
{
  "name": "SequelizeUniqueConstraintError",
  "parent": {
    "name": "error",
    "length": 167,
    "severity": "ERROR",
    "code": "23505",
    "detail": "Key (username)=(Mario) already exists.",
    "file": "nbtinsert.c",
    "line": "397",
    "routine": "_bt_check_unique",
    "sql": "INSERT INTO"
  },
  "sql": "INSERT INTO",
  "fields": [
    "username"
  ],
  "value": [
    "Mario"
  ],
  "index": null
}
'''
      app.models =
        Account:
          create: (json) ->
            then: (cb) -> return this
            catch: (cb) -> cb?(JSON.parse dbErrorJson)
      request(app)
        .post('/account')
        .send({ username: "Mario", password: "ilovepeach" })
        .expect(409)
        .end (err, res) ->
          return done err if err
          res.should.have.property 'text'
          res.text.should.be.ok
          done()

  describe 'GET /account/:id', ->
    it 'should return 401 Unauthorized', (done) ->
      request(app)
        .get('/account/1')
        .expect(401)
        .end (err, res) ->
          return done err if err
          done()

#----------------------------------------------------------------------------
# end of accountTest.coffee
