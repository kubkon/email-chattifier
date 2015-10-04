chattify-email
===

Chattify-email is a work-in-progress, simple Google Chrome extension that serves one simple purpose: to re-format your email exchange into something more readable, more like a chat archive. It is meant to perform the following 3 fundamental functions:
+ strip email signatures
+ remove any blockquote elements
+ convert "From:...To:..."" blocks into a one-liner "On this date that person wrote:"

# Requirements
In order to compile the extension, you need to install the following packages:
+ coffeescript
+ markdown
+ browserify
+ jasmine-node

# Compiling
Firstly, compile all coffee scripts in the `src/` folder into the `dist/` folder; that is:

```
$ coffee -o dist/ -cb src/*
```

Then, run browserify to splice all of the content together into one JS file:

```
$ browserify dist/main.js > dist/bundle.js
```

And that's you done. Now you can upload the folder `dist` to Google Chrome.

# Testing
The code can be tested running `jasmine` test engine. This can be accomplished as follows:

```
$ jasmine-node --coffee spec
```

# Found a bug?
If you have discovered a bug, or would like to discuss its current and future functionality, feel free to submit a Github issue, and assign it to me.

# License
MIT licenses, see [License.md](License.md).
