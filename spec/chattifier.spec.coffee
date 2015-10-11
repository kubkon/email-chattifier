jsdom = require("jsdom").jsdom
Chattifier = require "../src/chattifier.coffee"

describe "A suite of Chattifier tests", ->
  chattifier = {}
  document = {}
  node = {}

  beforeEach ->
    # create mock documentument
    document = jsdom '<body></body>'
    # create mock node
    node = document.createElement 'div'
    # create the Chattifier and add the node
    chattifier = new Chattifier document
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
        a = document.createElement 'a'
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
      a = document.createElement 'a'
      link = 'john.doe@johnny.com'
      a.href = 'mailto:' + link
      a.innerText = link
      node.appendChild a

      # run chattifier
      chattifier.escapeHyperlinks()

      # test output
      expect(a.innerText).
        toEqual link

  it "tests removing blockquote elements and preserving its HTML content", ->
    # create mock documentument containing blockquote elements
    # outer blockquote
    bq1 = document.createElement 'blockquote'
    p = document.createElement 'p'
    p.textContent = 'Outer blockquote'
    bq1.appendChild p
    # inner blockquote
    bq2 = document.createElement 'blockquote'
    p = document.createElement 'p'
    p.textContent = 'Inner blockquote'
    bq2.appendChild p
    bq1.appendChild bq2
    node.appendChild bq1

    # sanity test
    html = "<blockquote><p>Outer blockquote</p><blockquote><p>Inner blockquote</p></blockquote></blockquote>"
    expect(node.innerHTML).
      toEqual html

    # run chattifier
    chattifier.removeBlockquotes()

    # test output
    expect(node.getElementsByTagName("blockquote").length).
      toEqual 0

    html = "<p><p>Outer blockquote</p><p><p>Inner blockquote</p></p></p>"
    expect(node.innerHTML).
      toEqual html

