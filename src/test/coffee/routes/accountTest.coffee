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
proxyquire = require("proxyquire").noCallThru()

middle = proxyquire "../../lib/middle",
  "sequelize":
    "NOW": "NOW"

accountRoutes = proxyquire '../../lib/routes/account',
  "underscore": require "underscore"
  "restify": require "restify"
  "sequelize":
    or: ->
  "../../config":
    "baseUri": "http://localhost:8080"
    "pbkdf2":
      "digest": "sha512"
      "iterations": 64
      "keyLength": 8
      "saltLength": 8
  "../middle": middle
  "../auth": require "../../lib/auth"
  "../dbMessage": require "../../lib/dbMessage"

restmud = proxyquire '../../lib/restmud',
  "restify": require "restify"
  "./middle": require "../../lib/middle"
  "./routes/account": accountRoutes
  "./routes/hateoas":
    attach: ->
  "./routes/ping":
    attach: ->
  "./routes/session":
    attach: ->

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
      return false

  describe 'POST /account', ->
    it 'should return 400 Bad Request if no body is present', (done) ->
      request(app)
        .post('/account')
        .expect(400)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 400 Bad Request if the body is not valid JSON', (done) ->
      request(app)
        .post('/account')
        .send('This is not JSON')
        .expect(400)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 409 Conflict if the username is missing', (done) ->
      request(app)
        .post('/account')
        .send({ password: "hunter2" })
        .expect(409)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 409 Conflict if the password is missing', (done) ->
      request(app)
        .post('/account')
        .send({ username: "Hasenpfeffer" })
        .expect(409)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 409 Conflict if the username is too short', (done) ->
      request(app)
        .post('/account')
        .send({ username: "Ur", password: "hunter2" })
        .expect(409)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 409 Conflict if the username is too long', (done) ->
      request(app)
        .post('/account')
        .send({ username: "MacGhilleseatheanaich", password: "hunter2" })
        .expect(409)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 409 Conflict if the username contains non-alpha', (done) ->
      request(app)
        .post('/account')
        .send({ username: "Bob123456", password: "hunter2" })
        .expect(409)
        .end (err, res) ->
          return done err if err
          done()
      return false

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
      return false

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
      return false

  describe 'GET /account/:id', ->
    it 'should return 401 Unauthorized without req.auth', (done) ->
      request(app)
        .get('/account/1')
        .expect(401)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 403 Forbidden with the wrong req.auth', (done) ->
      wrongAccount =
        id: 3
        username: "Luigi"
        digest: "sha512"
        hashBase64: "h4D2ZBoHFBo="
        iterations: 64
        keyLength: 8
        saltBase64: "iXlL9gfYUsI="
      wrongSession =
        id: 16
        uuid: "06ade853-d8d3-466c-98e1-420a24020a73"
        expiresAt: "2014-12-20T20:58:16.615Z"
        AccountId: 3
        updatedAt: "2014-12-20T20:53:16.616Z"
        createdAt: "2014-12-20T20:53:16.616Z"
        getAccount: -> wrongAccount
      app.models =
        Session:
          find: (where) ->
            then: (cb) ->
              cb?(wrongSession)
              return this
            catch: (cb) ->
              return this
      request(app)
        .get('/account/1')
        .set('Session', '06ade853-d8d3-466c-98e1-420a24020a73')
        .expect(403)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 200 OK with the right req.auth', (done) ->
      rightAccount =
        id: 1
        username: "Mario"
        digest: "sha512"
        hashBase64: "yGBOPbBX+J8="
        iterations: 64
        keyLength: 8
        saltBase64: "JI3XbdNVKDw="
      rightSession =
        id: 16
        uuid: "06ade853-d8d3-466c-98e1-420a24020a73"
        expiresAt: "2014-12-20T20:58:16.615Z"
        AccountId: 1
        updatedAt: "2014-12-20T20:53:16.616Z"
        createdAt: "2014-12-20T20:53:16.616Z"
        getAccount: -> rightAccount
      app.models =
        Session:
          find: (where) ->
            then: (cb) ->
              cb?(rightSession)
              return this
            catch: (cb) ->
              return this
      request(app)
        .get('/account/1')
        .set('Session', '06ade853-d8d3-466c-98e1-420a24020a73')
        .expect(200)
        .end (err, res) ->
          return done err if err
          done()
      return false

  describe 'PUT /account/:id', ->
    it 'should return 401 Unauthorized without req.auth', (done) ->
      request(app)
        .put('/account/1')
        .expect(401)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 403 Forbidden with the wrong req.auth', (done) ->
      wrongAccount =
        id: 3
        username: "Luigi"
        digest: "sha512"
        hashBase64: "h4D2ZBoHFBo="
        iterations: 64
        keyLength: 8
        saltBase64: "iXlL9gfYUsI="
      wrongSession =
        id: 16
        uuid: "06ade853-d8d3-466c-98e1-420a24020a73"
        expiresAt: "2014-12-20T20:58:16.615Z"
        AccountId: 3
        updatedAt: "2014-12-20T20:53:16.616Z"
        createdAt: "2014-12-20T20:53:16.616Z"
        getAccount: -> wrongAccount
      app.models =
        Session:
          find: (where) ->
            then: (cb) ->
              cb?(wrongSession)
              return this
            catch: (cb) ->
              return this
      request(app)
        .put('/account/1')
        .set('Session', '06ade853-d8d3-466c-98e1-420a24020a73')
        .expect(403)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 200 OK if updatable fields are specified', (done) ->
      rightAccount =
        id: 1
        username: "Mario"
        digest: "sha512"
        hashBase64: "yGBOPbBX+J8="
        iterations: 64
        keyLength: 8
        saltBase64: "JI3XbdNVKDw="
        updateAttributes: (newFields, pickFields) ->
          for key in newFields
            @[key] = newFields[key]
          return this
        then: (cb) ->
          cb?(this)
          return this
        catch: (cb) ->
          return this
      rightSession =
        id: 16
        uuid: "06ade853-d8d3-466c-98e1-420a24020a73"
        expiresAt: "2014-12-20T20:58:16.615Z"
        AccountId: 1
        updatedAt: "2014-12-20T20:53:16.616Z"
        createdAt: "2014-12-20T20:53:16.616Z"
        getAccount: -> rightAccount
      app.models =
        Session:
          find: (where) ->
            then: (cb) ->
              cb?(rightSession)
              return this
            catch: (cb) ->
              return this
      request(app)
        .put('/account/1')
        .set('Session', '06ade853-d8d3-466c-98e1-420a24020a73')
        .send({
          username: 'Mario',
          password: 'fireflowersforpeach',
          email:    'mario@mushroom.gov' })
        .expect(200)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 200 OK and ignore non-updatable fields', (done) ->
      rightAccount =
        id: 1
        username: "Mario"
        digest: "sha512"
        hashBase64: "yGBOPbBX+J8="
        iterations: 64
        keyLength: 8
        saltBase64: "JI3XbdNVKDw="
        updateAttributes: (newFields, pickFields) ->
          for key in newFields
            @[key] = newFields[key]
          return this
        then: (cb) ->
          cb?(this)
          return this
        catch: (cb) ->
          return this
      rightSession =
        id: 16
        uuid: "06ade853-d8d3-466c-98e1-420a24020a73"
        expiresAt: "2014-12-20T20:58:16.615Z"
        AccountId: 1
        updatedAt: "2014-12-20T20:53:16.616Z"
        createdAt: "2014-12-20T20:53:16.616Z"
        getAccount: -> rightAccount
      app.models =
        Session:
          find: (where) ->
            then: (cb) ->
              cb?(rightSession)
              return this
            catch: (cb) ->
              return this
      request(app)
        .put('/account/1')
        .set('Session', '06ade853-d8d3-466c-98e1-420a24020a73')
        .send({
          id: 42,
          username: 'Sonic',
          digest: "sha512"
          hashBase64: 'Jnh/xKbSs9k=',
          iterations: 128,
          keyLength: 16,
          saltBase64: 'M2mHyylqqLA=',
          banned: true })
        .expect(200)
        .end (err, res) ->
          return done err if err
          res.body.should.have.properties [ 'id', 'username' ]
          res.body.should.not.have.property 'email'
          res.body.id.should.equal 1
          res.body.username.should.equal 'Mario'
          done()
      return false

    it 'should return 409 Conflict on a database error', (done) ->
      rightAccount =
        id: 1
        username: "Mario"
        digest: "sha512"
        hashBase64: "yGBOPbBX+J8="
        iterations: 64
        keyLength: 8
        saltBase64: "JI3XbdNVKDw="
        updateAttributes: (newFields, pickFields) ->
          for key in newFields
            @[key] = newFields[key]
          return this
        then: (cb) ->
          return this
        catch: (cb) ->
          cb?("field 'email' failed validation!")
          return this
      rightSession =
        id: 16
        uuid: "06ade853-d8d3-466c-98e1-420a24020a73"
        expiresAt: "2014-12-20T20:58:16.615Z"
        AccountId: 1
        updatedAt: "2014-12-20T20:53:16.616Z"
        createdAt: "2014-12-20T20:53:16.616Z"
        getAccount: -> rightAccount
      app.models =
        Session:
          find: (where) ->
            then: (cb) ->
              cb?(rightSession)
              return this
            catch: (cb) ->
              return this
      request(app)
        .put('/account/1')
        .set('Session', '06ade853-d8d3-466c-98e1-420a24020a73')
        .send({
          password: 'fireflowersforpeach'
          email: 'invalid.email.address' })
        .expect(409)
        .end (err, res) ->
          return done err if err
          done()
      return false

  describe 'DELETE /account/:id', ->
    it 'should return 401 Unauthorized without req.auth', (done) ->
      request(app)
        .delete('/account/1')
        .expect(401)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 403 Forbidden with the wrong req.auth', (done) ->
      wrongAccount =
        id: 3
        username: "Luigi"
        digest: "sha512"
        hashBase64: "h4D2ZBoHFBo="
        iterations: 64
        keyLength: 8
        saltBase64: "iXlL9gfYUsI="
      wrongSession =
        id: 16
        uuid: "06ade853-d8d3-466c-98e1-420a24020a73"
        expiresAt: "2014-12-20T20:58:16.615Z"
        AccountId: 3
        updatedAt: "2014-12-20T20:53:16.616Z"
        createdAt: "2014-12-20T20:53:16.616Z"
        getAccount: -> wrongAccount
      app.models =
        Session:
          find: (where) ->
            then: (cb) ->
              cb?(wrongSession)
              return this
            catch: (cb) ->
              return this
      request(app)
        .delete('/account/1')
        .set('Session', '06ade853-d8d3-466c-98e1-420a24020a73')
        .expect(403)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 200 OK if deleted', (done) ->
      rightAccount =
        id: 1
        username: "Mario"
        digest: "sha512"
        hashBase64: "yGBOPbBX+J8="
        iterations: 64
        keyLength: 8
        saltBase64: "JI3XbdNVKDw="
        destroy: ->
          then: (cb) ->
            cb?()
            return this
          catch: (cb) ->
            return this
      rightSession =
        id: 16
        uuid: "06ade853-d8d3-466c-98e1-420a24020a73"
        expiresAt: "2014-12-20T20:58:16.615Z"
        AccountId: 1
        updatedAt: "2014-12-20T20:53:16.616Z"
        createdAt: "2014-12-20T20:53:16.616Z"
        getAccount: -> rightAccount
      app.models =
        Session:
          find: (where) ->
            then: (cb) ->
              cb?(rightSession)
              return this
            catch: (cb) ->
              return this
      request(app)
        .delete('/account/1')
        .set('Session', '06ade853-d8d3-466c-98e1-420a24020a73')
        .expect(200)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 409 Conflict on a database error', (done) ->
      rightAccount =
        id: 1
        username: "Mario"
        digest: "sha512"
        hashBase64: "yGBOPbBX+J8="
        iterations: 64
        keyLength: 8
        saltBase64: "JI3XbdNVKDw="
        destroy: ->
          then: (cb) ->
            return this
          catch: (cb) ->
            # https://www.youtube.com/watch?v=xwfioD-ING8
            cb?("The jerk store called and they're running out of you!")
            return this
      rightSession =
        id: 16
        uuid: "06ade853-d8d3-466c-98e1-420a24020a73"
        expiresAt: "2014-12-20T20:58:16.615Z"
        AccountId: 1
        updatedAt: "2014-12-20T20:53:16.616Z"
        createdAt: "2014-12-20T20:53:16.616Z"
        getAccount: -> rightAccount
      app.models =
        Session:
          find: (where) ->
            then: (cb) ->
              cb?(rightSession)
              return this
            catch: (cb) ->
              return this
      request(app)
        .delete('/account/1')
        .set('Session', '06ade853-d8d3-466c-98e1-420a24020a73')
        .expect(409)
        .end (err, res) ->
          return done err if err
          done()
      return false

  describe 'GET /account/insecure', ->
    it 'should return 401 Unauthorized without req.auth', (done) ->
      request(app)
        .get('/account/insecure')
        .expect(401)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 403 Forbidden with the wrong req.auth', (done) ->
      wrongAccount =
        id: 3
        username: "Luigi"
        digest: "sha512"
        hashBase64: "h4D2ZBoHFBo="
        iterations: 64
        keyLength: 8
        saltBase64: "iXlL9gfYUsI="
        admin: false
      wrongSession =
        id: 16
        uuid: "06ade853-d8d3-466c-98e1-420a24020a73"
        expiresAt: "2014-12-20T20:58:16.615Z"
        AccountId: 3
        updatedAt: "2014-12-20T20:53:16.616Z"
        createdAt: "2014-12-20T20:53:16.616Z"
        getAccount: -> wrongAccount
      app.models =
        Session:
          find: (where) ->
            then: (cb) ->
              cb?(wrongSession)
              return this
            catch: (cb) ->
              return this
      request(app)
        .get('/account/insecure')
        .set('Session', '06ade853-d8d3-466c-98e1-420a24020a73')
        .expect(403)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 200 OK with the right req.auth', (done) ->
      rightAccount =
        id: 1
        username: "Mario"
        digest: "sha512"
        hashBase64: "yGBOPbBX+J8="
        iterations: 64
        keyLength: 8
        saltBase64: "JI3XbdNVKDw="
        admin: true
      rightSession =
        id: 16
        uuid: "06ade853-d8d3-466c-98e1-420a24020a73"
        expiresAt: "2014-12-20T20:58:16.615Z"
        AccountId: 1
        updatedAt: "2014-12-20T20:53:16.616Z"
        createdAt: "2014-12-20T20:53:16.616Z"
        getAccount: -> rightAccount
      app.models =
        Account:
          findAll: (where) ->
            then: (cb) ->
              cb?([{},{},{}])
              return this
            catch: (cb) ->
              return this
        Session:
          find: (where) ->
            then: (cb) ->
              cb?(rightSession)
              return this
            catch: (cb) ->
              return this
      request(app)
        .get('/account/insecure')
        .set('Session', '06ade853-d8d3-466c-98e1-420a24020a73')
        .expect(200)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 500 if the database throws', (done) ->
      rightAccount =
        id: 1
        username: "Mario"
        digest: "sha512"
        hashBase64: "yGBOPbBX+J8="
        iterations: 64
        keyLength: 8
        saltBase64: "JI3XbdNVKDw="
        admin: true
      rightSession =
        id: 16
        uuid: "06ade853-d8d3-466c-98e1-420a24020a73"
        expiresAt: "2014-12-20T20:58:16.615Z"
        AccountId: 1
        updatedAt: "2014-12-20T20:53:16.616Z"
        createdAt: "2014-12-20T20:53:16.616Z"
        getAccount: -> rightAccount
      app.models =
        Account:
          findAll: (where) ->
            then: (cb) ->
              return this
            catch: (cb) ->
              cb?("Ut oh...")
              return this
        Session:
          find: (where) ->
            then: (cb) ->
              cb?(rightSession)
              return this
            catch: (cb) ->
              return this
      request(app)
        .get('/account/insecure')
        .set('Session', '06ade853-d8d3-466c-98e1-420a24020a73')
        .expect(500)
        .end (err, res) ->
          return done err if err
          done()
      return false

#----------------------------------------------------------------------------
# end of accountTest.coffee
