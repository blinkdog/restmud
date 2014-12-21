# SessionTestDB.coffee
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
Sequelize = require 'sequelize'
should = require 'should'

model = require '../lib/models/Session'

describe 'Sequelize: Session', ->
  { dbname, username, password, options } = require './test-db-config'
  Session = null
  sequelize = null

  before (done) ->
    sequelize = new Sequelize dbname, username, password, options
    Session = sequelize.define model.NAME, model.SCHEMA
    done()

  beforeEach (done) ->
    sequelize.sync
      force: true
    .then ->
      done()
    .catch (err) ->
      done err

  it 'should return the model from the define method', ->
    Session.should.be.ok
    Session.should.have.properties [ 'create', 'find' ]
    
  it 'should not return expired sessions', (done) ->
    Session.create
      expiresAt: Date.now() - 300000
    .then (session) ->
      session.expiresAt.should.be.ok
      findByUuid =
        where:
          uuid: session.uuid
          expiresAt:
            gt: Sequelize.NOW
      Session.find(findByUuid)
      .then (notFoundSession) ->
        should(notFoundSession).equal null
        return done()
      .catch (err2) ->
        done err2
    .catch (err) ->
      done err

  it 'should return valid sessions', (done) ->
    Session.create
      expiresAt: Date.now() + 300000
    .then (session) ->
      session.expiresAt.should.be.ok
      findByUuid =
        where:
          uuid: session.uuid
          expiresAt:
            gt: Sequelize.NOW
      Session.find(findByUuid)
      .then (foundSession) ->
        foundSession.id.should.equal session.id
        foundSession.uuid.should.equal session.uuid
        return done()
      .catch (err2) ->
        done err2
    .catch (err) ->
      done err

#----------------------------------------------------------------------------
# end of SessionTestDB.coffee
