# dbMessageTest.coffee
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

dbMessage = require '../lib/dbMessage'

xdescribe 'Database Message', ->
  it 'should describe duplicate usernames', ->
    result = dbMessage.parse
      name: 'SequelizeUniqueConstraintError'
      fields: [ 'username' ]
    result.should.equal 'username is already in use'

  it 'should describe constraint errors with detail', ->
    result = dbMessage.parse
      name: 'SequelizeUniqueConstraintError'
      fields: [ 'id' ]
      parent:
        detail: 'Key (id)=(42) already exists.'
    result.should.equal 'SequelizeUniqueConstraintError: Key (id)=(42) already exists.'

  it 'should describe other errors with a message', ->
    result = dbMessage.parse
      name: 'SequelizeValidationError'
      fields: [ 'username' ]
      parent:
        detail: 'Key (username) is too long.'
    result.should.equal 'SequelizeValidationError: Key (username) is too long.'

  it 'should provide the name of the error if there is no detail available', ->
    result = dbMessage.parse
      name: 'SequelizeQueryError'
      parent:
        sql: 'INSERT INTO'
    result.should.equal 'SequelizeQueryError'

  it 'should provide the name of the error if there is no parent available', ->
    result = dbMessage.parse
      name: 'SequelizeQueryError'
    result.should.equal 'SequelizeQueryError'

  it 'should give a generic error when no information is available', ->
    result = dbMessage.parse {}
    result.should.equal 'Database Error'

  it 'should give a generic error when no error is provided', ->
    result = dbMessage.parse null
    result.should.equal 'Unknown Error'

#----------------------------------------------------------------------------
# end of dbMessageTest.coffee
