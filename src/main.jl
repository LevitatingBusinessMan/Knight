include("lexer.jl")
include("logger.jl")
include("parser.jl")
include("astprinter.jl")

using .Lexer
using .Parser
using .ASTPrinter

function repl()
	while true
		print("(knight)> ")
		input = readline(stdin)

		try
			tokens = lex(input)
			statements = Main.Parser.parse(tokens)
			print_tree(statements)
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
