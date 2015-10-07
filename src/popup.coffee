document.getElementById('hit-chattify').addEventListener 'click', ->
  chrome.tabs.query { active: true, currentWindow: true }, (tabs) ->
    chrome.tabs.sendMessage tabs[0].id, { chattify: true }, (response) ->
      success = "Successfully chattified"
      failure = "No conversation detected"
      report = if response.status then success else failure
      document.getElementById('status').textContent = report

