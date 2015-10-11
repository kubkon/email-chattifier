jsdom = require("jsdom").jsdom
Chattifier = require "../src/chattifier.coffee"

describe "A suite of Chattifier tests", ->
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

  describe "any existing hyperlink within the ancestor node", ->
    it "should be escaped before parsing content", ->
      links = [
        'www.google.com',
        'http://www.google.com',
        'https://www.google.com',
        'http://google.com',
        'https://google.com',
        'https://google.com/0/12398sf',
        'https://chrome.google.com/webstore/detail/e-c/abcdefghijkslme?utm_source=gmail'
      ]
      # generate links of different structure
      for link in links
        a = doc.createElement 'a'
        a.href = link
        a.innerText = link
        node.appendChild a

      # run chattifier
      chattifier.escapeHyperlinks()

      # test output
      for a, i in node.getElementsByTagName "a"
        expect(a.innerText).
          toEqual "[" + links[i] + "](" + links[i] + ")"

    it "unless it is an email address", ->
      a = doc.createElement 'a'
      link = 'john.doe@johnny.com'
      a.href = 'mailto:' + link
      a.innerText = link
      node.appendChild a

      # run chattifier
      chattifier.escapeHyperlinks()

      # test output
      expect(a.innerText).
        toEqual link

