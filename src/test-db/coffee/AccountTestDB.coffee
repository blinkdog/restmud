# AccountTestDB.coffee
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

model = require '../lib/models/Account'

describe 'Sequelize: Account', ->
  { dbname, username, password, options } = require './test-db-config'
  Account = null
  sequelize = null

  before (done) ->
    sequelize = new Sequelize dbname, username, password, options
    Account = sequelize.define model.NAME, model.SCHEMA
    done()

  beforeEach (done) ->
    sequelize.sync
      force: true
    .then ->
      done()
    .catch (err) ->
      done err

  it 'should return the model from the define method', ->
    Account.should.be.ok
    Account.should.have.property 'create'

  it 'should prevent a null username', (done) ->
    Account.create
      username: null
      password: "ilovepeach"
      hashBase64: "Z4xI4VTBjsg="
      iterations: 64
      keyLength: 8
      saltBase64: "EZnN2v1NtDk="
    .then (mario) ->
      mario.should.have.property 'username'
      done new Error("Account.username === null")
    .catch (err) ->
      done()

  it 'should prevent a null password', (done) ->
    Account.create
      username: "Mario"
      password: null
      hashBase64: "Z4xI4VTBjsg="
      iterations: 64
      keyLength: 8
      saltBase64: "EZnN2v1NtDk="
    .then (mario) ->
      mario.should.have.property 'password'
      done new Error("Account.password === null")
    .catch (err) ->
      done()

  it 'should prevent a null hashBase64', (done) ->
    Account.create
      username: "Mario"
      password: "ilovepeach"
      hashBase64: null
      iterations: 64
      keyLength: 8
      saltBase64: "EZnN2v1NtDk="
    .then (mario) ->
      mario.should.have.property 'hashBase64'
      done new Error("Account.hashBase64 === null")
    .catch (err) ->
      done()

  it 'should prevent non-positive iterations', (done) ->
    Account.create
      username: "Mario"
      password: "ilovepeach"
      hashBase64: "Z4xI4VTBjsg="
      iterations: 0
      keyLength: 8
      saltBase64: "EZnN2v1NtDk="
    .then (mario) ->
      mario.should.have.property 'iterations'
      done new Error("Account.iterations === 0")
    .catch (err) ->
      done()

  it 'should prevent non-positive keyLength', (done) ->
    Account.create
      username: "Mario"
      password: "ilovepeach"
      hashBase64: "Z4xI4VTBjsg="
      iterations: 64
      keyLength: 0
      saltBase64: "EZnN2v1NtDk="
    .then (mario) ->
      mario.should.have.property 'keyLength'
      done new Error("Account.keyLength === 0")
    .catch (err) ->
      done()

  it 'should prevent a null saltBase64', (done) ->
    Account.create
      username: "Mario"
      password: "ilovepeach"
      hashBase64: "Z4xI4VTBjsg="
      iterations: 64
      keyLength: 8
      saltBase64: null
    .then (mario) ->
      mario.should.have.property 'saltBase64'
      done new Error("Account.saltBase64 === null")
    .catch (err) ->
      done()

  it 'should prevent duplicate usernames', (done) ->
    Account.create
      username: "Mario"
      password: "ilovepeach"
      hashBase64: "Z4xI4VTBjsg="
      iterations: 64
      keyLength: 8
      saltBase64: "EZnN2v1NtDk="
    .then (mario) ->
      Account.create
        username: "Mario"
        password: "itsameWario"
        hashBase64: "Z4xI4VTBjsg="
        iterations: 64
        keyLength: 8
        saltBase64: "EZnN2v1NtDk="
      .then (wario) ->
        done new Error("Account.username is not unique")
      .catch (err) ->
        done()
    .catch (err) ->
      done err

  it 'should prevent non-alpha usernames', (done) ->
    badNames = [
      "^Bob^", "mix-master", "dredlock123",
      "/rofl/copter", "First Last", "Queensrÿche",
      "űnnæcessåry" ]
    maybeDone = _.after badNames.length, done
    for badName in badNames
      Account.create
        username: badName
        password: "misunderstood"
        hashBase64: "Z4xI4VTBjsg="
        iterations: 64
        keyLength: 8
        saltBase64: "EZnN2v1NtDk="
      .then (mario) ->
        done new Error("Account.username contains non-alpha")
      .catch (err) ->
        maybeDone()

  it 'should prevent short usernames', (done) ->
    badNames = [ "Ur", "Om", "A", "In", "On", "Xx" ]
    maybeDone = _.after badNames.length, done
    for badName in badNames
      Account.create
        username: badName
        password: "misunderstood"
        hashBase64: "Z4xI4VTBjsg="
        iterations: 64
        keyLength: 8
        saltBase64: "EZnN2v1NtDk="
      .then (mario) ->
        done new Error("Account.username contains a too-short username")
      .catch (err) ->
        maybeDone()

  it 'should prevent too-long usernames', (done) ->
    badNames = [ "MacGhilleseatheanaich", "Featherstonehaugh",
      "Wolfeschlegelsteinhausenbergerdorff", "xxxroflcopterroflxxx" ]
    maybeDone = _.after badNames.length, done
    for badName in badNames
      Account.create
        username: badName
        password: "misunderstood"
        hashBase64: "Z4xI4VTBjsg="
        iterations: 64
        keyLength: 8
        saltBase64: "EZnN2v1NtDk="
      .then (mario) ->
        done new Error("Account.username contains a too-long username #{badName}")
      .catch (err) ->
        maybeDone()

  it 'should prevent non-base64 password hashes', (done) ->
    Account.create
      username: "Mario"
      password: "ilovepeach"
      hashBase64: "űnnæcessåry"
      iterations: 64
      keyLength: 8
      saltBase64: "EZnN2v1NtDk="
    .then (mario) ->
      done new Error("Account.hashBase64 contains non-base64")
    .catch (err) ->
      done()

  it 'should prevent non-base64 salt', (done) ->
    Account.create
      username: "Mario"
      password: "ilovepeach"
      hashBase64: "EZnN2v1NtDk="
      iterations: 64
      keyLength: 8
      saltBase64: "űnnæcessåry"
    .then (mario) ->
      done new Error("Account.saltBase64 contains non-base64")
    .catch (err) ->
      done()

  it 'should create auto-incrementing ids', (done) ->
    accounts = []
    maybeDone = _.after 2, ->
      accounts.should.have.length 2
      accounts[0].id.should.not.equal accounts[1].id
      done()
    Account.create
      username: "Mario"
      password: "ilovepeach"
      hashBase64: "Z4xI4VTBjsg="
      iterations: 64
      keyLength: 8
      saltBase64: "EZnN2v1NtDk="
    .then (mario) ->
      mario.should.have.property 'id'
      mario.id.should.be.ok
      mario.id.should.be.greaterThan 0
      accounts.push mario
      maybeDone()
    .catch (err) ->
      done err
    Account.create
      username: "Luigi"
      password: "ilovedaisy"
      hashBase64: "Z4xI4VTBjsg="
      iterations: 64
      keyLength: 8
      saltBase64: "EZnN2v1NtDk="
    .then (luigi) ->
      luigi.should.have.property 'id'
      luigi.id.should.be.ok
      luigi.id.should.be.greaterThan 0
      accounts.push luigi
      maybeDone()
    .catch (err) ->
      done err

  it 'should allow us to specify an id', (done) ->
    Account.create
      id: 42
      username: "Mario"
      password: "ilovepeach"
      hashBase64: "Z4xI4VTBjsg="
      iterations: 64
      keyLength: 8
      saltBase64: "EZnN2v1NtDk="
    .then (mario) ->
      mario.should.have.property 'id'
      mario.id.should.be.ok
      mario.id.should.equal 42
      done()
    .catch (err) ->
      done err

#----------------------------------------------------------------------------
# end of AccountTestDB.coffee
