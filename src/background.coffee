chrome.tabs.onUpdated.addListener (tabId, changeInfo, tab) ->
  if tab.url.indexOf('https://mail.google.com') == 0
    chrome.pageAction.show tabId

