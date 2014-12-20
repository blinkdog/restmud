# account.coffee
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
restify = require 'restify'

{ baseUri, pbkdf2 } = require('../../config')

auth = require '../auth'
dbMessage = require '../dbMessage'

exports.PATH = PATH = '/account'

exports.attach = (server) ->

  server.get PATH, (req, res, next) ->
    next new restify.UnauthorizedError "Authentication required to list accounts"

  server.post PATH, (req, res, next) ->
    # handle all the bad cases
    if not req.body?
      return next new restify.BadRequestError "body required"
    if not req.is 'json'
      return next new restify.BadRequestError "valid JSON required"
    if not req.body.username?
      return next new restify.MissingParameterError "username required"
    if not req.body.password?
      return next new restify.MissingParameterError "password required"
    {username, password} = req.body
    if username.length < 3
      return next new restify.InvalidArgumentError "username too short"
    if username.length > 16
      return next new restify.InvalidArgumentError "username too long"
    if not /^[a-z]+$/i.test username
      return next new restify.InvalidArgumentError "username contains non-alpha"
    # prepare the account data for creation
    accountData = _.pick req.body, ['username', 'password']
    {Account} = server.models
    options =
      iterations: pbkdf2.iterations
      keyLength: pbkdf2.keyLength
      password: accountData.password
      saltLength: pbkdf2.saltLength
    auth.generate options, (err, cred) ->
      return next new restify.InternalServerError err if err?
      # attempt to create the account
      _.defaults accountData, cred
      Account.create(accountData)
      .then (account) ->
          res.send 201,
            rel: 'account'
            href: "#{baseUri}#{PATH}/#{account.id}"
          next()
      .catch (err) ->
        next new restify.ConflictError dbMessage.parse err

  server.get "#{PATH}/:id", (req, res, next) ->
    next new restify.UnauthorizedError "Authentication required to view account"

  return server

#----------------------------------------------------------------------------
# end of account.coffee
