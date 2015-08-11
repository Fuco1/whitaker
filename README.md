# whitaker

Simple `comint` based client for [Whitaker's words](http://en.wikipedia.org/wiki/William_Whitaker's_Words)

Call `whitaker` to start a new inferior process.

From any buffer, you can call `whitaker-send-word` to send the word
under cursor to the inferior process---the output will show in the
associated comint buffer.

# Installation

Add MELPA-stable or MELPA to your `package-archives`, then `M-x
package-refresh-contents` and `M-x package-install whitaker`.

You can usually learn how to add a repository on their websites (you
need to grab the URL from there).
