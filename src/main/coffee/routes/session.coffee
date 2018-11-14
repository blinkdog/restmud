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

_ = require 'underscore'
{InternalServerError} = require 'restify-errors'
Sequelize = require 'sequelize'

{ baseUri, sessionLength } = require '../../config'

middle = require '../middle'

exports.PATH = PATH = '/session'

acctPATH = require('./account').PATH

displaySession = (session) ->
  sess = _.pick session, [ 'id', 'uuid', 'expiresAt' ]
  sess.links = [
    { rel:'self',    href:"#{baseUri}#{PATH}/#{session.id}" },
    { rel:'account', href:"#{baseUri}#{acctPATH}/#{session.AccountId}" } ]
  return sess

exports.attach = (server) ->
  authorizationRequired = middle.authorizationRequired()

  server.post PATH, authorizationRequired, (req, res, next) ->
    if not req.auth?
      res.send 401
      return next()
    {Session} = server.models
    Session.create
      expiresAt: Date.now() + sessionLength
      AccountId: req.auth.id
    .then (session) ->
      res.send 201, displaySession session
      next()
    .catch (err) ->
      next new InternalServerError err

  server.del PATH, (req, res, next) ->
    ###
      Note: We really don't care about authentication here. If an
      anonymous user asks the server to delete expired sessions,
      it's not really a big deal.
    ###
    {Session} = server.models
    findByExpired =
      where:
        deletedAt: null
        expiresAt:
          lt: Sequelize.NOW            # expired sessions only
    Session.destroy(findByExpired)
    .then ->
      res.send 200
      next()
    .catch (err) ->
      next new InternalServerError err

  return server

#----------------------------------------------------------------------------
# end of session.coffee
