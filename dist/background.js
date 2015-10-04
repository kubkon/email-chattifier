chrome.browserAction.onClicked.addListener(function(_) {
  chrome.tabs.executeScript(null, { file: "bundle.js" });
});
