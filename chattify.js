function filterF(i, el) {
  var pattern = /(From|To|Sent|Subject|Cc|Date):/i;
  return el.textContent.match(pattern);
}

// convert From...To... blocks into one-liners
var matches = $(document).find("*").filter(filterF).get().reverse();

while (matches.length > 0) {
  matches[0].remove();
  matches = $(document).find("*").filter(filterF).get().reverse();
}

// remove blockquotes but preserve contents
$($("blockquote").get().reverse()).each(function(i, el) {
  var contents = $(el).contents();
  contents.insertAfter($(el));
  $(el).remove();
});
