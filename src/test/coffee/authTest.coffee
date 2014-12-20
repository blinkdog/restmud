# authTest.coffee
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

auth = require '../lib/auth'

describe 'auth', ->
  it 'should generate pbkdf hashes', (done) ->
    options =
      iterations: 64
      keyLength: 8
      password: 'ilovepeach'
      saltLength: 8
    auth.generate options, (err, cred) ->
      return done err if err?
      cred.should.have.properties [ 'hashBase64', 'iterations', 'keyLength', 'saltBase64' ]
      done()

  it 'should verifySync pbkdf hashes', (done) ->
    options =
      iterations: 64
      keyLength: 8
      password: 'ilovepeach'
      saltLength: 8
    auth.generate options, (err, cred) ->
      return done err if err?
      cred.should.have.properties [ 'hashBase64', 'iterations', 'keyLength', 'saltBase64' ]
      cred.password = 'ilovepeach'
      auth.verifySync(cred).should.equal true
      done()

  it 'should not verifySync pbkdf hashes with bad passwords', (done) ->
    options =
      iterations: 64
      keyLength: 8
      password: 'ilovepeach'
      saltLength: 8
    auth.generate options, (err, cred) ->
      return done err if err?
      cred.should.have.properties [ 'hashBase64', 'iterations', 'keyLength', 'saltBase64' ]
      cred.password = 'bowserrulz'
      auth.verifySync(cred).should.equal false
      done()

  it 'should generate an error with negative iterations', (done) ->
    options =
      iterations: -64
      keyLength: 8
      password: 'ilovepeach'
      saltLength: 8
    auth.generate options, (err, cred) ->
      return done() if err?
      should(err).be.ok
      done new Error "negative iterations"

  it 'should generate an error with negative keyLength', (done) ->
    options =
      iterations: 64
      keyLength: -8
      password: 'ilovepeach'
      saltLength: 8
    auth.generate options, (err, cred) ->
      return done() if err?
      should(err).be.ok
      done new Error "negative keyLength"

  it 'should generate an error with negative saltLength', (done) ->
    options =
      iterations: 64
      keyLength: 8
      password: 'ilovepeach'
      saltLength: -8
    auth.generate options, (err, cred) ->
      return done() if err?
      should(err).be.ok
      done new Error "negative saltLength"

  it 'should generate an error with a null password', (done) ->
    options =
      iterations: 64
      keyLength: 8
      password: null
      saltLength: 8
    auth.generate options, (err, cred) ->
      return done() if err?
      should(err).be.ok
      done new Error "null password"

#----------------------------------------------------------------------------
# end of authTest.coffee
