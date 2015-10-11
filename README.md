Email Chattifier
===


[![Build Status](https://travis-ci.org/kubkon/email-chattifier.svg?branch=master)](https://travis-ci.org/kubkon/email-chattifier)


Email Chattifier is a simple Google Chrome extension that serves one simple purpose: to re-format your email conversation into something more readable, like a chat archive. You can download and install it in your Chrome browser following this link: [chrome.google.com](https://chrome.google.com/webstore/detail/email-chattifier/pcjnciejhladedpdmiokgpeanfejiofa).

Currently, it only supports GMail web client, and performs the following 3 fundamental functions:
+ remove any blockquote elements
+ convert "From:...To:..." blocks into a one-liner "On...wrote:"
+ separates "On...wrote:" blocks into alternately coloured paragraph blocks
+ strips certain email signatures

In the future, it is also meant to support other web email clients such as iCloud, Outlook, etc.

# Development
## Prerequisites
The extension was written using Coffee Script. You can get a copy using the following command:

```
$ npm install -g coffee-script
```

Furthermore, since the app is meant to run in the browser, and since it features nodejs style `require` calls to resolve dependencies, you will need to install `browserify`:

```
$ npm install -g browserify
```

Finally, to install the libraries the app depends on, simply run:

```
$ npm install
```

## Compiling
Firstly, compile all coffee scripts in the `src/` folder into the `dist/` folder; that is:

```
$ coffee -o dist/ -cb src/*
```

Then, run browserify to splice all of the content together into one JS file:

```
$ browserify dist/main.js > dist/bundle.js
```

And that's you done. Now you can upload the folder `dist` to Google Chrome.

## Testing
The project uses `jasmine` to run the unit tests. `jasmine` will be automatically installed in the project's root folder when you run `npm install`. Afterwards, to test the code just run:

```
$ npm test
```

## Found a bug?
If you have discovered a bug, or would like to discuss its current and future functionality, feel free to submit a Github issue, and assign it to me.

# License
MIT license, see [License.md](License.md).
