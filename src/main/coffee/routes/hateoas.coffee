# hateoas.coffee
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

{baseUri, sourceUri} = require '../../config'
accounts = require './accounts'
ping = require './ping'
session = require './session'

exports.PATH = PATH = '/'

HATEOAS =
  links: [
    { rel:'accounts', href:"#{baseUri}#{accounts.PATH}" },
    { rel:'ping', href:"#{baseUri}#{ping.PATH}" },
    { rel:'self', href:"#{baseUri}#{PATH}" },
    { rel:'session', href:"#{baseUri}#{session.PATH}" },
    { rel:'source', href:"#{sourceUri}" } ]

exports.attach = (server) ->
  server.head PATH, (req, res, next) ->
    res.send 200
    next()

  server.get PATH, (req, res, next) ->
    res.send 200, HATEOAS
    next()

  return server

#----------------------------------------------------------------------------
# end of hateoas.coffee
