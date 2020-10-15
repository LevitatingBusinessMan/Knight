module Parser

	include("tokentypes.jl")

	#=

	expression
		literal | call | identifier

	call
		function_name expression*

	literal
		STRING | NUMBER | "true" | "false" | "null"
	
	=#

	index = 1
	failed = false

	function parse(tokens_)

		global index
		global tokens
		tokens = tokens_

		statements = []

		while index <= length(tokens)
			push!(statements, expression())
		end

		statements
	end

	function current()
		tokens[index]
	end

	function current_is(type)
		current().type == type
	end

	function advance()
		global index
		index += 1
	end

	function next()
		tokens[index+1]
	end

	function next_is(type)
		typeof(next()) == type
	end

	function expression()
		current_is(Main.Lexer.FUNCTION_NAME) ? call() :
		current_is(Main.Lexer.IDENTIFIER) ? identifier() :
		literal()
	end

	functions = Dict(
		"ECHO"=>1,
		"+"=>2
	)
	function call()
		if !haskey(functions, current().lexeme)
			throw("not exist bitch")
		end

		name = current().lexeme
		arguments = []

		arity = functions[name]

		advance()
		for _ in 1:arity
			push!(arguments, expression())
			advance()
		end

		FUNC_CALL(name, arguments)
	end

	function literal()
		current_is(Main.Lexer.TRUE) ? LITERAL(true) :
		current_is(Main.Lexer.FALSE) ? LITERAL(false) :
		current_is(Main.Lexer.NULL) ? LITERAL(nothing) :
		current_is(Main.Lexer.STRING) ? LITERAL(current().lexeme) :
		current_is(Main.Lexer.NUMBER) ? LITERAL(Base.parse(Int, current().lexeme)) :
		throw("Unknown literal type, this can't happen")
	end

	struct FUNC_CALL
		name
		arguments
	end

	struct LITERAL
		value
	end

end
