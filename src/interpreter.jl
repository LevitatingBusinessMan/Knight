module Interpreter

	struct UserFunction
		index
		parameters
	end

	functions = Dict()
	variables = Dict()

	#=
	Note about scopes
	New function for getting a var
	Array of variable dictionaries get searched by it. (also function dict)
	Push new dict when running function
	Pop dict when leaving function
	
	Index will be an array of indeces
	You run a function, you push the index you're on
	You finish it, pop it

	New GLOBAL= function
	=#

	#=
	Note about arrays
	
	Create with function ARRAY
	Edit with functions like PUSH

	, function wil concat
	, , "foo" "bar" ARRAY
	will make "foo" "bar"

	=#

	#index = []
	index = 1

	repl_mode = false

	native_functions = Dict(
		"ECHO"=> str -> println(str),
		"+"=> function(left,right)
			if (typeof(left) == Int && typeof(right) != Int || typeof(left) == String && typeof(right) != String)
				throw("Can't add different types")
			end
			if (typeof(left) == String)
				return string(left, right)
			end
			if (typeof(left) == Int)
				return left + right
			end
			throw("You can only add strings or integers")
		end,
		"="=> function(name, value)
			if !occursin(r"[a-z_]", name)
				throw("Please use snake_case in variable names")
			end
			if typeof(name) != String
				throw("Why are you trying to assign a value to a non-string name?")
			end
			variables[name] = value
		end,
		"!"=> value -> !value,
		"EXIST"=> (name) -> haskey(variables, name),
		"IF"=> function(value)
			global index
			if value != true
				skip(1)
			end
		end,
		"FN"=> function(name, parameter_names)
			if !occursin(r"[A-Z_]", name)
				throw("User-Made function names can only use characters 'A' to 'Z' and '_'")
			end
			if !occursin(r"[a-z_]*(,[a-z_]+)*", parameter_names)
				trow("The parameter_names string should look like: \"first_var,second_var\"")
			end

			parameters = split(parameter_names, ",")
			functions[name] = UserFunction(index+1, parameters)
			skip(1)
		end,
		"EXIT"=> () -> exit()
	)

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

			#User
			if typeof(func) == UserFunction
				for i in 1:length(arguments)
					variables[func.parameters[i]] = arguments[i]
				end
				old_index = index
				index = func.index
				value = evaluate(tokens[func.index])
				index = old_index
				return value
			#Native
			else
				return func(arguments...)
			end
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

	function skip(n)
		global index
		ensure_tokens(n)
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

	export interpret

end

#FN "GREET" "name" ECHO + "Hello " name GREET "Levi"
