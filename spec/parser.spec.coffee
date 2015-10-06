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

  it "tests matching From...To... blocks", ->
    parser = new Parser ""
    text = "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015"
    expect(parser.matchFromToBlocks text).
      toEqual [0, text.length]

    text = "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\nCc: c@d.com"
    expect(parser.matchFromToBlocks text).
      toEqual [0, text.length]

    text = "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\n"
    n = text.length
    text += " ...\n\n From:b@c.com"
    expect(parser.matchFromToBlocks text).
      toEqual [0, n]

    text1 = "From: a@b.com\n\n"
    text2 = "From: b@c.com\nTo: a@b.com\nSubject: Something\nDate: 01/01/2015\n"
    n = text1.length
    text = text1 + text2
    expect(parser.matchFromToBlocks text).
      toEqual [0, n]

    text1 = " ...\n\n ..."
    text2 = "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\n"
    a = text1.length
    b = text2.length + a
    text = text1 + text2 + " ...\n\n From:b@c.com"
    expect(parser.matchFromToBlocks text).
      toEqual [a, b]

