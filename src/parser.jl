# This is the tree Parser
# Just need to finish it and make
# it add functions when they get defined

module Parser

	#=

	call
		function_name expression*
	
	expression
		 call | identifier | literal

	literal
		STRING | NUMBER | "true" | "false" | "null"
	
	=#

	index = 1

	user_functions = Dict()

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

	function expression()
		current_is(Main.Lexer.FUNCTION_NAME) ? call() :
		current_is(Main.Lexer.IDENTIFIER) ? identifier() :
		literal()
	end

	function call()
		name = current().lexeme

		if name == "FN"
			func_name = tokens[index+1].lexeme[2:end-1]
			parameter_names = tokens[index+2].lexeme
			arity = length(split(parameter_names, ","))
			user_functions[func_name] = arity
		end

		arity = nothing
		if !haskey(Main.Interpreter.native_functions, name)
			if !haskey(user_functions, name)
				throw("Unknown function $name used")
			end
			arity = user_functions[name]
		else
			arity = first(methods(Main.Interpreter.native_functions[name])).nargs-1
			if in(Main.Interpreter.skippers)(name)
				arity += 1
			end
		end

		if arity > length(tokens) - index
			throw("Missing arguments on call $name")
		end

		arguments = []

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
		current_is(Main.Lexer.STRING) ? LITERAL(current().lexeme[2:end-1]) :
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
