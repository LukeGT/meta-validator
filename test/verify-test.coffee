meta = require '../index.coffee'

##
# Helper functions
##
createPair = (type, inputValue) ->
  def:
    field: type
  obj:
    field: inputValue

createTwoPairs = (type1, value1, type2, value2) ->
  createTwoPairsWithFields('field1', type1, value1, 'field2', type2, value2)

createTwoPairsWithFields = (field1, type1, value1, field2, type2, value2) ->
  pairs = {def: {}, obj: {}}
  pairs.def[field1] = type1
  pairs.def[field2] = type2
  if (value1 != undefined)
    pairs.obj[field1] = value1
  if (value2 != undefined)
    pairs.obj[field2] = value2
  return pairs

verifyPairValid = (test, pair) ->
  res = meta.validate pair.def, pair.obj
  test.ok res == null, res, 'Unexpected errors encountered'

verifyPairInvalid = (test, pair, num) ->
  res = meta.validate pair.def, pair.obj
  test.ok res != null, res, 'Expected errors, but received none'
  test.equal res.length, num, "Invalid number of errors. Expected #{num} but got #{res.length}"

##
# Number tests
##
exports.testNumberWithPositiveNumber = (test) ->
  pair = createPair 'number', 4

  verifyPairValid(test, pair)
  test.done()

exports.testNumberWithNegativeNumber = (test) ->
  pair = createPair 'number', -4

  verifyPairValid(test, pair)
  test.done()

exports.testNumberWithString = (test) ->
  pair = createPair 'number', 'four'

  verifyPairInvalid(test, pair, 1)
  test.done()

exports.testNumberWithDecimal = (test) ->
  pair = createPair 'number', 4.5

  verifyPairValid(test, pair)
  test.done()

##
# String Tests
##
exports.testStringWithString = (test) ->
  pair = createPair 'string', 'Valid string'

  verifyPairValid(test, pair)
  test.done()

exports.testStringWithNumber = (test) ->
  pair = createPair 'string', 4
  verifyPairInvalid(test, pair, 1)
  test.done()

##
# Testing custom function matchers
##
exports.testCustomFunctionSuccessfulMatch = (test) ->
  pair = createPair ((s) -> s == s.toUpperCase()), 'YEAH BUDDY'
  verifyPairValid(test, pair)
  test.done()

exports.testCustomFunctionUnsuccessfulMatch = (test) ->
  pair = createPair ((s) -> s == s.toUpperCase()), 'not ALL caps'
  verifyPairInvalid(test, pair, 1)
  test.done()


##
# Testing regex matchers
##
exports.testRegexSuccessfulMatch = (test) ->
  pair = createPair /[0-9]+\.[0-9]+/, '1232.23'
  verifyPairValid(test, pair)
  test.done()

exports.testRegexUnsuccessfulMatch = (test) ->
  pair = createPair /[0-9]+\.[0-9]+/, 'sad face'
  verifyPairInvalid(test, pair, 1)
  test.done()

exports.testEnumerationSuccessfulMatch = (test) ->
  pair = createPair ['Yes', 'No'], 'Yes'
  verifyPairValid(test, pair)
  test.done()

exports.testEnumerationUnsuccessfulMatch = (test) ->
  pair = createPair ['Yes', 'No'], 'asdf'
  verifyPairInvalid(test, pair, 1)
  test.done()

exports.testNecessaryParametersMissing = (test) ->
  pairs = createTwoPairs 'number', 4, 'string'
  verifyPairInvalid(test, pairs, 1)
  test.done()

exports.testOptionalParametersLeftOut = (test) ->
  pairs = createTwoPairsWithFields 'id', 'number', 4, '$_name', 'string'

  verifyPairValid(test, pairs)
  test.done()

exports.testAdditionalParametersIsInvalid = (test) ->
  pairs = createPair 'number', 4
  pairs.obj.extraField = 'Bob'

  verifyPairInvalid(test, pairs, 1)
  test.done()

exports.testAdditionParameterOverOptional = (test) ->
  pairs = createTwoPairs('number', 4, '$_name')
  pairs.obj.extraField = 'Bob'

  verifyPairInvalid(test, pairs, 2)
  test.done()

exports.testListOfObjects = (test) ->
  pairs =
    def:
      people: [
        name: 'string'
        age: 'number'
      ]
    obj:
      people: [
        name: 'Bob'
        age: 23
      ,
        name: 'Fred'
        age: 53
      ,
        name: 'Jack'
        age: 15
      ]
  verifyPairValid(test, pairs)
  test.done()

exports.testNegativeItemInObjectList = (test) ->
  pairs =
    def:
      people: [
        name: 'string'
        age: 'number'
      ]
    obj:
      people: [
        name: 'Bob'
        age: 23
      ,
        name: 'Fred'
        age: 'N/A'
      ,
        name: 'Jack'
        age: 15
      ]
  verifyPairInvalid(test, pairs, 1)
  test.done()

exports.testNegativeObjectList = (test) ->
  pairs =
    def:
      people: [
        name: 'string'
        age: 'number'
      ]
    obj:
      people: '[ name: "bob", age: 23 ]'
  verifyPairInvalid(test, pairs, 1)
  test.done()


exports.testNestedObjectsPass = (test) ->
  pairs =
    def:
      person:
        name:
          first: 'string'
          middle: 'string'
          last: 'string'
        age: 'number'
    obj:
      person:
        name:
          first: 'Luke'
          middle: 'George'
          last: 'Tsekouras'
        age: 21
  verifyPairValid(test, pairs)
  test.done()

exports.testNestedObjectInvalid = (test) ->
  pairs =
    def:
      person:
        name:
          first: 'string'
          middle: 'string'
          last: 'string'
        age: 'number'
    obj:
      person:
        name:
          first: 'Luke'
          middle: 2
          last: 'Tsekouras'
        age: 21

  verifyPairInvalid(test, pairs, 1)
  test.done()

exports.testNestedObjectsOptionalIncluded = (test) ->
  pairs =
    def:
      person:
        $_name:
          first: 'string'
          $_middle: 'string'
          last: 'string'
        age: 'number'
    obj:
      person:
        name:
          first: 'Luke'
          middle: 'George'
          last: 'Tsekouras'
        age: 21
  verifyPairValid(test, pairs)
  test.done();

exports.testNestedObjectCanIgnoreOptional = (test) ->
  pairs =
    def:
      person:
        $_name:
          first: 'string'
          $_middle: 'string'
          last: 'string'
        age: 'number'
    obj:
      person:
        name:
          first: 'Luke'
          last: 'Tsekouras'
        age: 21
  verifyPairValid(test, pairs)
  test.done();

exports.testNestedObjectOptionalParentSkipped = (test) ->
  pairs =
    def:
      person:
        $_name:
          first: 'string'
          $_middle: 'string'
          last: 'string'
        age: 'number'
    obj:
      person:
        age: 21
  verifyPairValid(test, pairs)
  test.done();

exports.testNestedObjectChildRequiredMissing = (test) ->
  pairs =
    def:
      person:
        $_name:
          first: 'string'
          $_middle: 'string'
          last: 'string'
        age: 'number'
    obj:
      person:
        name:
          middle: 'George'
          last: 'Tsekouras'
        age: 21
  verifyPairInvalid(test, pairs, 1)
  test.done();

exports.testSingleValueValid = (test) ->
  pair =
    def: 'string'
    obj: 'test string'
  verifyPairValid(test, pair)
  test.done()


exports.testSingleValueInvalid = (test) ->
  pair =
    def: 'number'
    obj: 'test string'
  verifyPairInvalid(test, pair, 1)
  test.done()

exports.testArrayValueValid = (test) ->
  pair =
    def: [ 'string' ]
    obj: [ 'one', 'two', 'three' ]
  verifyPairValid(test, pair)
  test.done()

exports.testArrayValueInvalid = (test) ->
  pair =
    def: [ 'number' ]
    obj: [ 'one', 'two', 'three' ]
  verifyPairInvalid(test, pair, 3)
  test.done()