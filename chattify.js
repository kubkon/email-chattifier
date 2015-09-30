// Generated by CoffeeScript 1.10.0
(function() {
  var cleanIndentation, htmlContent, reindented, removeBlockquotes, textContent;

  removeBlockquotes = (function(_this) {
    return function() {
      var blockquotes, bq, bqHtml, newChild, parent, results;
      blockquotes = document.getElementsByTagName("blockquote");
      results = [];
      while (blockquotes.length > 0) {
        bq = blockquotes[0];
        bqHtml = bq.innerHTML;
        parent = bq.parentNode;
        newChild = document.createElement("p");
        newChild.insertAdjacentHTML('afterbegin', bqHtml);
        parent.insertBefore(newChild, bq);
        parent.removeChild(bq);
        results.push(blockquotes = document.getElementsByTagName("blockquote"));
      }
      return results;
    };
  })(this);

  cleanIndentation = (function(_this) {
    return function(text) {
      var cleanedLines, i, len, line, lines;
      lines = text.split("\n");
      cleanedLines = [];
      for (i = 0, len = lines.length; i < len; i++) {
        line = lines[i];
        cleanedLines.push(line.trim().replace(/^(?:>\s*){1,}/, "").trim());
      }
      return cleanedLines.join("\n");
    };
  })(this);

  removeBlockquotes();

  textContent = document.body.textContent;

  reindented = cleanIndentation(textContent);

  htmlContent = markdown.toHTML(reindented);

  document.body.innerHTML = htmlContent;

}).call(this);
