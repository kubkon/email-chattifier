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

  it "tests splitting string into substrings containing a From: tag", ->
    parser = new Parser ""
    text = "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015"
    expect(parser.splitByFromTag text).
      toEqual [text]

    text = "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\nCc: c@d.com"
    expect(parser.splitByFromTag text).
      toEqual [text]

    text1 = "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\n ...\n\n "
    text2 = "From:b@c.com\nTo: d@e.com\n"
    expect(parser.splitByFromTag text1 + text2).
      toEqual [text1, text2]

    text1 = "From: a@b.com\nSent: 01/01/2015\n"
    text2 = "From: b@c.com\nTo: a@b.com\nSubject: Something\nDate: 01/01/2015\n"
    expect(parser.splitByFromTag text1 + text2).
      toEqual [text1, text2]

    text1 = " ...\n\n ..."
    text2 = "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\n...\n\n"
    text3 = "From:b@c.com\nTo:z@z.co.uk"
    expect(parser.splitByFromTag text1 + text2 + text3).
      toEqual [text1, text2, text3]

  it "tests replacing From..To.. string into 'On...wrote:'", ->
    parser = new Parser ""
    text = "From: a@b.com\nTo: b@c.com\nDate: 01/01/2015\nSubject: Something\n"
    expect(parser.replaceFromToBlocks text).
      toEqual "On 01/01/2015, a@b.com wrote:\n\n"

    text = "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\n"
    expect(parser.replaceFromToBlocks text).
      toEqual "On 01/01/2015, a@b.com wrote:\n\n"

    text = "From: a@b.com\nTo: b@c.com\nDate: 01/01/2015\nSubject: Something\nHi there,"
    expect(parser.replaceFromToBlocks text).
      toEqual "On 01/01/2015, a@b.com wrote:\n\nHi there,"

    text = "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\n Hi there,"
    expect(parser.replaceFromToBlocks text).
      toEqual "On 01/01/2015, a@b.com wrote:\n\n Hi there,"

    text = "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\nCc: c@d.com\n"
    expect(parser.replaceFromToBlocks text).
      toEqual "On 01/01/2015, a@b.com wrote:\n\n"

    text = "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\nCc: c@d.com\n\n Hi there,"
    expect(parser.replaceFromToBlocks text).
      toEqual "On 01/01/2015, a@b.com wrote:\n\n\n Hi there,"

    text = "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\nCc: c@d.com\n Hi there,\n"
    expect(parser.replaceFromToBlocks text).
      toEqual "On 01/01/2015, a@b.com wrote:\n\n Hi there,\n"

  it "tests removing 'forwarded message' headers", ->
    parser = new Parser ""
    text = "------ Forwarded message: ------\n"
    expect(parser.removeForwardedMsgHeaders text).
      toEqual "\n"

    text = " ------ Forwarded message: ------\n"
    expect(parser.removeForwardedMsgHeaders text).
      toEqual " \n"

    text = "------ Forwarded message: ------ "
    expect(parser.removeForwardedMsgHeaders text).
      toEqual " "

    text = "------ Forwarded message: ------\n"
    expect(parser.removeForwardedMsgHeaders text).
      toEqual "\n"

    text = "- Forwarded message: --\n"
    expect(parser.removeForwardedMsgHeaders text).
      toEqual "\n"

    text = "Begin forwarded message:\n"
    expect(parser.removeForwardedMsgHeaders text).
      toEqual "\n"

    text = " Begin forwarded message:\n"
    expect(parser.removeForwardedMsgHeaders text).
      toEqual " \n"
      
    text = " Begin forwarded message: \n"
    expect(parser.removeForwardedMsgHeaders text).
      toEqual "  \n"

