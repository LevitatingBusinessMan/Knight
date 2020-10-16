# KNIGHT (WIP)
This is my version of [sampersands Knight](https://github.com/sampersand/Knight-Haskell)

It is a language without keywords, and a very limited syntax grammar.
Something is either a function, variable identifier, or a literal.

There is no parser.
I did write one, though it's extremely simple because pretty much any operation is classified as a function call.
But the interpreter doesn't use it. The polish notation of the language means that the interpreter can work without any parsing tree.
It can parse the tokens from the scanner during runtime instead. So it is somewhat parsing, it just parses and runs every single statement it finds.
It's almost like brainfuck in the sense that all statements form a tape, and control flow is handled simply by moving an instruction pointer.

It can however be useful to parse the code for debugging purposes.

[![asciicast](https://asciinema.org/a/zEFUTHG6pYRP3UW7zOvvj9rkV.svg)](https://asciinema.org/a/zEFUTHG6pYRP3UW7zOvvj9rkV)
