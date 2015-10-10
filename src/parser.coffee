markdown = require("markdown").markdown

class Parser
  constructor: (content) ->
    @content = content

  # convert content into markdown
  parse: ->
    # split into lines and iterate:
    # 1. trim whitespaces
    # 2. remove special quote chars such as ">"
    lines = @content.split /\r?\n/
    @content = (@removeSpecialChars(l.trim()).trim() for l in lines).join "\n"

    # remove "forwarded message"-type headers
    @content = @removeForwardedMsgHeaders @content

    # convert From...To... blocks into "On...wrote:"
    blocks = @splitByFromTag @content
    @content = (@replaceFromToBlocks b for b in blocks).join "\n"

    # escape any existing '#' tags not generated by us
    @content = @content.replace /(#)/g, "\\$1"

    # tag all "On...wrote:" occurrences with # symbol
    @content = @content.replace /On [\s\S]*?wrote(:|;)/g, (match) =>
      match = match.replace /\r?\n/g, " "
      # remove any unwanted characters and strings
      match = match.replace /([\[\]<>]|mailto:|javascript:;)/g, ""
      # make email addresses into hyperlinks
      match = @emailToHyperlink(match)
      "\n# " + match + "\n"

  # convert content into html
  toHTML: (cssClass) ->
    parsedTree = markdown.toHTMLTree markdown.parse @content
    outputTree = [parsedTree[0], ["div", { class: cssClass }]]
    count = 1

    for el in parsedTree[1..]
      if el[0] == "h1"
        outputTree.push ["div", { class: cssClass }]
        count += 1

      outputTree[count].push el

    # console.log markdown.renderJsonML outputTree
    markdown.renderJsonML outputTree

  # convert email to a hyperlink
  emailToHyperlink: (str) ->
    emailRegex = /([a-zA-Z0-9_!#$%&'*+\/=?`{|}~^.-]+@[a-zA-Z0-9.-]+)/

    str.replace emailRegex, "[$1](mailto:$1)"

  # remove special blockquote characters
  removeSpecialChars: (str) ->
    str.replace /^(?:>\s*){1,}/, ""

  # split text content into substrings such that each substring
  # contains at most one "From...To..." block
  splitByFromTag: (str) ->
    mainRegex = /From:[\s\S]*?(To|Subject|Date|Cc|Sent):/g
    indices = (match.index while match = mainRegex.exec str)

    # check if zero index in the array
    if 0 not in indices
      indices.splice 0, 0, 0

    # add the last index to the array
    indices.push str.length

    (str[indices[i]...indices[i+1]] for i in [0...indices.length-1])

  # replace "From...To..." blocks with one-liners "On...wrote:"
  replaceFromToBlocks: (str) ->
    blockRegex = /From:([\s\S]*?(To|Subject|Date|Cc|Sent):){3,}.*\n/

    str.replace blockRegex, (match) ->
      match = match.replace /\r?\n/g, " "
      from = (/From:(.*?)(To|Subject|Date|Cc|Sent):/.exec match)[1].trim()
      dateMatch = /(Date|Sent):(.*?)(To|Subject|Cc):/.exec match
      dateMatch ?= /(Date|Sent):(.*)/.exec match
      date = dateMatch[2].trim()
      "On " + date + ", " + from + " wrote:\n\n"

  # remove "Forwarded message"-type headers
  removeForwardedMsgHeaders: (str) ->
    regex = /(-+ Forwarded message -+|Begin forwarded message:)([\s\n]+)/g

    str.replace regex, "$2"


module.exports = Parser

