function filterF(i, el) {
  var pattern = /(From|To|Sent|Subject|Cc|Date):/i;
  return el.textContent.match(pattern);
}

// convert From...To... blocks into one-liners
var matches = $(document).find("*").filter(filterF).get().reverse();

while (matches.length > 0) {
  var parent = $(matches[0]).parent();
  var localMatches = parent.find("*").filter(filterF);

  // insert breakpoint after the last element of localMatches
  $("<div id=breakpoint></div>").insertAfter(localMatches[localMatches.length-1]);
  var breakpoint = $("#breakpoint");
  // save all text content of the block
  var textContent = $(localMatches[0]).text();
  $(localMatches[0]).nextUntil(breakpoint).each(function(i, el) {
    textContent += $(el).text();
    $(el).remove();
  });
  $(localMatches[0]).remove();

  console.log(textContent);
  // extract relevant info from the text
  var from = textContent.match(/From:(.*)\n/i)[1].trim();
  var date = textContent.match(/Date:(.*)\n/i)[1].trim();
  var output = "<p class='converted'>On " + date + ", " + from + " wrote:\n</p>";

  $(output).insertAfter(breakpoint);
  breakpoint.remove();

  break;

  matches = $(document).find("*").filter(filterF).get().reverse();
}

// remove blockquotes but preserve contents
$($("blockquote").get().reverse()).each(function(i, el) {
  var contents = $(el).contents();
  contents.insertAfter($(el));
  $(el).remove();
});
