function fromToBlocksIntoOneLiners(topSearchElement) {
  var tags = ["From", "To", "Date", "Sent", "Subject", "Cc"];

  var filterF = function(i, el) {
    var regExp = new RegExp("(" + tags.join("|") + "):", "g");
    return el.textContent.match(regExp);
  };

  var matches = topSearchElement.find("*").filter(filterF).get().reverse();

  while (matches.length > 0) {
    var parent = $(matches[0]).parent();
    var localMatches = parent.find("*:not(.converted)").filter(filterF);

    // did we match multiple span elements or a single p element?
    var numMatches = localMatches.length;
    var last = $(localMatches[localMatches.length-1]);
    if (numMatches > 1) {
      // if multiple span elements, check if the last element of the
      // array is the last element of the parent
      var next = last.next();
      if (next.parent().get(0) === parent.get(0)) {
        last = next;
      }
    }

    // insert breakpoint after the last element
    var first = $(localMatches[0]);
    $("<div id=breakpoint></div>").insertAfter(last);
    var breakpoint = $("#breakpoint");

    // preserve all text content of the block
    var textContent = first.text();
    first.nextUntil(breakpoint).each(function(i, el) {
      if ($(el).hasClass("converted")) {
        return;
      }
      textContent += $(el).text();
      $(el).remove();
    });
    first.remove();

    // extract relevant info from the text
    textContent = textContent.trim();
    var fromRegExp = textContent.match(new RegExp(tags[0] + ":(.*)\n*", "i"));
    if (fromRegExp === null || fromRegExp.length < 1) {
      // no point continuing; we must have found something we cannot handle
      break;
    }
    // replace email address within <...> with an a element;
    // this might not be the most robust way of matching an email address though!
    var from = fromRegExp[1].trim().replace(/<(.*)>/g, "<a href=mailto:$1 target='_blank'>$1</a>");
    var dateRegExp = textContent.match(new RegExp(tags[2] + ":(.*)\n*", "i"));
    if (dateRegExp === null || dateRegExp.length < 1) {
      // no point continuing; we must have found something we cannot handle
      break;
    }
    var date = dateRegExp[1].trim();

    // remove unwanted info and preserve the rest
    var unwantedRegExp = new RegExp("(" + tags.join("|") + "):.*\n*", "g");
    textContent = textContent.replace(unwantedRegExp, "");
    textContent = textContent.replace(/(.*)\n/g, '$1<br />');
    var output = "<div class='converted'><p class='converted'>On " + date + ", " + from +
                 " wrote:</p><p class='converted'>" + textContent + "</p></div>";

    $(output).insertAfter(breakpoint);
    breakpoint.remove();

    // update matches array
    matches = topSearchElement.find("*:not(converted)").filter(filterF).get().reverse();
  }
}

function removeBlockquotes() {
  // remove blockquote html elements (mainly GMail)
  $("blockquote").each(function(i, el) {
    var contents = $(el).contents();
    contents.insertAfter($(el));
    $(el).remove();
  });

  // remove &gt; which is used as the blockquote element
  // FIX:ME this also removes right bracket in <email_address>
  weirdBlockquote = "&gt;";
  var regExp = new RegExp(weirdBlockquote, "g");
  var contents = document.body.innerHTML;
  document.body.innerHTML = contents.replace(regExp, "");
}

function colourEncode(topSearchElement) {
  // Colour encode the participants of the email exchange
}

// convert From...To... blocks into one-liners
// fromToBlocksIntoOneLiners($("body"));

// remove blockquotes but preserve contents
removeBlockquotes();

// colour encode the conversation and add horizontal separators
// colourEncode($("body"));
