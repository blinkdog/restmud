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
{
  BadRequestError,
  ConflictError,
  ForbiddenError,
  InternalServerError,
  InvalidArgumentError,
  MissingParameterError,
  UnauthorizedError
} = require "restify-errors"
Sequelize = require 'sequelize'

{ baseUri, pbkdf2 } = require('../../config')

middle = require '../middle'

auth = require '../auth'
dbMessage = require '../dbMessage'

exports.PATH = PATH = '/account'

displayAccount = (account) ->
  acct = _.pick account, [ 'id', 'username', 'email' ]
  acct.links = [
    { rel:'self', href:"#{baseUri}#{PATH}/#{acct.id}" } ]
  return acct

exports.attach = (server) ->

  server.get PATH, (req, res, next) ->
    next new UnauthorizedError "Authentication required to list accounts"

  server.post PATH, (req, res, next) ->
    # handle all the bad cases
    if not req.body?
      return next new BadRequestError "body required"
    if not req.is 'json'
      return next new BadRequestError "valid JSON required"
    if not req.body.username?
      return next new MissingParameterError "username required"
    if not req.body.password?
      return next new MissingParameterError "password required"
    {username, password} = req.body
    if username.length < 3
      return next new InvalidArgumentError "username too short"
    if username.length > 16
      return next new InvalidArgumentError "username too long"
    if not /^[a-z]+$/i.test username
      return next new InvalidArgumentError "username contains non-alpha"
    # prepare the account data for creation
    accountData = _.pick req.body, ['username', 'password']
    {Account} = server.models
    options =
      digest: pbkdf2.digest
      iterations: pbkdf2.iterations
      keyLength: pbkdf2.keyLength
      password: accountData.password
      saltLength: pbkdf2.saltLength
    auth.generate options, (err, cred) ->
      return next new InternalServerError err if err?
      # attempt to create the account
      _.defaults accountData, cred
      Account.create(accountData)
      .then (account) ->
          res.send 201,
            rel: 'account'
            href: "#{baseUri}#{PATH}/#{account.id}"
          next()
      .catch (err) ->
        next new ConflictError dbMessage.parse err

  adminRequired = middle.adminRequired()
  server.get "#{PATH}/insecure", adminRequired, (req, res, next) ->
    findInsecure =
      where: Sequelize.or(
        { iterations: { lt: pbkdf2.iterations } },
        { keyLength:  { lt: pbkdf2.keyLength } } )
    {Account} = server.models
    Account.findAll(findInsecure)
    .then (insecureAccounts) ->
      res.send 200, insecureAccounts
      next()
    .catch (err) ->
      next new InternalServerError dbMessage.parse err

  server.get "#{PATH}/:id", (req, res, next) ->
    ERROR_MESSAGE = "Authentication required to view account"
    if not req.auth?
      return next new UnauthorizedError ERROR_MESSAGE
    if req.auth.id isnt parseInt req.params.id
      return next new ForbiddenError ERROR_MESSAGE
    res.send 200, displayAccount req.auth
    next()

  server.put "#{PATH}/:id", (req, res, next) ->
    # check authentication
    ERROR_MESSAGE = "Authentication required to update account"
    if not req.auth?
      return next new UnauthorizedError ERROR_MESSAGE
    if req.auth.id isnt parseInt req.params.id
      return next new ForbiddenError ERROR_MESSAGE
    # determine what fields need to be updated
    newAcct = _.pick req.body, [ 'email', 'password' ]
    # if the user updated their password
    if newAcct.password?
      _.defaults newAcct, auth.generateSync
        digest: pbkdf2.digest
        iterations: pbkdf2.iterations
        keyLength: pbkdf2.keyLength
        password: newAcct.password
        saltLength: pbkdf2.saltLength
    # ask the database to update the account object
    req.auth.updateAttributes(newAcct)
    .then ->
      res.send 200, displayAccount req.auth
      next()
    .catch (err) ->
      next new ConflictError dbMessage.parse err

  server.del "#{PATH}/:id", (req, res, next) ->
    # check authentication
    ERROR_MESSAGE = "Authentication required to delete account"
    if not req.auth?
      return next new UnauthorizedError ERROR_MESSAGE
    if req.auth.id isnt parseInt req.params.id
      return next new ForbiddenError ERROR_MESSAGE
    # delete the account
    req.auth.destroy()
    .then ->
      res.send 200
      next()
    .catch (err) ->
      next new ConflictError dbMessage.parse err

  return server

#----------------------------------------------------------------------------
# end of account.coffee
