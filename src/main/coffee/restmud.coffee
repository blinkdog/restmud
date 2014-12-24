# restmud.coffee
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

restify = require 'restify'

middle = require './middle'

exports.create = (options) ->
  app = restify.createServer()
  
  app.pre restify.pre.userAgentConnection()   # clean up curl requests
  app.use restify.authorizationParser()       # parse an Authorization header
  app.use restify.bodyParser()                # parse JSON into req.body

  app.use middle.requestAuth app              # load req.auth when valid creds
  app.use middle.sessionAuth app              # load req.auth when valid Session
  app.use middle.forbidBanned()               # 403 requests from banned accts

  require('./routes/account').attach app
  require('./routes/hateoas').attach app
  require('./routes/ping').attach app
  require('./routes/session').attach app

  return app

#----------------------------------------------------------------------------
# end of restmud.coffee
