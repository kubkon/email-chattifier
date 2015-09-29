chrome.browserAction.onClicked.addListener(function(_) {
  chrome.tabs.executeScript(null, { file: "markdown.min.js" }, function() {
    chrome.tabs.executeScript(null, { file: "chattify.js" });
  });
});
