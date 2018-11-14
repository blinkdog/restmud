# sessionTest.coffee
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

should = require 'should'
request = require 'supertest'
proxyquire = require("proxyquire").noCallThru()

sessionRoutes = proxyquire '../../lib/routes/session',
  "underscore": require "underscore"
  "sequelize":
    NOW: "NOW"
  "../../config":
    baseUri: "http://not.really.a.uri"
    sessionLength: 9001 # over 9000!!!
  "../middle": require "../../lib/middle"
  "./account":
    PATH: "/account"

restmud = proxyquire '../../lib/restmud',
  "restify": require "restify"
  "./middle": require "../../lib/middle"
  "./routes/account":
    attach: ->
  "./routes/hateoas":
    attach: ->
  "./routes/ping":
    attach: ->
  "./routes/session": sessionRoutes

basicAuth = (username, password) ->
  base64 = new Buffer("#{username}:#{password}").toString 'base64'
  "Basic #{base64}"

app = restmud.create()

describe '/session', ->
  beforeEach ->
    delete app.models

  describe 'HEAD /session', ->
    it 'should return 405', (done) ->
      request(app)
        .head('/session')
        .expect(405)
        .end (err, res) ->
          return done err if err
          done()
      return false

  describe 'GET /session', ->
    it 'should return 405', (done) ->
      request(app)
        .get('/session')
        .expect(405)
        .end (err, res) ->
          return done err if err
          done()
      return false

  describe 'POST /session', ->
    it 'should return 401 if no Authorization header is provided', (done) ->
      request(app)
        .post('/session')
        .expect(401)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 401 if bad credentials are provided', (done) ->
      mario =
        id: 1
        username: "Mario"
        digest: "sha512"
        hashBase64: "yGBOPbBX+J8="
        iterations: 64
        keyLength: 8
        saltBase64: "JI3XbdNVKDw="
      app.models =
        Account:
          find: (where) ->
            return this
          then: (cb) ->
            cb?(mario)
            return this
          catch: (cb) ->
            return this
      request(app)
        .post('/session')
        .set('Authorization', basicAuth("Mario", "bowserrulz"))
        .expect(401)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 201 if good credentials are provided', (done) ->
      mario =
        id: 1
        username: "Mario"
        digest: "sha512"
        hashBase64: "UFdcS+lle6w="
        iterations: 64
        keyLength: 8
        saltBase64: "JI3XbdNVKDw="
      session =
        id: 1
        uuid: "403386a7-1130-427c-b8a5-852918a12c4d"
        expiresAt: Date.now()
      app.models =
        Account:
          find: (where) ->
            return this
          then: (cb) ->
            cb?(mario)
            return this
          catch: (cb) ->
            return this
        Session:
          create: (json) ->
            return this
          then: (cb) ->
            cb?(session)
            return this
          catch: (cb) ->
            return this
      request(app)
        .post('/session')
        .set('Authorization', basicAuth("Mario", "ilovepeach"))
        .expect(201)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 500 if the database throws during Session creation', (done) ->
      mario =
        id: 1
        username: "Mario"
        digest: "sha512"
        hashBase64: "UFdcS+lle6w="
        iterations: 64
        keyLength: 8
        saltBase64: "JI3XbdNVKDw="
      session =
        id: 1
        uuid: "403386a7-1130-427c-b8a5-852918a12c4d"
        expiresAt: Date.now()
      app.models =
        Account:
          find: (where) ->
            return this
          then: (cb) ->
            cb?(mario)
            return this
          catch: (cb) ->
            return this
        Session:
          create: (json) ->
            return this
          then: (cb) ->
            return this
          catch: (cb) ->
            cb?("Exterminate! Exterminate!")
            return this
      request(app)
        .post('/session')
        .set('Authorization', basicAuth("Mario", "ilovepeach"))
        .expect(500)
        .end (err, res) ->
          return done err if err
          done()
      return false

  describe 'PUT /session', ->
    it 'should return 405', (done) ->
      request(app)
        .put('/session')
        .expect(405)
        .end (err, res) ->
          return done err if err
          done()
      return false

  describe 'DELETE /session', ->
    it 'should return 200 OK when deleting expired sessions', (done) ->
      app.models =
        Session:
          destroy: (json) ->
            return this
          then: (cb) ->
            cb?()
            return this
          catch: (cb) ->
            return this
      request(app)
        .delete('/session')
        .expect(200)
        .end (err, res) ->
          return done err if err
          done()
      return false

    it 'should return 500 if the database throws during DELETE', (done) ->
      app.models =
        Session:
          destroy: (json) ->
            return this
          then: (cb) ->
            return this
          catch: (cb) ->
            cb?("Exterminate!")
            return this
      request(app)
        .delete('/session')
        .expect(500)
        .end (err, res) ->
          return done err if err
          done()
      return false

#----------------------------------------------------------------------------
# end of sessionTest.coffee
