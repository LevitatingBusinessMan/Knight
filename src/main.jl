include("lexer.jl")
include("logger.jl")

using .Lexer

function repl()
	while true
		print("(knight)> ")
		input = readline(stdin)

		try
			tokens = lex(input)
			println(tokens)
		catch err
			Logger.error(err)
		end
	end
end

if length(ARGS) < 1
	repl();
else
	println("You didn't write that code yet")
end
