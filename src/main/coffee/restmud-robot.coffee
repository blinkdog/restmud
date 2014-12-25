# restmud-robot.coffee
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

config = require '../config'
restify = require 'restify'

SEC_PER_MIN = 60
MSEC_PER_SEC = 1000

FIVE_MINUTES = 5 * SEC_PER_MIN * MSEC_PER_SEC

deleteExpiredSessions = ->
  client = restify.createJsonClient
    url: config.baseUri
  client.del '/session', (err, req, res) ->
    console.log "Error: #{err}" if err?
    console.log 'Delete Expired Sessions: %d -> %j', res.statusCode, res.headers

everyFiveMinutes = ->
  console.log 'Starting: Five minute tasks'
  deleteExpiredSessions()
  console.log 'Ending: Five minute tasks'
  setTimeout everyFiveMinutes, FIVE_MINUTES

exports.run = ->
  setTimeout everyFiveMinutes, FIVE_MINUTES

#----------------------------------------------------------------------------
# end of restmud-robot.coffee
