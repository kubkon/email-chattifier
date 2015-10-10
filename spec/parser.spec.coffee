Parser = require "../src/parser.coffee"

describe "Test Parser class", ->
  parser = {}

  it "tests email formatting", ->
    parser = new Parser ""
    testData = [
      {
        input: "John Doe john.doe@abc.com wrote",
        expected: "John Doe [john.doe@abc.com](mailto:john.doe@abc.com) wrote"
      },
      {
        input: "John Doe johndoe@abc.co.uk wrote",
        expected: "John Doe [johndoe@abc.co.uk](mailto:johndoe@abc.co.uk) wrote"
      },
      {
        input: "John Doe john_doe@abc.com wrote",
        expected: "John Doe [john_doe@abc.com](mailto:john_doe@abc.com) wrote"
      },
      {
        input: "John Doe john-doe@abc.com wrote",
        expected: "John Doe [john-doe@abc.com](mailto:john-doe@abc.com) wrote"
      }
    ]
    for t in testData
      expect(parser.emailToHyperlink t.input).
        toBe t.expected

  it "tests removing special chars", ->
    parser = new Parser ""
    testData = [
      {
        input: ">",
        expected: ""
      },
      {
        input: ">>",
        expected: ""
      },
      {
        input: "> >",
        expected: ""
      },
      {
        input: "> >>",
        expected: ""
      },
      {
        input: ">> >",
        expected: ""
      },
      {
        input: ">>>",
        expected: ""
      },
      {
        input: " >",
        expected: " >"
      }
    ]
    for t in testData
      expect(parser.removeSpecialChars t.input).
        toBe t.expected

  it "tests splitting string into substrings containing a From: tag", ->
    parser = new Parser ""
    testData = [
      {
        input: "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015",
        expected: ["From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015"]
      },
      {
        input: "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\nCc: c@d.com",
        expected: ["From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\nCc: c@d.com"]
      },
      {
        input: "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\n ...\n\n From:b@c.com\nTo: d@e.com\n",
        expected: ["From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\n ...\n\n ",
                   "From:b@c.com\nTo: d@e.com\n"]
      },
      {
        input: "From: a@b.com\nSent: 01/01/2015\nFrom: b@c.com\nTo: a@b.com\nSubject: Something\nDate: 01/01/2015\n",
        expected: ["From: a@b.com\nSent: 01/01/2015\n",
                   "From: b@c.com\nTo: a@b.com\nSubject: Something\nDate: 01/01/2015\n"]
      },
      {
        input: " ...\n\n ...From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\n...\n\nFrom:b@c.com\nTo:z@z.co.uk",
        expected: [" ...\n\n ...",
                   "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\n...\n\n",
                   "From:b@c.com\nTo:z@z.co.uk"]
      }
    ]
    for t in testData
      expect(parser.splitByFromTag t.input).
        toEqual t.expected

  it "tests replacing From..To.. string into 'On...wrote:'", ->
    parser = new Parser ""
    testData = [
      {
        input: "From: a@b.com\nTo: b@c.com\nDate: 01/01/2015\nSubject: Something\n",
        expected: "On 01/01/2015, a@b.com wrote:\n\n"
      },
      {
        input: "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\n",
        expected: "On 01/01/2015, a@b.com wrote:\n\n"
      },
      {
        input: "From: a@b.com\nTo: b@c.com\nDate: 01/01/2015\nSubject: Something\nHi there,",
        expected: "On 01/01/2015, a@b.com wrote:\n\nHi there,"
      },
      {
        input: "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\n Hi there,",
        expected: "On 01/01/2015, a@b.com wrote:\n\n Hi there,"
      },
      {
        input: "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\nCc: c@d.com\n",
        expected: "On 01/01/2015, a@b.com wrote:\n\n"
      },
      {
        input: "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\nCc: c@d.com\n\n Hi there,",
        expected: "On 01/01/2015, a@b.com wrote:\n\n\n Hi there,"
      },
      {
        input: "From: a@b.com\nTo: b@c.com\nSubject: Something\nDate: 01/01/2015\nCc: c@d.com\n Hi there,\n",
        expected: "On 01/01/2015, a@b.com wrote:\n\n Hi there,\n"
      }
    ]
    for t in testData
      expect(parser.replaceFromToBlocks t.input).
        toEqual t.expected

  it "tests removing 'forwarded message' headers", ->
    parser = new Parser ""
    testData = [
      {
        input: "------ Forwarded message ------\n",
        expected: "\n"
      },
      {
        input: " ------ Forwarded message ------\n",
        expected: " \n"
      },
      {
        input: "------ Forwarded message ------ ",
        expected: " "
      },
      {
        input: "------ Forwarded message ------\n",
        expected: "\n"
      },
      {
        input: "- Forwarded message --\n",
        expected: "\n"
      },
      {
        input: "Begin forwarded message:\n",
        expected: "\n"
      },
      {
        input: " Begin forwarded message:\n",
        expected: " \n"
      },
      {
        input: " Begin forwarded message: \n",
        expected: "  \n"
      }
    ]
    for t in testData
      expect(parser.removeForwardedMsgHeaders t.input).
        toEqual t.expected

  it "tests stripping email signatures within a string", ->
    parser = new Parser ""
    testData = [
      {
        input: "Hi there,\nHow are you?\n Best,\n John\n\n-- JD\nCEO & CEO\n\n",
        expected: "Hi there,\nHow are you?\n Best,\n John\n\n"
      },
      {
        input: "Hi there,\nHow are you?\n Best,\n John-- JD\nCEO & CEO\n\n",
        expected: "Hi there,\nHow are you?\n Best,\n John"
      },
      {
        input: "Hi there,\nHow are you?\n Best,\n John -- JD\nCEO & CEO\n\n",
        expected: "Hi there,\nHow are you?\n Best,\n John "
      },
      {
        input: "Hi there,\nHow are you?\n Best,\n John--JD\nCEO & CEO\n\n",
        expected: "Hi there,\nHow are you?\n Best,\n John"
      },
      {
        input: "Hi there,\nHow are you?\n Best,\n John--\nJD\nCEO & CEO\n\n",
        expected: "Hi there,\nHow are you?\n Best,\n John"
      },
      {
        input: "Hi there,\nHow are you?\n Best,\n John\nSent from my iPhone\n--\nJD\nCEO & CEO\n\n",
        expected: "Hi there,\nHow are you?\n Best,\n John\n"
      },
      {
        input: "Hi there,\nHow are you?\n Best,\n JohnSent from my iPhone\n--\nJD\nCEO & CEO\n\n",
        expected: "Hi there,\nHow are you?\n Best,\n John"
      },
      {
        input: "Hi there,\nHow are you?\n Best,\n JohnSent from\nmy iPhone\n--\nJD\nCEO & CEO\n\n",
        expected: "Hi there,\nHow are you?\n Best,\n John"
      },
      {
        input: "Hi there,\nHow are you?\n Best,\n John Sent from\n Outlook\n--\nJD\nCEO & CEO\n\n",
        expected: "Hi there,\nHow are you?\n Best,\n John "
      },
      {
        input: "Hi there,\nHow are you?\n Best,\n JohnSent from Outlook\n--\nJD\nCEO & CEO\n\n",
        expected: "Hi there,\nHow are you?\n Best,\n John"
      },
      {
        input: "Hi there,\nHow are you?\n Best,\n -JohnSent from Outlook\n--\nJD\nCEO & CEO\n\n",
        expected: "Hi there,\nHow are you?\n Best,\n -John"
      }
    ]
    for t in testData
      expect(parser.stripEmailSignatures t.input).
        toEqual t.expected

