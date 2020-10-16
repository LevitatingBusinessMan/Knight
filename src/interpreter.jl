module Interpreter

	native_functions = Dict(
		"ECHO"=> str -> println(str),
		"+"=> (left,right) -> left + right
	)

	index = 0
	tokens = []

	functions = Dict()
	variables = Dict()

	function interpret(tokens_)
		
		global index
		global tokens
		tokens = tokens_

		while index < length(tokens)
			index += 1
			evaluate(tokens[index])
			#= if token.type != Main.Lexer.FUNCTION_NAME
				println(evaluate(token))
			else
				evaluate(token)
			end =#
		end

	end

	function evaluate(token)
		global index

		if(token.type == Main.Lexer.FUNCTION_NAME)
			global tokens
			name = token.lexeme
			if !haskey(native_functions, name)
				throw("Unknown function $name used")
			end
			func = native_functions[name]
			arity = first(methods(func)).nargs-1
			arguments = []
			for i in 1:arity
				index +=1
				push!(arguments, evaluate(tokens[index]))
			end
			return func(arguments...)
		end
		
		if(token.type == Main.Lexer.IDENTIFIER)
			return
		end

		 #Literal
		token.type == Main.Lexer.TRUE ? true :
		token.type == Main.Lexer.FALSE ? false :
		token.type == Main.Lexer.NULL ? nothing :
		token.type == Main.Lexer.STRING ? token.lexeme[2:end] :
		token.type == Main.Lexer.NUMBER ? Base.parse(Int, token.lexeme) :
		throw("Unknown token type, this can't happen")
		
	end

	export interpret

end
