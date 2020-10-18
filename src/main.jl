include("lexer.jl")
include("logger.jl")
include("parser.jl")
include("astprinter.jl")
include("interpreter.jl")

using .Lexer
using .Parser
using .ASTPrinter
using .Interpreter

function repl()
	while true
		print("(knight)> ")
		input = readline(stdin)

		try
			tokens = lex(input)
			#statements = Main.Parser.parse(tokens)
			#print_tree(statements)
			println(interpret(tokens, true))
		catch err
			Logger.error(err)
			throw(err)
		end
	end
end

function get_more_tokens(x)
	print("\t$x> ")
	input = readline(stdin)
	return lex(input)
end

if length(ARGS) < 1
	repl();
else
	source = open(ARGS[1]) do file
    	read(file, String)
	end
	tokens = lex(source)
	interpret(tokens, false)
end
