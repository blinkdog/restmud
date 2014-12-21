# middle.coffee
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

{verifySync} = require './auth'
{UUIDV4} = require './validate'

exports.authorizationRequired = ->
  return (req, res, next) ->
    if not req.authorization.basic?
      res.send 401
      return next false
    next()

exports.requestAuth = (app) ->
  return (req, res, next) ->
    return next() if not req.authorization.basic?
    findUsername =
      where:
        username: req.authorization.basic.username
    {Account} = app.models
    Account.find(findUsername)
    .then (account) ->
      return next() if not account?
      verifyCred =
        hashBase64: account.hashBase64
        iterations: account.iterations
        keyLength: account.keyLength
        password: req.authorization.basic.password
        saltBase64: account.saltBase64
      if verifySync verifyCred
        req.auth = account
      next()
    .catch (err) ->
      return next()

exports.sessionAuth = (app) ->
  return (req, res, next) ->
    return next() if not req.headers.session?
    return next() if not UUIDV4.test req.headers.session
    findByUuid =
      where:
        uuid: req.headers.session
        expiresAt:
          gt: Sequelize.NOW            # non-expired sessions only
    {Session} = app.models
    Session.find(findByUuid)
    .then (session) ->
      return next() if not session?
      req.auth = session.getAccount()
      next()
    .catch (err) ->
      return next()

#----------------------------------------------------------------------------
# end of middle.coffee
