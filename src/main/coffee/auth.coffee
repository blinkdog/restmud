# auth.coffee
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

crypto = require 'crypto'

exports.generate = (options, callback) ->
  { iterations, keyLength, password, saltLength } = options
  try 
    saltBuffer = crypto.pseudoRandomBytes saltLength
    # https://github.com/joyent/node/issues/8915
    try 
      key = crypto.pbkdf2Sync password, saltBuffer, iterations, keyLength
      callback null,
        hashBase64: key.toString 'base64'
        iterations: iterations
        keyLength: keyLength
        saltBase64: saltBuffer.toString 'base64'
    catch err2
      callback err2
  catch err
    callback err

exports.verifySync = (options) ->
  { hashBase64, iterations, keyLength, password, saltBase64 } = options
  saltBuffer = new Buffer saltBase64, 'base64'
  hashBuffer = crypto.pbkdf2Sync password, saltBuffer, iterations, keyLength
  hashBase64 is hashBuffer.toString 'base64'

#----------------------------------------------------------------------------
# end of auth.coffee
