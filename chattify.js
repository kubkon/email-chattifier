function fromToBlocksIntoOneLiners(topSearchElement) {
  var filterF = function(i, el) {
    var pattern = /(From|To|Sent|Subject|Cc|Date):/i;
    return el.textContent.match(pattern);
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

    console.log(textContent);
    // extract relevant info from the text
    var from = textContent.match(/From:(.*)\n/i)[1].trim();
    var date = textContent.match(/Date:(.*)\n/i)[1].trim();
    var output = "<p class='converted'>On " + date + ", " + from + " wrote:\n</p>";

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
