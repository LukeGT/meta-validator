jsonChecker = require '../index.coffee'

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

verifyPairValid = (pair) ->
  res = jsonChecker.verify pair.def, pair.obj
  res == null

verifyPairInvalid = (pair) ->
  !verifyPairValid(pair)

##
# Number tests
##
exports.testNumberWithPositiveNumber = (test) ->
  pair = createPair 'number', 4

  test.ok verifyPairValid(pair)
  test.done()

exports.testNumberWithNegativeNumber = (test) ->
  pair = createPair 'number', -4

  test.ok verifyPairValid(pair)
  test.done()

exports.testNumberWithString = (test) ->
  pair = createPair 'number', 'four'

  test.ok verifyPairInvalid(pair)
  test.done()

# TODO: Find out whether decimals should pass?
exports.testNumberWithDecimal = (test) ->
  pair = createPair 'number', 4.5

  test.ok verifyPairValid(pair)
  test.done()

##
# String Tests
##
exports.testStringWithString = (test) ->
  pair = createPair 'string', 'Valid string'

  test.ok verifyPairValid(pair)
  test.done()

exports.testStringWithNumber = (test) ->
  pair = createPair 'string', 4
  test.ok verifyPairInvalid(pair)
  test.done()

##
# Testing custom function matchers
##
exports.testCustomFunctionSuccessfulMatch = (test) ->
  pair = createPair ((s) -> s == s.toUpperCase()), 'YEAH BUDDY'
  test.ok verifyPairValid(pair)
  test.done()

exports.testCustomFunctionUnsuccessfulMatch = (test) ->
  pair = createPair ((s) -> s == s.toUpperCase()), 'not ALL caps'
  test.ok verifyPairInvalid(pair)
  test.done()


##
# Testing regex matchers
##
exports.testRegexSuccessfulMatch = (test) ->
  pair = createPair /[0-9]+\.[0-9]+/, '1232.23'
  test.ok verifyPairValid(pair)
  test.done()

exports.testRegexUnsuccessfulMatch = (test) ->
  pair = createPair /[0-9]+\.[0-9]+/, 'sad face'
  test.ok verifyPairInvalid(pair)
  test.done()

exports.testEnumerationSuccessfulMatch = (test) ->
  pair = createPair ['Yes', 'No'], 'Yes'
  test.ok verifyPairValid(pair)
  test.done()

exports.testEnumerationUnsuccessfulMatch = (test) ->
  pair = createPair ['Yes', 'No'], 'asdf'
  test.ok verifyPairInvalid(pair)
  test.done()

exports.testNecessaryParametersMissing = (test) ->
  pairs = createTwoPairs 'number', 4, 'string'
  test.ok verifyPairInvalid(pairs)
  test.done()

exports.testOptionalParametersLeftOut = (test) ->
  pairs = createTwoPairsWithFields 'id', 'number', 4, '$_name', 'string'

  test.ok verifyPairValid(pairs)
  test.done()

exports.testAdditionalParametersIsInvalid = (test) ->
  pairs = createPair 'number', 4
  pairs.obj.extraField = 'Bob'

  test.ok verifyPairInvalid(pairs)
  test.done()

exports.testAdditionParameterOverOptional = (test) ->
  pairs = createTwoPairs('number', 4, '$_name')
  pairs.obj.extraField = 'Bob'

  test.ok verifyPairInvalid(pairs)
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
  test.ok verifyPairValid(pairs)
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

  test.ok verifyPairInvalid(pairs)
  test.done()