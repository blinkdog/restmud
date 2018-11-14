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

xdescribe 'validate', ->
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
          should(false).equal true

    it 'should invalidate bad base64 strings', ->
      validate.BASE64.test('"[|Â½8-WÂ£â€¹"').should.equal false
      validate.BASE64.test('インターネットで日本語を学習するのに「これeな」と思ったサイトやアイディアを紹介するサイト').should.equal false
      validate.BASE64.test('xx9cxf3Hxcdxc9xc9xd7Q(xcf/xcaIQx04x00 ^x04x8a').should.equal false
      validate.BASE64.test('48656c6c6f2c20776f726c6421').should.equal false

  describe 'UUIDV4', ->
    it 'should be a regular expression', ->
      validate.should.have.property 'UUIDV4'
      validate.UUIDV4.should.be.ok
      validate.UUIDV4.constructor.name.should.equal 'RegExp'
      should(validate.UUIDV4 instanceof RegExp).equal true

    it 'should validate legitimate UUID v4 strings', ->
      {UUIDV4} = validate
      UUIDV4.test("58cac0ff-db9b-42e9-8119-2a9782334beb").should.equal true
      UUIDV4.test("5d5d462a-8fc7-4f90-9a7e-75900b14c095").should.equal true
      UUIDV4.test("706afbc5-8724-40be-a462-e573b260b6e3").should.equal true
      UUIDV4.test("1a441627-a85b-4615-b4ad-567490cbecaf").should.equal true

    it 'should invalidate bogus UUID v4 strings', ->
      {UUIDV4} = validate
      UUIDV4.test("58cac0ff-db9b-42e9-1119-2a9782334beb").should.equal false
      UUIDV4.test("5d5d462a-8fc7-4f90-2a7e-75900b14c095").should.equal false
      UUIDV4.test("706afbc5-8724-40be-3462-e573b260b6e3").should.equal false
      UUIDV4.test("1a441627-a85b-4615-44ad-567490cbecaf").should.equal false
      UUIDV4.test("58cac0ff-db9b-42e9-5119-2a9782334beb").should.equal false
      UUIDV4.test("5d5d462a-8fc7-4f90-6a7e-75900b14c095").should.equal false
      UUIDV4.test("706afbc5-8724-40be-7462-e573b260b6e3").should.equal false
      UUIDV4.test("1a441627-a85b-4615-c4ad-567490cbecaf").should.equal false
      UUIDV4.test("1a441627-a85b-4615-d4ad-567490cbecaf").should.equal false
      UUIDV4.test("1a441627-a85b-4615-e4ad-567490cbecaf").should.equal false
      UUIDV4.test("1a441627-a85b-4615-f4ad-567490cbecaf").should.equal false

    it 'should invalidate non-v4 UUID strings', ->
      {UUIDV4} = validate
      UUIDV4.test("706afbc5-8724-10be-a462-e573b260b6e3").should.equal false
      UUIDV4.test("706afbc5-8724-20be-a462-e573b260b6e3").should.equal false
      UUIDV4.test("706afbc5-8724-30be-a462-e573b260b6e3").should.equal false
      UUIDV4.test("706afbc5-8724-50be-a462-e573b260b6e3").should.equal false
      UUIDV4.test("706afbc5-8724-60be-a462-e573b260b6e3").should.equal false
      UUIDV4.test("706afbc5-8724-70be-a462-e573b260b6e3").should.equal false
      UUIDV4.test("706afbc5-8724-80be-a462-e573b260b6e3").should.equal false
      UUIDV4.test("706afbc5-8724-90be-a462-e573b260b6e3").should.equal false
      UUIDV4.test("706afbc5-8724-a0be-a462-e573b260b6e3").should.equal false
      UUIDV4.test("706afbc5-8724-b0be-a462-e573b260b6e3").should.equal false
      UUIDV4.test("706afbc5-8724-c0be-a462-e573b260b6e3").should.equal false
      UUIDV4.test("706afbc5-8724-d0be-a462-e573b260b6e3").should.equal false
      UUIDV4.test("706afbc5-8724-e0be-a462-e573b260b6e3").should.equal false
      UUIDV4.test("706afbc5-8724-f0be-a462-e573b260b6e3").should.equal false

#----------------------------------------------------------------------------
# end of validateTest.coffee
