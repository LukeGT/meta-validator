meta = require '../index.coffee'

exports.basicCheckPositive = (test) ->

  check = meta.check().isInt()

  result = check._check(43)
  test.ok result == true, "Unexpected failure"

  test.done()

exports.basicCheckNegative = (test) ->

  check = meta.check().isInt()

  result = check._check("string")
  test.ok result != true, "Unexpected success"

  test.done()

exports.checkMultipleTimes = (test) ->

  check = meta.check().regex(/^[a-z]*$/)

  result = check._check("something")
  test.ok result == true, "Unexpected failure"

  result = check._check("23432")
  test.ok result != true, "Unexpected success"

  result = check._check("goodagain")
  test.ok result == true, "Unexpected failure"

  test.done()

exports.chainedChecks = (test) ->

  check = meta.check().isEmail().contains("lawl").regex(/[0-9]{2}/)

  result = check._check("not an email")
  test.ok result != true, "Unexpected success"
  test.equal result, "Invalid email", "Incorrect error"

  result = check._check("i.dont.have@the.secret.word")
  test.ok result != true, "Unexpected success"
  test.equal result, "Invalid characters", "Incorrect error"

  result = check._check("lawl@lawl.com")
  test.ok result != true, "Unexpected success"
  test.equal result, "Invalid characters", "Incorrect error"

  result = check._check("lawl69@lawl.com")
  test.ok result == true, "Unexpected failure"

  test.done()

exports.multipleArguments = (test) ->

  check = meta.check().len(3, 5)

  result = check._check("1")
  test.ok result != true, "Unexpected success"
  test.equal result, "String is not in range", "Incorrect error"

  result = check._check("1234")
  test.ok result == true, "Unexpected failure"

  result = check._check("123456")
  test.ok result != true, "Unexpected success"
  test.equal result, "String is not in range", "Incorrect error"

  test.done()