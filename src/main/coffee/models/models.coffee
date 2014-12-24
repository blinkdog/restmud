# models.coffee
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

modelNames = [ "Account", "Session" ]

options =
  paranoid: true                       # use deletedAt instead of deleting rows

exports.define = (sequelize, app) ->
  # load and define all the models
  models = {}
  for name in modelNames
    model = require("./#{name}")
    models[model.NAME] = sequelize.define model.NAME, model.SCHEMA, options
  # define the relations between models
  models.Account.hasMany models.Session
  models.Session.belongsTo models.Account
  # return our app with ORM models
  app.models = models
  return app

#----------------------------------------------------------------------------
# end of models.coffee
