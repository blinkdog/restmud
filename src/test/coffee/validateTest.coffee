# validateTest.coffee
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
crypto = require 'crypto'
should = require 'should'

validate = require '../lib/validate'

SIZE_RANDOM_TEST = 256
NUM_RANDOM_TESTS = 64

describe 'validate', ->
  describe 'BASE64', ->
    it 'should be a regular expression', ->
      validate.should.have.property 'BASE64'
      validate.BASE64.should.be.ok
      validate.BASE64.constructor.name.should.equal 'RegExp'
      should(validate.BASE64 instanceof RegExp).equal true
      
    it 'should validate legitimate base64 strings', (done) ->
      maybeDone = _.after NUM_RANDOM_TESTS, done
      for i in [1..NUM_RANDOM_TESTS]
        crypto.randomBytes SIZE_RANDOM_TEST, (err, bytes) ->
          return done err if err?
          base64 = bytes.toString 'base64'
          return maybeDone() if validate.BASE64.test base64
          console.log 'validateTest.coffee:36 - %s', base64
          should(false).equal true

    it 'should invalidate bad base64 strings', ->
      validate.BASE64.test('"[|Â½8-WÂ£â€¹"').should.equal false
      validate.BASE64.test('インターネットで日本語を学習するのに「これeな」と思ったサイトやアイディアを紹介するサイト').should.equal false
      validate.BASE64.test('xx9cxf3Hxcdxc9xc9xd7Q(xcf/xcaIQx04x00 ^x04x8a').should.equal false
      validate.BASE64.test('48656c6c6f2c20776f726c6421').should.equal false

#----------------------------------------------------------------------------
# end of validateTest.coffee
