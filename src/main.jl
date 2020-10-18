include("lexer.jl")
include("logger.jl")
include("parser.jl")
include("astprinter.jl")
include("interpreter.jl")
include("print_value.jl")

using .Lexer
using .Parser
using .ASTPrinter
using .Interpreter

parser_flag = in(ARGS)("-p")
filter!(arg -> arg != "-p", ARGS)

debug_flag = in(ARGS)("--debug")
filter!(arg -> arg != "--debug", ARGS)


function repl()
	while true
		print("(knight)> ")
		input = readline(stdin)

		try
			tokens = lex(input)
			if parser_flag
				statements = Main.Parser.parse(tokens)
				print_tree(statements)
			end
			print_value(interpret(tokens, true))
		catch err
			Logger.error(err)
			if debug_flag
				throw(err)
			end
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
	try
		tokens = lex(source)
		if parser_flag
			statements = Main.Parser.parse(tokens)
			print_tree(statements)
		end
		interpret(tokens, false)
	catch err
		Logger.error(err)
		if debug_flag
			throw(err)
		end
	end
end
