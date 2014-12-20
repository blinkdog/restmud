# session.coffee
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

config = require '../../config'
middle = require '../middle'

exports.PATH = PATH = '/session'

exports.attach = (server) ->
  authorizationRequired = middle.authorizationRequired()

  server.post PATH, authorizationRequired, (req, res, next) ->
    if not req.auth?
      res.send 401
      return next()
    {Session} = server.models
    Session.create
      expiresAt: Date.now() + config.sessionLength
      AccountId: req.auth.id
    .then (session) ->
      res.send 201, session
      next()
    .catch (err) ->
      next new restify.InternalServerError err

  return server

#----------------------------------------------------------------------------
# end of session.coffee
