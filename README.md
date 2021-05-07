# KNIGHT
This is my version of [sampersands Knight](https://github.com/sampersand/Knight-Haskell)

It is a language without keywords, and a very limited syntax grammar.
Something is either a function, variable identifier, or a literal.

There is no parser.
I did write one, though it's extremely simple because pretty much any operation is classified as a function call.
But the interpreter doesn't use it. The polish notation of the language means that the interpreter can work without any parsing tree.
It can parse the tokens from the scanner during runtime instead. So it is somewhat parsing, it just parses and runs every single statement it finds.
It's almost like brainfuck in the sense that all statements form a tape, and control flow is handled simply by moving an instruction pointer.
This makes the interpreter extremely complex, because it needs to calculate what expressions form a single function call together whenever it's moving to a different instruction. Somtimes guessing the arity of functions that aren't even initiliazed.

It can however be useful to parse the code for debugging purposes.

#### Fibonacci
```
FN "FIB" "n" 
	; IF < n 2
		n
	+ FIB - n 1 FIB - n 2

ECHO FIB 10
```

#### REPL
[![asciicast](https://asciinema.org/a/zEFUTHG6pYRP3UW7zOvvj9rkV.svg)](https://asciinema.org/a/zEFUTHG6pYRP3UW7zOvvj9rkV)

#### Grammar syntax
```
	call
		function_name expression*
	
	expression
		 call | identifier | literal

	literal
		STRING | NUMBER | "true" | "false" | "null"
```

#### Hello world
```
ECHO "Hello world"
```

#### Comments
```
# This is a comment
```

#### Create variable
Use the `=` function to create a variable
```
= "foo" "bar"
```

#### Control flow
The `IF` function skips a statement if it's condition is false
```
IF < cookies 1 ECHO "We are out of cookies!"
```

#### Create function
Functions in Knight are a bit weird.
You use the `FN` function, which takes a function name,
and then a `parameter_string` with the syntax `first_param,second_param`
```
FN "GREET" "name"
	ECHO + "Hello " name
GREET "Levi"
```
The `FN` function then saves the location of the next expression in the list.
This expression is what gets run when you call the function.
So you need to group statements into a single expression if you want complicated functions.

#### Grouping statements
The `;` function takes 2 expressions as its arguments.
Then returns the value of the second.
This way you can turn a list of expressions into 1
```
FN "GREET" "name_one,name_two,name_three"
	; ECHO + "Hello " name_one
	; ECHO + "Hello " name_two
	ECHO + "Hello " name_three
GREET "Eren" "Mikasa" "Armin"
```

#### Scopes
Knight has basic scoping.
```
FN "SOME_FUNC" ""
    = "local" "foobar"
SOME_FUNC
ECHO EXIST "local" # prints false
```

#### Global variables
For assigning to global variables there is a seperate assignment function
```
FN "SOME_FUNC" ""
    GLOBAL= "global" "foobar"
SOME_FUNC
ECHO EXIST "global" # prints true
```

#### Arrays
Make arrays with the `ARRAY` function
```
ECHO ARRAY # prints []
```
Push to an array with the `PUSH` function
```
= "myarr" ARRAY
PUSH 5 myarr
```
You can also cleverly build functions with the `,` function. Which concatenates arrays.
```
= "my_fav_numbers" , , , , , , ,  23 34 75 23 46 98 34 ARRAY
ECHO my_fav_numbers # prints [23, 34, 75, 23, 46, 98, 34]
```
Access arrays with the `INDEX` function. (Also did I say arrays start at 1 already?)
```
ECHO INDEX 2 my_fav_numbers # 34
```
And there are some more basic array functions

#### Whitespace
Whitespace in knight is only necessary to seperate tokens. Because tokens have a limited possible character set this means many tokens can be put next to each other.
This is the fibonacci example again.
```
FN"FIB""n"; IF <n2n+ FIB -n1 FIB -n2ECHO FIB10
```
Pretty much only function names have to be seperated.

#### StackOverflowError
Julia has the habit of creating enormous stacks.
This compiler makes a lot of use of recursive functions,
and KNIGHT doesn't support loops. So complicated KNIGHT code also requires a lot of recursion to work.
This causes a remotely complicated KNIGHT program to overflow its stack rather easily.

On Mac Or Linux, resolve this by increasing the stack size limit.
Use this command to increase your stack size limits for your current shell instance.

`ulimit -s 16384` (sets to 16mb)

#### (File) IO
KNIGHT supports some basic file IO

Mainly via the `INPUT`, `OPEN_FD`, `READ_FD`, `WRITE_FD` and `CLOSE_FD` functions.

You can read a file like this.
```
= "file" OPEN_FD "file.txt" "r"
= "content" READ_FD file
ECHO content
CLOSE_FD file
```
You can use `WRITE_FD` to print to the terminal without newlines.

#### All functions
Knight has a lot more built-in functions that aren't mentioned in this readme.
Please refer to `src/natives.jl` to see all supported functions.
Here you can find functions for CLI arguments, splitting strings etc.
#### Brainfuck Interpreter Example
In the `brainfuck.kn` file you will find a brainfuck interpreter written in Knight.
This is a good example of what a complicated Knight program could look like.

If you want to run it, you will probably need to increase your OS's stack limit size.
