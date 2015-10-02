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

        # tag all "On...wrote:" occurrences with # symbol
        replacer = (match, offset, string) =>
            match = match.replace /\r?\n/g, " "
            # remove any unwanted characters and strings
            match = match.replace /([\[\]<>]|mailto:|javascript:;)/g, ""
            # make email addresses into hyperlinks
            emailRegex = /([a-zA-Z0-9_!#$%&'*+\/=?`{|}~^.-]+@[a-zA-Z0-9.-]+)/
            match = match.replace emailRegex, "[$1](mailto:$1)"
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


# inserts new line characters at the end of each
# div and span element within the email trace
insertNewLines = () =>
    divs = document.body.getElementsByTagName "div"
    for div in divs
        div.appendChild document.createTextNode "\n\n"

    spans = document.body.getElementsByTagName "span"
    for span in spans
        span.appendChild document.createTextNode "\n\n"


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


# creates a new stylesheet for color encoding of the
# generated blocks, and applies some rudimentary CSS
colorEncode = () =>
    divs = document.body.getElementsByTagName "div"
    classes = ['first', 'second']
    for div, i in divs
        div.className = classes[i % 2]

    # create new stylesheet
    style = document.createElement "style"
    style.appendChild document.createTextNode ""
    document.head.appendChild style

    style.sheet.insertRule "h1 { margin-bottom: 4px;
                                font-size: 15px;
                                font-family: Georgia,'Times New Roman','Bitstream Charter',Times,serif; }", 0
    style.sheet.insertRule "p { margin: 2px;
                                font-size: 15px;
                                font-family: Arial,'Bitstream Vera Sans',Helvetica,Verdana,sans-serif; }", 0
    style.sheet.insertRule "div { margin: 2px; }", 0

    colors = ['#D3D3D3', '#A9A9A9']
    for cl, i in classes
        clStyle = "." + cl + " { display: block; background-color: " + colors[i] + "; }"
        style.sheet.insertRule clStyle, 0


# 1. HTML preprocessing
# insert new lines after div and span elements
# to account for poorly formatted web pages
insertNewLines()

# remove blockquote elements
removeBlockquotes()

# 2. parse into markdown followed by HTML
# html to text
parser = new Parser document.body.textContent
document.body.innerHTML = parser.
                            cleanIndentation().
                            stripFromToBlocks().
                            toMarkdown().
                            toHTML().
                            content

# 3. HTML postprocessing
colorEncode()
