# pingTest.coffee
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

restmud = require '../../lib/restmud'

app = restmud.create()

xdescribe '/ping', ->
  describe 'HEAD /ping', ->
    it 'should return 200', (done) ->
      request(app)
        .head('/ping')
        .expect(200)
        .end (err, res) ->
          return done err if err
          done()

  describe 'GET /ping', ->
    it 'should return 405', (done) ->
      request(app)
        .get('/ping')
        .expect(405)
        .end (err, res) ->
          return done err if err
          done()

  describe 'POST /ping', ->
    it 'should return 405', (done) ->
      request(app)
        .post('/ping')
        .expect(405)
        .end (err, res) ->
          return done err if err
          done()

  describe 'PUT /ping', ->
    it 'should return 405', (done) ->
      request(app)
        .put('/ping')
        .expect(405)
        .end (err, res) ->
          return done err if err
          done()

  describe 'DELETE /ping', ->
    it 'should return 405', (done) ->
      request(app)
        .delete('/ping')
        .expect(405)
        .end (err, res) ->
          return done err if err
          done()

#----------------------------------------------------------------------------
# end of pingTest.coffee
