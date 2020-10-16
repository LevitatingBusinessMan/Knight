module Interpreter

	functions = Dict()
	variables = Dict()

	index = 0

	native_functions = Dict(
		"ECHO"=> str -> println(str),
		"+"=> (left,right) -> left + right,
		"="=> function(name, value)
			if typeof(name) != String
				throw("Why are you trying to assign a value to a non-string name?")
			end
			variables[name] = value
		end,
		"EXIST"=> (name) -> haskey(variables, name),
		"IF"=> function(value)
			global index
			if value != true
				skip(1)
			end
		end
	)

	tokens = []

	function skip(n)
		global index
		println("SKIP")
		for i in 1:n
			index += 1
			if tokens[index].type == Main.Lexer.FUNCTION_NAME
				(_, arity) = getFunc(tokens[index].lexeme)
				skip(arity)
			end
		end
	end

	function getFunc(name)
		if !haskey(native_functions, name)
			throw("Unknown function $name used")
		end
		func = native_functions[name]
		arity = first(methods(func)).nargs-1
		return (func, arity)
	end

	function interpret(tokens_)
		
		global index
		global tokens
		tokens = vcat(tokens,tokens_)

		out = nothing
		while index < length(tokens)
			index += 1
			out = evaluate(tokens[index])
		end

		out
	end

	function evaluate(token)
		println(token)
		global index

		if(token.type == Main.Lexer.FUNCTION_NAME)
			global tokens
			name = token.lexeme
			(func, arity) = getFunc(name)
			arguments = []
			for i in 1:arity
				index +=1
				push!(arguments, evaluate(tokens[index]))
			end
			return func(arguments...)
		end
		
		if(token.type == Main.Lexer.IDENTIFIER)
			name = token.lexeme
			if !haskey(variables, name)
				throw("Unknown variable $name")
			end
			return variables[name]
		end

		#Literal
		token.type == Main.Lexer.TRUE ? true :
		token.type == Main.Lexer.FALSE ? false :
		token.type == Main.Lexer.NULL ? nothing :
		token.type == Main.Lexer.STRING ? token.lexeme[2:end-1] :
		token.type == Main.Lexer.NUMBER ? Base.parse(Int, token.lexeme) :
		throw("Unknown token type, this can't happen")
		
	end

	export interpret

end
