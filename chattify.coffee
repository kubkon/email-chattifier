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
            match = match.replace /\r?\n/g, " "
            "\n# " + match + "\n"
        @content = @content.replace /On[\s\S]*?wrote(:|;)/g, replacer

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
        console.log [@state, @content].join ":"
        this


# removes all blockquote elements and substitutes them
# for p elements
removeBlockquotes = () =>
    blockquotes = document.body.getElementsByTagName "blockquote"

    while blockquotes.length > 0
        bq = blockquotes[0]
        bqHtml = bq.innerHTML
        parent = bq.parentNode
        newChild = document.createElement "p"
        newChild.insertAdjacentHTML 'afterbegin', bqHtml
        parent.insertBefore newChild, bq
        parent.removeChild bq
        blockquotes = document.body.getElementsByTagName "blockquote"


colorEncode = () =>
    divs = document.body.getElementsByTagName "div"
    classes = ['first', 'second']
    for div, i in divs
        div.className = classes[i % 2]

    # create new stylesheet
    style = document.createElement "style"
    style.appendChild document.createTextNode ""
    document.head.appendChild style

    colors = ['blue', 'red']
    for cl, i in classes
        clStyle = "." + cl + " { display: block; background: " + colors[i] + "; }"
        style.sheet.insertRule clStyle, 0


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
                            log().
                            content

# 3. HTML postprocessing
colorEncode()
