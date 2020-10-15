include("lexer.jl")

using .Lexer

function repl()
	while true
		print("(knight)> ")
		input = readline(stdin)
		tokens = lex(input)

		println(tokens)

		#= 		
		try
			lex(input)
		catch err
			@error(err)
		end
		=#
	end
end

if length(ARGS) < 1
	repl();
else
	println("You didn't write that code yet")
end
