# whitaker

Simple `comint` based client for [Whitaker's words](http://en.wikipedia.org/wiki/William_Whitaker's_Words)

Call `whitaker` to start a new inferior process.

From any buffer, you can call `whitaker-send-word` to send the word
under cursor to the inferior process---the output will show in the
associated comint buffer.
