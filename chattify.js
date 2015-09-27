function filterF(i, el) {
  var pattern = /(From|To|Subject|Cc|Date):/i;
  return el.textContent.match(pattern);
}

$($("blockquote").get().reverse()).each(function(i, el) {
  var contents = $(el).contents();
  var matches = contents.find("*").filter(filterF).get().reverse();

  while (matches.length > 0) {
    matches[0].remove();
    matches = contents.find("*").filter(filterF).get().reverse();
  }

  // remove blockquotes but preserve contents
  contents.insertAfter($(el));
  $(el).remove();
});
