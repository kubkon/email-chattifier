chrome.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
  if (tab.url.indexOf('https://mail.google.com') == 0) {
    chrome.pageAction.show(tabId);
  }
});

chrome.pageAction.onClicked.addListener(function(_) {
  chrome.tabs.executeScript(null, { file: "bundle.js" });
});
