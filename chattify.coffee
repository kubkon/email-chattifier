class Chattifier
    constructor: ->
        @state        = 'init'
        @ancestorNode = null
        @textContent  = ""

    # infers the ancestor (top most) node of the email conversation
    inferAncestorNode: ->
        @state = 'inferAncestorNode'

        # check if blockquote exist, and get their
        # parent if they do
        blockquotes = document.body.getElementsByTagName "blockquote"
        if blockquotes.length > 0
            @ancestorNode = blockquotes[0].parentNode
            return this

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
        
        this

    # preprocesses the existing HTML of the ancestor node
    preprocessHTML: ->
        @state = 'preprocessHTML'

        if not @ancestorNode?
            return this

        @_insertNewLinesIntoDivsAndSpans(@ancestorNode)
        @_removeBlockquotes(@ancestorNode)
        @textContent = @ancestorNode.textContent
        this

    # removes spurious indentation and any special
    # block quote characters such as ">"
    cleanIndentation: ->
        @state = 'cleanIndentation'

        # split into lines and iterate:
        # 1. trim whitespaces
        # 2. remove special quote chars such as ">"
        lines = @textContent.split /\r?\n/
        cleanedLines = []
        for line in lines
            cleanedLines.push line.trim().replace(/^(?:>\s*){1,}/, "").trim()
        @textContent = cleanedLines.join "\n"

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
        @textContent = @textContent.replace blockRegex, replacer

        this

    # convert to markdown
    toMarkdown: ->
        @state = 'toMarkdown'

        # escape any existing '#' tags not generated by us
        @textContent = @textContent.replace /(#)/g, "\\$1"

        # tag all "On...wrote:" occurrences with # symbol
        replacer = (match, offset, string) =>
            match = match.replace /\r?\n/g, " "
            # remove any unwanted characters and strings
            match = match.replace /([\[\]<>]|mailto:|javascript:;)/g, ""
            # make email addresses into hyperlinks
            emailRegex = /([a-zA-Z0-9_!#$%&'*+\/=?`{|}~^.-]+@[a-zA-Z0-9.-]+)/
            match = match.replace emailRegex, "[$1](mailto:$1)"
            "\n# " + match + "\n"
        @textContent = @textContent.replace /On [\s\S]*?wrote(:|;)/g, replacer

        this

    # convert to html
    toHTML: ->
        @state = 'toHTML'

        parsedTree = markdown.toHTMLTree markdown.parse @textContent
        outputTree = [parsedTree[0], ["div"]]
        i = 1

        for el in parsedTree[1..]
            if el[0] == "h1"
                outputTree.push ["div"]
                i += 1
            outputTree[i].push el

        @textContent = markdown.renderJsonML outputTree
        this

    # postprocesses HTML after all matching has been done
    postprocessHTML: ->
        @state = 'postprocessHTML'

        if not @ancestorNode?
            return this

        @ancestorNode.innerHTML = @textContent
        @_colorEncode(@ancestorNode)
        this

    # log to console
    # for debugging only
    _log: ->
        state = "state: " + @state
        ancestorNode = "ancestorNode: " + @ancestorNode.tagName
        textContent  = "textContent: " + @textContent
        msg = "{ " + ([state, ancestorNode, textContent].join "\n") + " }"
        console.log msg
        this

    # inserts new line characters at the end of each
    # div and span element within the email trace
    _insertNewLinesIntoDivsAndSpans: (node) ->
        divs = node.getElementsByTagName "div"
        for div in divs
            div.appendChild document.createTextNode "\n\n"

        spans = node.getElementsByTagName "span"
        for span in spans
            span.appendChild document.createTextNode "\n\n"

    # removes all blockquote elements and substitutes them
    # for p elements
    _removeBlockquotes: (node) ->
        blockquotes = node.getElementsByTagName "blockquote"

        while blockquotes.length > 0
            bq = blockquotes[0]
            bqHtml = bq.innerHTML
            parent = bq.parentNode
            newChild = document.createElement "p"
            newChild.insertAdjacentHTML 'afterbegin', bqHtml
            parent.insertBefore newChild, bq
            parent.removeChild bq
            blockquotes = node.getElementsByTagName "blockquote"

    # creates a new stylesheet for color encoding of the
    # generated blocks, and applies some rudimentary CSS
    _colorEncode: (node) ->
        divs = node.getElementsByTagName "div"
        classes = ['first', 'second']
        for div, i in divs
            div.className = "chattifier " + classes[i % 2]

        # create new stylesheet
        style = document.createElement "style"
        style.appendChild document.createTextNode ""
        document.head.appendChild style

        style.sheet.insertRule "div.chattifier { margin: 2px; display: block; }", 0
        style.sheet.insertRule "div.chattifier > h1 { margin-bottom: 4px;
                                font-size: 15px;
                                font-family: Georgia,'Times New Roman','Bitstream Charter',Times,serif; }", 0
        style.sheet.insertRule "div.chattifier > p { margin: 2px;
                                font-size: 15px;
                                font-family: Arial,'Bitstream Vera Sans',Helvetica,Verdana,sans-serif; }", 0

        colors = ['#FFF', '#F4F4F4']
        for cl, i in classes
            clStyle = "." + cl + " { background-color: " + colors[i] + "; }"
            style.sheet.insertRule clStyle, 0


# run!
chattifier = new Chattifier()
chattifier.
    inferAncestorNode().
    preprocessHTML().
    cleanIndentation().
    stripFromToBlocks().
    toMarkdown().
    toHTML().
    postprocessHTML()
