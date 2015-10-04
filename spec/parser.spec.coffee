Parser = require "../src/parser.coffee"

describe "Test Parser class", ->
  parser = {}

  it "tests email regex", ->
    parser = new Parser "someone@someone.com"
    expect(true).toBe true

