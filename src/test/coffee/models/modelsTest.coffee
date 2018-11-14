# modelsTest.coffee
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

models = require '../../lib/models/models'

xdescribe 'Models', ->
  nameList = []

  sequelize =
    define: (name, schema) ->
      name.should.be.ok
      schema.should.be.ok
      nameList.push name
      model =
        belongsTo: ->
        hasMany: ->

  app =
    models: null

  models.define sequelize, app

  describe 'Definitions', ->
    it 'should have defined an Account model', ->
      (_.contains nameList, 'Account').should.equal true
    it 'should have defined a Session model', ->
      (_.contains nameList, 'Session').should.equal true

  describe 'Application', ->
    it 'should inject the models dependency object into application', ->
      app.should.have.property 'models'
      app.models.should.be.ok
    it 'should have an Account model', ->
      app.models.should.have.property 'Account'
      app.models.Account.should.be.ok
    it 'should have a Session model', ->
      app.models.should.have.property 'Session'
      app.models.Session.should.be.ok

#----------------------------------------------------------------------------
# end of modelsTest.coffee
