function filterF(i, el) {
  var pattern = /(From|To|Sent|Subject|Cc|Date):/i;
  return el.textContent.match(pattern);
}

// convert From...To... blocks into one-liners
var matches = $(document).find("*").filter(filterF).get().reverse();

while (matches.length > 0) {
  var parent = $(matches[0]).parent();
  var localMatches = parent.find("*").filter(filterF);

  // insert breakpoint after either the last element of localMatches
  var breakpoint = "breakpoint";
  $(localMatches[localMatches.length-1]).insertAfter("<div id=" + breakpoint + "></div>");
  $(localMatches[0]).nextUntil("#" + breakpoint).each(function(i, el) {
    $(el).remove();
  });
  $(localMatches[0]).remove();
  $("#" + breakpoint).remove();

  matches = $(document).find("*").filter(filterF).get().reverse();
}

// remove blockquotes but preserve contents
$($("blockquote").get().reverse()).each(function(i, el) {
  var contents = $(el).contents();
  contents.insertAfter($(el));
  $(el).remove();
});
