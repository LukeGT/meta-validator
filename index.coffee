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

@verify = (def, value, errors = [], prequel = '') ->

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
          @verify def[0], v, errors, prequel + "[#{i}]"

  # Custom function check
  else if typeof def == 'function'

    unless def value
      errors.push prequel + ' did not pass validation'

  # Object structure check
  else if typeof def == "object"

    # Go through each property present and validate it
    for key, propValue of value
      @verify def[key] ? def["$_#{key}"], propValue, errors, prequel + "#{ if prequel then "." else "" }#{key}"

    # Check that all expected properties existed
    for key of def

      [optional, key] = key.match( /^(\$_)?(.*)$/ )[1..]

      unless value[key]? or optional?
        errors.push prequel + "#{ if prequel then "." else "" }#{key} is mandatory"

  return if errors.length then errors else null
