validator = require 'validator'
Q = require 'q'

#
# Wraps around the node-validator check suite so that a series of checks can be lined up and then later executed on a
# number of different inputs.
#
class NodeValidatorWrapper

  constructor: ->

    @_funcs = []

    for name of validator.validators
      @[name] = do (name) -> (args...) ->
        @_funcs.push (check) ->
          check[name](args...)
        return @

  _check: (args...) ->

    try
      check = validator.check(args...)
      for func in @_funcs
        check = func(check)
      return true

    catch e
      return e.message

#
# Returns a NodeValidatorWrapper, ready to help define a chain of node-validator checks
#
@check = -> new NodeValidatorWrapper()

#
# Validate JSON objects by creating a meta object defining the criteria for validity
# By default, all declarations are mandatory, but they can be made optional by prepending the property with $_ (see below)
# Any properties that !!!Finish this sentence?!!!
#
# e.g.
# {
#   dataTypeCheck: 'string'
#   customCheck: (s) -> s.length < 10
#   regexCheck: /^[a-zA-Z0-9]*$/
#   enumeration: [ 'Yes', 'No', 'Maybe' ]
#   $_optionalParameter: 'number'
#   listOfValidatedObjects: [
#     id: 'number'
#     value: 'string'
#   ]
#   listOfEnumeratedObjects: [
#     [ 'left', 'right', 'up', 'down' ]
#   ]
#   listOfNumbers: [
#     'number'
#   ]
#   listOfCustomValidatedStrings: [
#     (s) -> s.length < 10
#   ]
#   nestedObjects:
#     a: 
#       value: 'string'
#     b:
#       value: 'string'
#     $_optionalPart:
#       compulsoryIfAboveIncluded: 'string'
# }
#
@validate = (def, value, errors = [], prequel = '') ->

  # Check if there's a definition
  if !def

    errors.push prequel + ' is not permitted'

  # Check a regex
  else if def instanceof RegExp

    unless def.test value
      errors.push prequel + " must match the regular expression #{def}"

  # Check a data type
  else if typeof def == 'string' or def instanceof String

    unless ( typeof global[def] == 'function' and value instanceof global[def] ) or typeof value == def
      errors.push prequel + " must be of type '#{def}', but was instead value '#{value}' of type '#{value?.constructor.name}'"

  # Handle Arrays
  else if def instanceof Array

    # Array contains enumeration
    if def.length > 1
      unless value in def
        errors.push prequel + " must be one of: #{ def.join ', ' }"

    # Array contains array-of validation
    else if def.length == 1

      unless value instanceof Array
        errors.push prequel + " must be an Array, but was instead of type '#{value?.constructor.name}'"
      else
        for v, i in value
          @validate def[0], v, errors, prequel + "[#{i}]"

  # Custom function check
  else if typeof def == 'function'

    unless def value
      errors.push prequel + ' did not pass validation'

  # Object structure check
  else if typeof def == "object"

    # Go through each property present and validate it
    for key, propValue of value
      @validate def[key] ? def["$_#{key}"], propValue, errors, prequel + "#{ if prequel then "." else "" }#{key}"

    # Check that all expected properties existed
    for key of def

      [optional, key] = key.match( /^(\$_)?(.*)$/ )[1..]

      unless value[key]? or optional?
        errors.push prequel + "#{ if prequel then "." else "" }#{key} is mandatory"

  return if errors.length then errors else null