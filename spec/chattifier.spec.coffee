jsdom = require("jsdom").jsdom
Chattifier = require "../src/chattifier.coffee"

describe "Test Chattifier class", ->
  chattifier = {}
  doc = {}
  node = {}

  beforeEach ->
    # create mock document
    doc = jsdom '<body></body>'
    # create mock node
    node = doc.createElement 'div'
    # create the Chattifier and add the node
    chattifier = new Chattifier()
    chattifier.ancestorNode = node

  it "tests escaping hyperlinks", ->
    a = doc.createElement 'a'
    link = 'https://mail.google.com/0/12398sf'
    a.innerText = link
    node.appendChild a

    chattifier.escapeHyperlinks()

    for a in node.getElementsByTagName "a"
      expect(a.innerText).
        toEqual "[" + link + "](" + link + ")"

