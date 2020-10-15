include("lexer.jl")
include("logger.jl")
include("parser.jl")

using .Lexer
using .Parser

function repl()
	while true
		print("(knight)> ")
		input = readline(stdin)

		try
			tokens = lex(input)
			statements = Parser.parse(tokens)
			println(statements)
		catch err
			Logger.error(err)
			throw(err)
		end
	end
end

if length(ARGS) < 1
	repl();
else
	println("You didn't write that code yet")
end
