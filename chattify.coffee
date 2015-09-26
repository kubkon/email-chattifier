# remove blockquotes but preserve contents
$("blockquote").each (i, element) =>
    contents = $(element).contents()
    console.log contents
    contents.insertAfter($(element))
    $(element).remove()
