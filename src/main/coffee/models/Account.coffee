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

exports.NAME = 'Account'

exports.SCHEMA = 
  id:
    type: Sequelize.INTEGER
    autoIncrement: true
    primaryKey: true
  username:
    type: Sequelize.STRING
    allowNull: false
    unique: true
    validate:
      is: /^[a-z]+$/i
      len: [3,16]
  hashBase64:
    type: Sequelize.STRING
    allowNull: false
    validate:
      is: BASE64
  iterations:
    type: Sequelize.INTEGER
    allowNull: false
    validate:
      min: 1
  keyLength:
    type: Sequelize.INTEGER
    allowNull: false
    validate:
      min: 1
  saltBase64:
    type: Sequelize.STRING
    allowNull: false
    validate:
      is: BASE64
  email:
    type: Sequelize.STRING
    validate:
      isEmail: true
  banned:
    type: Sequelize.BOOLEAN
    allowNull: false
    defaultValue: false
  admin:
    type: Sequelize.BOOLEAN
    allowNull: false
    defaultValue: false

#----------------------------------------------------------------------------
# end of Account.coffee
