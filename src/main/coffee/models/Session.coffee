# Account.coffee
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

Sequelize = require 'sequelize'

{BASE64} = require '../validate'

exports.NAME = 'Session'

exports.SCHEMA = 
  id:
    type: Sequelize.BIGINT
    autoIncrement: true
    primaryKey: true
  uuid:
    type: Sequelize.UUID
    allowNull: false
    defaultValue: Sequelize.UUIDV4
    validate:
      isUUID: 4
  expiresAt:
    type: Sequelize.DATE
    allowNull: false
    validate:
      isDate: true

#----------------------------------------------------------------------------
# end of Session.coffee
