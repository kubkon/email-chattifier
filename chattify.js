// Generated by CoffeeScript 1.10.0
(function() {
  var Parser, parser, removeBlockquotes;

  Parser = (function() {
    function Parser(content) {
      this.content = content;
      this.state = 'init';
    }

    Parser.prototype.cleanIndentation = function() {
      var cleanedLines, i, len, line, lines;
      this.state = 'cleanIndentation';
      lines = this.content.split(/\r?\n/);
      cleanedLines = [];
      for (i = 0, len = lines.length; i < len; i++) {
        line = lines[i];
        cleanedLines.push(line.trim().replace(/^(?:>\s*){1,}/, "").trim());
      }
      this.content = cleanedLines.join("\n");
      return this;
    };

    Parser.prototype.toMarkdown = function() {
      this.state = 'toMarkdown';
      this.content = this.content.replace(/(On.*?wrote(:|;))/g, "\n# $1\n");
      return this;
    };

    Parser.prototype.toHTML = function() {
      this.state = 'toHTML';
      this.content = markdown.toHTML(this.content);
      return this;
    };

    Parser.prototype.log = function() {
      console.log([this.state, this.content].join(":"));
      return this;
    };

    return Parser;

  })();

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

  removeBlockquotes();

  parser = new Parser(document.body.textContent);

  document.body.innerHTML = parser.cleanIndentation().log().toMarkdown().log().toHTML().content;

}).call(this);
