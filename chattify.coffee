# html to text
textContent = document.body.textContent

# do all the prettifying here...

# markdown to html
htmlContent = markdown.toHTML(textContent);

# replace the body of the website
document.body.innerHTML = htmlContent
