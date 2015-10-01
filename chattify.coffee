class Parser
    constructor: (content) ->
        @content = content
        @state = 'init'

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

    # convert to markdown
    toMarkdown: ->
        @state = 'toMarkdown'

        # tag all "On...wrote:" occurrences with # symbol
        replacer = (match, offset, string) =>
            match = match.replace /\r?\n/g, ""
            "\n# " + match + "\n"
        @content = @content.replace /On[\s\S]*?wrote(:|;)/g, replacer
        
        this

    # convert to html
    toHTML: ->
        @state = 'toHTML'
        @content = markdown.toHTML @content
        this

    # log to console
    # for debugging only
    log: ->
        console.log [@state, @content].join ":"
        this


# removes all blockquote elements and substitutes them
# for p elements
removeBlockquotes = () =>
    blockquotes = document.getElementsByTagName "blockquote"

    while blockquotes.length > 0
        bq = blockquotes[0]
        bqHtml = bq.innerHTML
        parent = bq.parentNode
        newChild = document.createElement "p"
        newChild.insertAdjacentHTML 'afterbegin', bqHtml
        parent.insertBefore newChild, bq
        parent.removeChild bq
        blockquotes = document.getElementsByTagName "blockquote"


# 1. HTML preprocessing
# remove blockquote elements
removeBlockquotes()

# 2. parse into markdown followed by HTML
# html to text
parser = new Parser document.body.textContent
document.body.innerHTML = parser.
                            cleanIndentation().
                            log().
                            toMarkdown().
                            log().
                            toHTML().
                            content
