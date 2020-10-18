module Interpreter

	struct UserFunction
		index
		parameters
	end

	functions = Dict()
	variables = [Dict()]

	#=
	Note about arrays
	
	Create with function ARRAY
	Edit with functions like PUSH

	, function wil concat
	, , "foo" "bar" ARRAY
	will make ["foo","bar"]

	=#

	#index = []
	index = 1

	repl_mode = false

	include("natives.jl")

	tokens = []

	function interpret(tokens_, repl_mode_)
		
		global index
		global tokens
		tokens = vcat(tokens,tokens_)

		global repl_mode
		repl_mode = repl_mode_

		out = nothing
		while index <= length(tokens)
			out = evaluate(tokens[index])
			index += 1
		end

		out
	end

	function evaluate(token)
		global index

		if(token.type == Main.Lexer.FUNCTION_NAME)
			global tokens
			name = token.lexeme
			(func, arity) = getFunc(name)
			arguments = []

			ensure_tokens(arity)

			for i in 1:arity
				index +=1
				push!(arguments, evaluate(tokens[index]))
			end

			value = nothing

			#New scope
			push!(variables,Dict())
				try
					#User
					if typeof(func) == UserFunction
						for i in 1:length(arguments)
							variables[end][func.parameters[i]] = arguments[i]
						end
						old_index = index
						index = func.index
						value = evaluate(tokens[func.index])
						index = old_index
					#Native
					else
						value = func(arguments...)
					end
				catch err
					println(err.message)
					println(strip(err.message, "throw: "))
					error(token, strip(err.message, "throw: "))
				end

			#End scope
			pop!(variables)

			return value
		end
		
		if(token.type == Main.Lexer.IDENTIFIER)
			name = token.lexeme
			(exist, value) = get_var(name)
			if !exist
				error(token,"Unknown variable $name")
			end
			return value
		end

		#Literal
		token.type == Main.Lexer.TRUE ? true :
		token.type == Main.Lexer.FALSE ? false :
		token.type == Main.Lexer.NULL ? nothing :
		token.type == Main.Lexer.STRING ? token.lexeme[2:end-1] :
		token.type == Main.Lexer.NUMBER ? Base.parse(Int, token.lexeme) :
		error(token,"Unknown token type, this can't happen")
		
	end

	function skip(n)
		global index
		ensure_tokens(n) # (minimal)
		for i in 1:n
			index += 1
			ensure_tokens(n - i) # Make sure the tokens didn't get used already
			if tokens[index].type == Main.Lexer.FUNCTION_NAME
				(f, arity) = getFunc(tokens[index].lexeme)
				skip(arity)
			end
		end
	end

	function getFunc(name)
		if !haskey(native_functions, name)
			if !haskey(functions, name)
				throw("Unknown function $name used")
			end
			func = functions[name]
			arity = length(func.parameters)
			return (func, arity)
		end
		func = native_functions[name]
		arity = first(methods(func)).nargs-1
		return (func, arity)
	end

	function ensure_tokens(needed)
		global tokens, index
		if needed > length(tokens) - index
			if !repl_mode
				throw("Missing function arguments")
			end
			tokens = vcat(tokens, Main.get_more_tokens(needed - (length(tokens) - index)))
			ensure_tokens(needed)
		end
	end

	function get_var(name)
		index = length(variables)
		while index > 0
			if haskey(variables[index], name)
				return (true, variables[index][name])
			end
			index -= 1
		end
		return (false, nothing)
	end

	export interpret

	function error(token, msg)
		throw(InterpretationError(msg, token.line))
	end

	struct InterpretationError <: Exception
		msg::String
		line::Integer
	end

end

#FN "GREET" "name" ECHO + "Hello " name GREET "Levi"
