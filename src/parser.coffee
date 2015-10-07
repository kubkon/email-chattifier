markdown = require("markdown").markdown

class Parser
  constructor: (content) ->
    @state   = 'init'
    @content = content

  # convert to markdown
  toMarkdown: ->
    @state = 'toMarkdown'

    # split into lines and iterate:
    # 1. trim whitespaces
    # 2. remove special quote chars such as ">"
    lines = @content.split /\r?\n/
    cleanedLines = []
    for line in lines
      cleanedLines.push @removeSpecialChars(line.trim()).trim()

    @content = cleanedLines.join "\n"

    # convert From...To... blocks into "On...wrote:"
    blocks = @splitByFromTag @content
    @content = (@replaceFromToBlocks b for b in blocks).join "\n"

    # escape any existing '#' tags not generated by us
    @content = @content.replace /(#)/g, "\\$1"

    # tag all "On...wrote:" occurrences with # symbol
    replacer = (match) =>
      match = match.replace /\r?\n/g, " "
      # remove any unwanted characters and strings
      match = match.replace /([\[\]<>]|mailto:|javascript:;)/g, ""
      # make email addresses into hyperlinks
      match = @emailToHyperlink(match)
      "\n# " + match + "\n"

    @content = @content.replace /On [\s\S]*?wrote(:|;)/g, replacer
    this

  # convert to html
  toHTML: ->
    @state = 'toHTML'

    parsedTree = markdown.toHTMLTree markdown.parse @content
    outputTree = [parsedTree[0], ["div"]]
    i = 1

    for el in parsedTree[1..]
      if el[0] == "h1"
        outputTree.push ["div"]
        i += 1

      outputTree[i].push el

    @content = markdown.renderJsonML outputTree
    this

  # log to console
  # for debugging only
  log: ->
    state = "state: " + @state
    content  = "content: " + @content
    msg = "{ " + ([state, content].join "\n") + " }"
    console.log msg
    this

  emailToHyperlink: (str) ->
    emailRegex = /([a-zA-Z0-9_!#$%&'*+\/=?`{|}~^.-]+@[a-zA-Z0-9.-]+)/
    str.replace emailRegex, "[$1](mailto:$1)"

  removeSpecialChars: (str) ->
    regex = /^(?:>\s*){1,}/
    str.replace regex, ""

  splitByFromTag: (str) ->
    mainRegex = /From:[\s\S]*?(To|Subject|Date|Cc|Sent):/g
    substrings = []
    matchIndices = (match.index while match = mainRegex.exec str)

    # check if zero index in the array
    if 0 not in matchIndices
      matchIndices.splice 0, 0, 0

    # add the last index to the array
    matchIndices.push str.length

    for i in [0...matchIndices.length-1]
      substrings.push str[matchIndices[i]...matchIndices[i+1]]

    return substrings

  replaceFromToBlocks: (str) ->
    blockRegex = /From:([\s\S]*?(To|Subject|Date|Cc|Sent):){3,}.*\n/

    replacer = (match) =>
      match = match.replace /\r?\n/g, " "
      from = (/From:(.*?)(To|Subject|Date|Cc|Sent):/.exec match)[1].trim()
      dateMatch = /(Date|Sent):(.*?)(To|Subject|Cc):/.exec match
      dateMatch ?= /(Date|Sent):(.*)/.exec match
      date = dateMatch[2].trim()
      "On " + date + ", " + from + " wrote:\n\n"

    str.replace blockRegex, replacer


module.exports = Parser

