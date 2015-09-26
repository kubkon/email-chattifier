chrome.browserAction.onClicked.addListener(function(tab) {
  chrome.tabs.executeScript(null, { file: "jquery.min.js" }, function() {
    chrome.tabs.executeScript(null, { file: "chattify.js" });
  });
});
