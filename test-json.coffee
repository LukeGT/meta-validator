jsonChecker = require '../json-checker'

testCases = [

  name: 'Positive number'
  def:
    id: 'number'
  obj:
    id: 4
  check: (res) -> res == null
,

  name: 'Negative number'
  def:
    id: 'number'
  obj:
    id: 'Not a number'
  check: (res) -> res != null
,

  name: 'Positive string'
  def:
    name: 'string'
  obj:
    name: 'Mr. Jackson'
  check: (res) -> res == null
,

  name: 'Negative string'
  def:
    name: 'string'
  obj:
    name: [ 'Not a string' ]
  check: (res) -> res != null
,

  name: 'Positive custom func'
  def:
    caps: (s) -> s == s.toUpperCase()
  obj:
    caps: 'YEAH BUDDY'
  check: (res) -> res == null
,

  name: 'Negative custom func'
  def:
    caps: (s) -> s == s.toUpperCase()
  obj:
    caps: 'yeah buddy'
  check: (res) -> res != null
,

  name: 'Positive regex'
  def:
    float: /[0-9]+\.[0-9]+/
  obj:
    float: '1232.23'
  check: (res) -> res == null
,

  name: 'Negative regex'
  def:
    float: /[0-9]+\.[0-9]+/
  obj:
    float: ':)'
  check: (res) -> res != null
,

  name: 'Positive enumeration'
  def:
    answer: [ 'Yes', 'No' ]
  obj:
    answer: 'No'
  check: (res) -> res == null
,

  name: 'Negative enumeration'
  def:
    answer: [ 'Yes', 'No' ]
  obj:
    answer: 'Maybe'
  check: (res) -> res != null
,

  name: 'Positive necessary parameters'
  def:
    id: 'number'
    name: 'string'
  obj:
    id: 4
    name: 'Mr. Dickson'
  check: (res) -> res == null
,

  name: 'Negative necessary parameters'
  def:
    id: 'number'
    name: 'string'
  obj:
    id: 4
  check: (res) -> res != null
,

  name: 'Left out optional parameters'
  def:
    id: 'number'
    $_name: 'string'
  obj:
    id: 4
  check: (res) -> res == null
,

  name: 'Included optional parameters'
  def:
    id: 'number'
    $_name: 'string'
  obj:
    id: 4
    name: 'string'
  check: (res) -> res == null
,

  name: 'Include illegal parameter'
  def:
    id: 'number'
    name: 'string'
  obj:
    id: 4
    name: 'Bob'
    fullname: 'A joke'
  check: (res) -> res != null
,

  name: 'Include illegal parameter over optional parameter'
  def:
    id: 'number'
    $_name: 'string'
  obj:
    id: 4
    fullname: 'A joke'
  check: (res) -> res != null
,

  name: 'Positive list of objects'
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
  check: (res) -> res == null
,

  name: 'Negative item in list of objects'
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
  check: (res) -> res != null
,

  name: 'Negative list of objects'
  def:
    people: [
      name: 'string'
      age: 'number'
    ]
  obj:
    people: '[ name: "bob", age: 23 ]'
  check: (res) -> res != null
,

  name: 'Positive nested objects'
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
  check: (res) -> res == null
,

  name: 'Negative nested objects'
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
        middle: null
        last: 'Tsekouras'
      age: 21
  check: (res) -> res != null
,

  name: 'Positive nested objects with optional included'
  def:
    person:
      name:
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
  check: (res) -> res == null
,

  name: 'Positive nested objects with optional removed'
  def:
    person:
      name:
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
  check: (res) -> res == null
,

  name: 'Positive nested objects with optional object included and internal option included'
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
  check: (res) -> res == null
,

  name: 'Positive nested objects with optional object included, internal option removed'
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
  check: (res) -> res == null
,

  name: 'Positive nested objects with optional object removed'
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
  check: (res) -> res == null
,

  name: 'Negative nested objects with optional object included and compulsory property removed'
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
  check: (res) -> res != null
]

for t in testCases
  res = jsonChecker.verify t.def, t.obj
  pass = t.check res
  if pass
    console.log "PASS: #{ t.name }"
  else
    console.log "FAIL: #{ t.name }"
    console.log "\t#{ res }"
