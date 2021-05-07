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
		old_tokens = tokens
		tokens = vcat(tokens,tokens_)

		global repl_mode
		repl_mode = repl_mode_

		out = nothing
		
		try
			while index <= length(tokens)
				out = evaluate(tokens[index])
				index += 1
			end
		catch err

			while length(tokens) < index
				index -= 1
			end
			current = tokens[index]

			#Remove bad code
			tokens = old_tokens

			if in(:msg, fieldnames(typeof(err)))
				error_token(current, err.msg)
			else
				throw(err)
			end

		end

		out
	end

	function evaluate(token)
		global index

		if(token.type == Main.Lexer.FUNCTION_NAME)
			global tokens
			name = token.lexeme
			(func, arity) = get_func(name)

			if typeof(func) == UserFunction && func.index < 0
				error("Refusing to run initiliazed function")
			end

			if func == nothing
				error("Unknown function $name used")
			end

			arguments = []

			ensure_tokens(arity)

			for i in 1:arity
				index +=1
				ensure_tokens(arity - i) # Make sure the tokens didn't get used already
				push!(arguments, evaluate(tokens[index]))
			end

			value = nothing

			#New scope
			push!(variables,Dict())

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


			#End scope
			pop!(variables)
			return value
		end
		
		if(token.type == Main.Lexer.IDENTIFIER)
			name = token.lexeme
			(exist, value) = get_var(name)
			if !exist
				error("Unknown variable $name")
			end
			return value
		end

		#Literal
		token.type == Main.Lexer.TRUE ? true :
		token.type == Main.Lexer.FALSE ? false :
		token.type == Main.Lexer.NULL ? nothing :
		token.type == Main.Lexer.STRING ? token.lexeme[2:end-1] :
		token.type == Main.Lexer.NUMBER ? Base.parse(Int, token.lexeme) :
		error("Unknown token type, this can't happen")
		
	end

	function skip(n)
		global index
		ensure_tokens(n) # (minimal)
		for i in 1:n
			index += 1
			ensure_tokens(n - i) # Make sure the tokens didn't get used already
			if tokens[index].type == Main.Lexer.FUNCTION_NAME
				name = tokens[index].lexeme
				(f, arity) = get_func(name)

				# Even if the FN function isn't run yet we can try to guess it's arity
				if name == "FN"
					if tokens[index+1].type == Main.Lexer.STRING && tokens[index+2].type == Main.Lexer.STRING
						ensure_tokens(2)
						func_name = tokens[index+1].lexeme[2:end-1]
						parameter_names = tokens[index+2].lexeme
						if split(parameter_names, ",")[1] == "\"\""
							arity = 0
						else
							arity = length(split(parameter_names, ","))
						end
						functions[func_name] = UserFunction(-1,arity)
					end
				end


				if f == nothing
					error("Unknown function $name used (can't guess arity)")
				end

				#These contain a branch
				if in(skippers)(name)
					arity += 1
				end

				skip(arity)
			end
		end
	end

	function get_func(name)
		if !haskey(native_functions, name)
			if !haskey(functions, name)
				#error("Unknown function $name used")
				return (nothing, nothing)
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
				error("Missing function arguments")
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

	function error_token(token, msg)
		throw(InterpretationError(msg, token.line))
	end

	struct InterpretationError <: Exception
		msg::String
		line::Integer
	end

end

#FN "GREET" "name" ECHO + "Hello " name GREET "Levi"
