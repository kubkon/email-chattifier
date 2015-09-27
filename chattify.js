function fromToBlocksIntoOneLiners(topSearchElement) {
  var tags = ["From", "To", "Date", "Sent", "Subject", "Cc"];

  var filterF = function(i, el) {
    var regExp = new RegExp("(" + tags.join("|") + "):", "g");
    return el.textContent.match(regExp);
  };

  var matches = topSearchElement.find("*").filter(filterF).get().reverse();

  while (matches.length > 0) {
    var parent = $(matches[0]).parent();
    var localMatches = parent.find("*").filter(filterF);

    // check if the last element of the array is the last element
    // of the parent
    var last = $(localMatches[localMatches.length-1]);
    var next = last.next();
    if (next.parent().get(0) === parent.get(0)) {
      last = next;
    }

    // insert breakpoint after the last element
    var first = $(localMatches[0]);
    $("<div id=breakpoint></div>").insertAfter(last);
    var breakpoint = $("#breakpoint");

    // preserve all text content of the block
    var textContent = first.text();
    first.nextUntil(breakpoint).each(function(i, el) {
      textContent += $(el).text();
      $(el).remove();
    });
    first.remove();

    // extract relevant info from the text
    textContent = textContent.trim();
    var fromRegExp = new RegExp(tags[0] + ":(.*)\n", "i");
    var from = textContent.match(fromRegExp)[1].trim();
    var dateRegExp = new RegExp(tags[2] + ":(.*)\n", "i");
    var date = textContent.match(dateRegExp)[1].trim();

    // remove unwanted info and preserve the rest
    var unwantedRegExp = new RegExp("(" + tags.join("|") + "):.*\n", "g");
    textContent = textContent.replace(unwantedRegExp, "");
    textContent = textContent.replace(/(.*)\n/g, '$1<br />');
    var output = "<div class='converted'><p>On " + date.trim() + ", " + from.trim() +
                 " wrote:</p><p>" + textContent + "</p></div>";

    $(output).insertAfter(breakpoint);
    breakpoint.remove();

    // update matches array
    matches = topSearchElement.find("*").filter(filterF).get().reverse();
  }
}

function removeBlockquotes(blockquoteElement) {
  $(blockquoteElement.get().reverse()).each(function(i, el) {
    var contents = $(el).contents();
    contents.insertAfter($(el));
    $(el).remove();
  });
}

// convert From...To... blocks into one-liners
fromToBlocksIntoOneLiners($("blockquote"));

// remove blockquotes but preserve contents
removeBlockquotes($("blockquote"));
