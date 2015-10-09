Chattifier = require "./chattifier.js"

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  if request.chattify
    chattifier = new Chattifier()
    status = chattifier.renderHTML()
    sendResponse { status: status }

