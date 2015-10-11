Parser = require "./Parser.js"

class Chattifier
  @headerStartLevel = 4

  constructor: ->
    @ancestorNode = null

  # rerender the email conversation
  renderHTML: ->
    # infer the ancestor node
    @inferAncestorNode()

    if not @ancestorNode?
      return false

    # preprocess HTML
    @escapeHyperlinks()
    @insertNewLinesIntoDivsAndSpans()
    @removeBlockquotes()
      
    # parse the text content into Markdown
    parser = new Parser @ancestorNode.textContent
    parser.parse()
    @ancestorNode.innerHTML = parser.toHTML Chattifier.headerStartLevel

    # postprocess HTML
    @groupInDivs()
    @colorEncode()

    return true
      
  # infers the ancestor (top most) node of the email conversation
  inferAncestorNode: ->
    # check if blockquote exist, and get their
    # parent if they do
    blockquotes = document.body.getElementsByTagName "blockquote"
    if blockquotes.length > 0
      @ancestorNode = blockquotes[0].parentNode
      return

    # don't give up just yet; check for special indendation
    # characters such as ">" and get the parentNode of their
    # element
    allElements = Array.prototype.slice.call document.body.getElementsByTagName "*"
    searchedEl = []
    scores = []
    for el in allElements.reverse()
      searchedEl.push el
      score = 0
      for line in el.textContent.split /\r?\n/
        if line.match /^(?:>\s*){2,}/
          score += 1

      scores.push score

    maxEl = Math.max.apply null, scores
    if maxEl > 0
      @ancestorNode = searchedEl[scores.indexOf maxEl].parentNode
      return
  
  # escape existing hyperlinks into Markdown format [...](...)
  # note that currently ignores any tags with "mailto:" protocol
  escapeHyperlinks: ->
    for link in @ancestorNode.getElementsByTagName "a"
      if link.protocol != "mailto:"
        text = "[" + link.innerText + "](" + link.innerText + ")"
        link.innerText = text

  # inserts new line characters at the end of each
  # div and span element within the email trace
  insertNewLinesIntoDivsAndSpans: ->
    divs = @ancestorNode.getElementsByTagName "div"
    for div in divs
      div.appendChild document.createTextNode "\n\n"

    spans = @ancestorNode.getElementsByTagName "span"
    for span in spans
      span.appendChild document.createTextNode "\n\n"

  # removes all blockquote elements and substitutes them
  # for p elements
  removeBlockquotes: ->
    blockquotes = @ancestorNode.getElementsByTagName "blockquote"

    while blockquotes.length > 0
      bq = blockquotes[0]
      bqHtml = bq.innerHTML
      parent = bq.parentNode
      newChild = document.createElement "p"
      newChild.insertAdjacentHTML 'afterbegin', bqHtml
      parent.insertBefore newChild, bq
      parent.removeChild bq
      blockquotes = @ancestorNode.getElementsByTagName "blockquote"

  groupInDivs: ->
    headerTag = "h" + Chattifier.headerStartLevel
    divs = [document.createElement "div"]
    count = 0
    
    for child in @ancestorNode.children
      if child.tagName.toLowerCase() == headerTag
        divs.push document.createElement "div"
        count += 1

      divs[count].appendChild child.cloneNode true

    # remove all children from the ancestor node
    while @ancestorNode.hasChildNodes()
      @ancestorNode.removeChild @ancestorNode.lastChild

    # re-populate the ancestor with new children
    # and CSS classes
    classes = ['first', 'second']
    for div, i in divs
      div.className = "chattifier " + classes[i % 2]
      @ancestorNode.appendChild div

  # creates a new stylesheet for color encoding of the
  # generated blocks, and applies some rudimentary CSS
  colorEncode: ->
    style = document.createElement "style"
    style.appendChild document.createTextNode ""
    document.head.appendChild style

    style.sheet.insertRule "div.chattifier { margin: 2px; display: block; }", 0
    colors = ['#FFF', '#F4F4F4']
    classes = ['first', 'second']
    for cl, i in classes
      clStyle = ".chattifier." + cl + " { background-color: " + colors[i] + "; }"
      style.sheet.insertRule clStyle, 0


module.exports = Chattifier

