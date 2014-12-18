# dbMessage.coffee
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

exports.parse = (err) ->
  if not err?
    return 'Unknown Error'
  if err.name? and err.fields?
    if err.name is 'SequelizeUniqueConstraintError'
      if _.contains err.fields, 'username'
        return 'username is already in use'
  if err.name? and err.parent?.detail?
    return "#{err.name}: #{err.parent.detail}"
  if err.name?
    return "#{err.name}"
  return 'Database Error'

#----------------------------------------------------------------------------
# end of dbMessage.coffee
