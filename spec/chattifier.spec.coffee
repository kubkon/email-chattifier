jsdom = require("jsdom").jsdom
Chattifier = require "../src/chattifier.coffee"

describe "A suite of Chattifier tests:", ->
  chattifier = {}
  document = {}
  node = {}

  beforeEach ->
    # create mock documentument
    document = jsdom '<html></html>'
    # create mock node
    node = document.createElement 'div'
    document.body.appendChild node
    # create the Chattifier and add the node
    chattifier = new Chattifier document
    chattifier.ancestorNode = node

  describe "tests whether the immediate parent node of", ->
    beforeEach ->
      # create mock documentument
      document = jsdom '<html></html>'
      # create mock node
      node = document.createElement 'div'
      node.className = 'the-parent'
      document.body.appendChild node
      # create the Chattifier and add the node
      chattifier = new Chattifier document

    it "topmost blockquote element is selected, or", ->
      html = "<blockquote id='top'><blockquote id='inner'></blockquote></blockquote>"
      node.innerHTML = html

      # run chattifier
      chattifier.inferAncestorNode()

      # test
      expect(chattifier.ancestorNode.tagName.toLowerCase()).
        toEqual "div"

      expect(chattifier.ancestorNode.className.toLowerCase()).
        toEqual "the-parent"

    it "the parent of the element containing the text blockquotes of type >...>, or", ->
      html = "<p>>> something\n>> something\n>> something</p>"
      node.innerHTML = html

      # run chattifier
      chattifier.inferAncestorNode()

      # test
      expect(chattifier.ancestorNode.tagName.toLowerCase()).
        toEqual "div"

      expect(chattifier.ancestorNode.className.toLowerCase()).
        toEqual "the-parent"

    it "exits gracefully otherwise", ->
      # run chattifier
      chattifier.inferAncestorNode()

      # test
      expect(chattifier.ancestorNode).
        toEqual null

  describe "tests that any existing hyperlink within the ancestor node", ->
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
    # create mock document containing blockquote elements
    html = "<blockquote><p>Outer blockquote</p>" +
           "<blockquote><p>Inner blockquote</p>" +
           "</blockquote></blockquote>"
    node.innerHTML = html

    # run chattifier
    chattifier.removeBlockquotes()

    # test output
    expect(node.getElementsByTagName("blockquote").length).
      toEqual 0

    html = "<p><p>Outer blockquote</p><p><p>Inner blockquote</p></p></p>"
    expect(node.innerHTML).
      toEqual html

  describe "tests the HTML output should be grouped into divs regardless if", ->
    it "has a header element as the topmost element, or if", ->
      # create mock document of the following structure
      h = "h" + Chattifier.headerStartLevel
      html = "<" + h + "><p>First</p></" + h + ">" +
             "<" + h + "><p>Second</p></" + h + ">"
      node.innerHTML = html

      # run chattifier
      chattifier.groupIntoDivs()

      # test output
      html = '<div class="' + Chattifier.cssAttrs.mainClass + ' ' +
             Chattifier.cssAttrs.alternatingClasses[0] + '"></div>' +
             '<div class="' + Chattifier.cssAttrs.mainClass + ' ' +
             Chattifier.cssAttrs.alternatingClasses[1] + '">' +
             '<' + h + '><p>First</p></' + h + '></div>' +
             '<div class="' + Chattifier.cssAttrs.mainClass + ' ' +
             Chattifier.cssAttrs.alternatingClasses[0] + '">' +
             '<' + h + '><p>Second</p></' + h + '></div>'
      expect(node.innerHTML).
        toEqual html

    it "has a paragraph element as the topmost element", ->
      # create mock document of the following structure
      h = "h" + Chattifier.headerStartLevel
      html = "<p>Zero</p>" +
             "<" + h + "><p>First</p></" + h + ">" +
             "<" + h + "><p>Second</p></" + h + ">"
      node.innerHTML = html

      # run chattifier
      chattifier.groupIntoDivs()

      # test output
      html = '<div class="' + Chattifier.cssAttrs.mainClass + ' ' +
             Chattifier.cssAttrs.alternatingClasses[0] + '">' +
             '<p>Zero</p></div>' +
             '<div class="' + Chattifier.cssAttrs.mainClass + ' ' +
             Chattifier.cssAttrs.alternatingClasses[1] + '">' +
             '<' + h + '><p>First</p></' + h + '></div>' +
             '<div class="' + Chattifier.cssAttrs.mainClass + ' ' +
             Chattifier.cssAttrs.alternatingClasses[0] + '">' +
             '<' + h + '><p>Second</p></' + h + '></div>'
      expect(node.innerHTML).
        toEqual html

