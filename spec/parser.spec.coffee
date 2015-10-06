Parser = require "../src/parser.coffee"

describe "Test Parser class", ->
  parser = {}

  it "tests email formatting", ->
    parser = new Parser ""
    expect(parser.emailToHyperlink "John Doe john.doe@abc.com wrote").
      toBe "John Doe [john.doe@abc.com](mailto:john.doe@abc.com) wrote"

    expect(parser.emailToHyperlink "John Doe johndoe@abc.co.uk wrote").
      toBe "John Doe [johndoe@abc.co.uk](mailto:johndoe@abc.co.uk) wrote"

    expect(parser.emailToHyperlink "John Doe john_doe@abc.com wrote").
      toBe "John Doe [john_doe@abc.com](mailto:john_doe@abc.com) wrote"

    expect(parser.emailToHyperlink "John Doe john-doe@abc.com wrote").
      toBe "John Doe [john-doe@abc.com](mailto:john-doe@abc.com) wrote"

  it "tests removing special chars", ->
    parser = new Parser ""
    expect(parser.removeSpecialChars ">").
      toBe ""

    expect(parser.removeSpecialChars ">>").
      toBe ""

    expect(parser.removeSpecialChars "> >").
      toBe ""

    expect(parser.removeSpecialChars "> >>").
      toBe ""

    expect(parser.removeSpecialChars ">> >").
      toBe ""

    expect(parser.removeSpecialChars ">>>").
      toBe ""

    expect(parser.removeSpecialChars " >").
      toBe " >"

