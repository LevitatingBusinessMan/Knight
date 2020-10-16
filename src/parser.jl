# This is the tree Parser
# Just need to finish it and make
# it add functions when they get defined

module Parser

	#=

	expression
		literal | call | identifier

	call
		function_name expression*

	literal
		STRING | NUMBER | "true" | "false" | "null"
	
	=#

	index = 1

	function parse(tokens_)

		global index
		index = 1

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
		name = current().lexeme

		if !haskey(functions, name)
			throw("Unknown function $name used")
		end

		name = current().lexeme
		arguments = []

		arity = functions[name]

		if arity > length(tokens) - index
			throw("Missing arguments on call $name")
		end

		advance()
		for _ in 1:arity
			push!(arguments, expression())
		end

		FUNC_CALL(name, arguments)
	end

	function identifier()
		expr = VARIABLE(current().lexeme)
		advance()
		expr
	end
	
	function literal()
		expr = current_is(Main.Lexer.TRUE) ? LITERAL(true) :
		current_is(Main.Lexer.FALSE) ? LITERAL(false) :
		current_is(Main.Lexer.NULL) ? LITERAL(nothing) :
		current_is(Main.Lexer.STRING) ? LITERAL(current().lexeme) :
		current_is(Main.Lexer.NUMBER) ? LITERAL(Base.parse(Int, current().lexeme)) :
		throw("Unknown literal type, this can't happen")
		
		advance()
		expr
	end

	struct FUNC_CALL
		name
		arguments
	end

	struct LITERAL
		value
	end

	struct VARIABLE
		name
	end

	export parser, FUNC_CALL, LITERAL, VARIABLE

end
