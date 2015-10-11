Chattifier = require "./chattifier.js"

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  if request.chattify
    chattifier = new Chattifier document
    status = chattifier.renderHTML()
    sendResponse { status: status }

