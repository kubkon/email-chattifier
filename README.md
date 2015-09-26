chattify-email
===

Author: Jakub Konka <[jakub.konka@strath.ac.uk](mailto:jakub.konka@strath.ac.uk)>

Chattify-email is a work-in-progress, simple Google Chrome extension that serves one simple purpose: to re-format your email exchange into something more readable, more like a chat archive. It is meant to perform the following 3 fundamental functions:
+ strip email signatures
+ remove any blockquote elements
+ convert "From:...To:..."" blocks into a one-liner "On this date that person wrote:"

# Installation instructions
In order to use the extension, you (obviously) need a Chrome browser (the latest if possible). In the browser, open new tab (ctrl+t), and navigate to an address:

```
chrome://extensions
```

Enable the developer mode, and click on the "Load unpacked extension..." button. Navigate to the local folder on your computer which contains this repository (wherever you have cloned it into), and click OK. And that's you done. The extension should now be available as a "puzzle" icon in the Chrome toolbar (top right-hand corner), and whenever you press the extension button, the current webpage should have the formatting modifications applied. Note that they are not permament. It's just some JavaScript magic ;-)

# Found a bug?
If you have discovered a bug, or would like to discuss its current and future functionality, feel free to submit a Github issue, and assign it to me.
