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

# html to text
textContent = document.body.textContent

# reindent
reindented = cleanIndentation textContent

# markdown to html
htmlContent = markdown.toHTML reindented

# replace the body of the website
document.body.innerHTML = htmlContent
