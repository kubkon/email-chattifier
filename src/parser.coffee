markdown = require("markdown").markdown

class Parser
  constructor: (content) ->
    @state   = 'init'
    @content = content

  # removes spurious indentation and any special
  # block quote characters such as ">"
  cleanIndentation: ->
    @state = 'cleanIndentation'

    # split into lines and iterate:
    # 1. trim whitespaces
    # 2. remove special quote chars such as ">"
    lines = @content.split /\r?\n/
    cleanedLines = []
    for line in lines
      cleanedLines.push line.trim().replace(/^(?:>\s*){1,}/, "").trim()

    @content = cleanedLines.join "\n"
    this

  # strip From...To... blocks
  stripFromToBlocks: ->
    @state = 'stripFromToBlocks'

    blockRegex = ///From:
      [\s\S]*?(To|Subject|Date|Cc|Sent):
      [\s\S]*?(To|Subject|Date|Cc|Sent):
      [\s\S]*?(To|Subject|Date|Cc|Sent):
      [\s\S]*?(To|Subject|Date|Cc|Sent):
      (.*\n){1,2}
    ///g

    replacer = (match, offset, string) =>
      match = match.replace /\r?\n/g, " "
      from = (/From:(.*?)(To|Subject|Date|Cc|Sent):/g.exec match)[1].trim()
      date = (/(Date|Sent):(.*?)(To|Subject|Cc):/g.exec match)[2].trim()
      "On " + date + ", " + from + " wrote:\n\n"

    @content = @content.replace blockRegex, replacer
    this

  # convert to markdown
  toMarkdown: ->
    @state = 'toMarkdown'

    # escape any existing '#' tags not generated by us
    @content = @content.replace /(#)/g, "\\$1"

    # tag all "On...wrote:" occurrences with # symbol
    replacer = (match, offset, string) =>
      match = match.replace /\r?\n/g, " "
      # remove any unwanted characters and strings
      match = match.replace /([\[\]<>]|mailto:|javascript:;)/g, ""
      # make email addresses into hyperlinks
      emailRegex = /([a-zA-Z0-9_!#$%&'*+\/=?`{|}~^.-]+@[a-zA-Z0-9.-]+)/
      match = match.replace emailRegex, "[$1](mailto:$1)"
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


module.exports = Parser

