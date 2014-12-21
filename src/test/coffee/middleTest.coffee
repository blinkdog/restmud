# middleTest.coffee
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

middle = require '../lib/middle'

describe 'middle', ->
  describe 'authorizationRequired', ->
    authorizationRequired = middle.authorizationRequired()

    it 'should pass along when req.authorization.basic exists', (done) ->
      req =
        authorization:
          basic: {}
      res = {}
      next = (err) ->
        return done() if not err?
        true.should.equal false
      authorizationRequired req, res, next

    it 'should send a 401 when req.authorization.basic does not exist', (done) ->
      statusOk = false
      req =
        authorization: {}
      res =
        send: (status, body) ->
          statusOk = true if status is 401
      next = (err) ->
        return done() if statusOk and err is false
        true.should.equal false
      authorizationRequired req, res, next

  describe 'requestAuth', ->
    it 'should pass along when req.authorization.basic does not exist', (done) ->
      app =
        models:
          Account: {}
      requestAuth = middle.requestAuth app
      req =
        authorization: {}
      res = {}
      next = (err) ->
        return done() if not req.auth?
        true.should.equal false
      requestAuth req, res, next

    it 'should not annotate req.auth when given an unknown user', (done) ->
      app =
        models:
          Account:
            find: (where) ->
              return this
            then: (cb) ->
              cb?(null)
              return this
            catch: (cb) ->
              return this
      requestAuth = middle.requestAuth app
      req =
        authorization:
          basic:
            username: "CrashBandicoot"
            password: "bandicoot"
      res = {}
      next = (err) ->
        return done() if not req.auth?
        true.should.equal false
      requestAuth req, res, next

    it 'should not annotate req.auth when given bad credentials', (done) ->
      mario =
        id: 1
        username: "Mario"
        hashBase64: "yGBOPbBX+J8="
        iterations: 64
        keyLength: 8
        saltBase64: "JI3XbdNVKDw="
      app =
        models:
          Account:
            find: (where) ->
              return this
            then: (cb) ->
              cb?(mario)
              return this
            catch: (cb) ->
              return this
      requestAuth = middle.requestAuth app
      req =
        authorization:
          basic:
            username: "Mario"
            password: "bowserrulz"
      res = {}
      next = (err) ->
        return done() if not req.auth?
        true.should.equal false
      requestAuth req, res, next

    it 'should not annotate req.auth when the database throws', (done) ->
      app =
        models:
          Account:
            find: (where) ->
              return this
            then: (cb) ->
              return this
            catch: (cb) ->
              cb?("Exterminate! Exterminate!")
              return this
      requestAuth = middle.requestAuth app
      req =
        authorization:
          basic:
            username: "Mario"
            password: "ilovepeach"
      res = {}
      next = (err) ->
        return done() if not req.auth?
        true.should.equal false
      requestAuth req, res, next

    it 'should annotate req.auth when provided with good credentials', (done) ->
      mario =
        id: 1
        username: "Mario"
        hashBase64: "yGBOPbBX+J8="
        iterations: 64
        keyLength: 8
        saltBase64: "JI3XbdNVKDw="
      app =
        models:
          Account:
            find: (where) ->
              return this
            then: (cb) ->
              cb?(mario)
              return this
            catch: (cb) ->
              return this
      requestAuth = middle.requestAuth app
      req =
        authorization:
          basic:
            username: "Mario"
            password: "ilovepeach"
      res = {}
      next = (err) ->
        return done() if req.auth?
        true.should.equal false
      requestAuth req, res, next

  describe 'sessionAuth', ->
    it 'should pass along when req.headers.session does not exist', (done) ->
      app = {}
      sessionAuth = middle.sessionAuth app
      req =
        headers: {}
      res = {}
      next = (err) ->
        return done() if not req.auth?
        true.should.equal false
      sessionAuth req, res, next

    it 'should pass along when req.headers.session is not a UUID', (done) ->
      app = {}
      sessionAuth = middle.sessionAuth app
      req =
        headers:
          session: "h2YgZX9Thm0"
      res = {}
      next = (err) ->
        return done() if not req.auth?
        true.should.equal false
      sessionAuth req, res, next

    it 'should pass along when Session contains an unknown or expired session', (done) ->
      app =
        models:
          Session:
            find: (where) ->
              return this
            then: (cb) ->
              cb?(null)
              return this
            catch: (cb) ->
              return this
      sessionAuth = middle.sessionAuth app
      req =
        headers:
          session: "e21aaa94-aea9-4d9f-b36b-45a2736ace64"
      res = {}
      next = (err) ->
        return done() if not req.auth?
        true.should.equal false
      sessionAuth req, res, next

    it 'should not annotate req.auth when the database throws', (done) ->
      app =
        models:
          Session:
            find: (where) ->
              return this
            then: (cb) ->
              return this
            catch: (cb) ->
              cb?("Exterminate! Exterminate!")
              return this
      sessionAuth = middle.sessionAuth app
      req =
        headers:
          session: "06ade853-d8d3-466c-98e1-420a24020a73"
      res = {}
      next = (err) ->
        return done() if not req.auth?
        true.should.equal false
      sessionAuth req, res, next

    it 'should load req.auth when Session references a valid session', (done) ->
      mario =
        id: 1
        username: "Mario"
        hashBase64: "yGBOPbBX+J8="
        iterations: 64
        keyLength: 8
        saltBase64: "JI3XbdNVKDw="
      session =
        id: 16
        uuid: "06ade853-d8d3-466c-98e1-420a24020a73"
        expiresAt: "2014-12-20T20:58:16.615Z"
        AccountId: 1
        updatedAt: "2014-12-20T20:53:16.616Z"
        createdAt: "2014-12-20T20:53:16.616Z"
        getAccount: -> mario
      app =
        models:
          Session:
            find: (where) ->
              return this
            then: (cb) ->
              cb?(session)
              return this
            catch: (cb) ->
              return this
      sessionAuth = middle.sessionAuth app
      req =
        headers:
          session: "06ade853-d8d3-466c-98e1-420a24020a73"
      res = {}
      next = (err) ->
        req.auth.should.equal mario
        return done() 
      sessionAuth req, res, next

#----------------------------------------------------------------------------
# end of middleTest.coffee
