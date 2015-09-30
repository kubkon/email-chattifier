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


# removes spurious indentation and any special
# block quote characters such as ">"
cleanIndentation = (text) =>
    lines = text.split "\n"
    # iterate:
    # 1. trim whitespaces
    # 2. remove special quote chars such as ">"
    cleanedLines = []
    for line in lines
        cleanedLines.push line.trim().replace(/^(?:>\s*){1,}/, "").trim()
    cleanedLines.join "\n"


# remove blockquote elements
removeBlockquotes()

# html to text
textContent = document.body.textContent

# reindent
reindented = cleanIndentation textContent

# markdown to html
htmlContent = markdown.toHTML reindented

# replace the body of the website
document.body.innerHTML = htmlContent
