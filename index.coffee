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

@verify = (def, object, errors = [], prequel = '') ->
  
  # Go through each property present and validate it
  for key, value of object

    [optional, key] = key.match( /^(\$_)?(.*)$/ )[1..]

    test = def[key] ? def["$_#{key}"]

    # Check if there's a definition
    if !test?

      errors.push "#{prequel}property '#{key}' is not permitted"

    # Check a regex
    else if test instanceof RegExp
      
      unless value.match? test
        errors.push "#{prequel}property '#{key}' must match the regular expression #{test}"
    
    # Check a data type
    else if typeof test == 'string' or test instanceof String

      unless ( typeof global[test] == 'function' and value instanceof global[test] ) or typeof value == test
        errors.push "#{prequel}property '#{key}' must be of type '#{test}', but was instead value '#{value}' of type '#{value?.constructor.name}'"
        
    # Handle Arrays
    else if test instanceof Array

      # Array contains enumeration
      if test.length > 1
        unless value in test
          errors.push "#{prequel}property '#{key}' must be one of: #{test.join ', '}"

      else if test.length == 1

        unless value instanceof Array
          errors.push "#{prequel}property '#{key}' must be an Array, but was instead of type '#{value?.constructor.name}'"

        # Array contains meta-data
        if test[0]?.constructor.name == 'Object'

          for v, i in value
            @verify test[0], v, errors, "#{prequel}within property '#{key}' (index #{i}), "

        # Array contains validation data
        else if test.length

          for v, i in value
            @verify {val: test[0]}, {val: v}, errors, "#{prequel}within property '#{key}' (index #{i}), "

    # Custom function check
    else if typeof test == 'function'

      unless test value
        errors.push "#{prequel}property '#{key}' did not pass validation"

    # Check an object
    else if test instanceof Object
      
      @verify test, value, errors, "#{prequel}within property '#{key}', "

  # Check that all expected properties existed
  for key, value of def

    [optional, key] = key.match( /^(\$_)?(.*)$/ )[1..]

    unless object[key]? or optional?
      errors.push "#{prequel}property '#{key}' is mandatory"

  return if errors.length then errors else null
