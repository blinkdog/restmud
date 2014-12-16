# hateoasTest.coffee
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

describe 'HATEOAS /', ->
  describe 'HEAD /', ->
    it 'should return 200', (done) ->
      request(app)
        .head('/')
        .expect(200)
        .end (err, res) ->
          return done err if err
          done()

  describe 'GET /', ->
    it 'should return 200', (done) ->
      request(app)
        .get('/')
        .expect(200)
        .end (err, res) ->
          return done err if err
          done()
          
    it 'should return JSON', (done) ->
      request(app)
        .get('/')
        .set('Accept', 'application/json')
        .expect('Content-Type', /json/)
        .expect(200)
        .end (err, res) ->
          return done err if err
          done()

    it 'should return HATEOAS links', (done) ->
      request(app)
        .get('/')
        .set('Accept', 'application/json')
        .expect('Content-Type', /json/)
        .expect(200)
        .end (err, res) ->
          res.body.should.be.ok
          res.body.should.have.property 'links'
          res.body.links.should.be.an.Array
          res.body.links.should.not.be.empty
          res.body.links.should.matchEach (link) ->
            link.should.match 
              rel:  (it) -> it.should.be.ok
              href: (it) -> it.should.be.ok
          return done err if err
          done()

#----------------------------------------------------------------------------
# end of hateoasTest.coffee
