native_functions = Dict(
	"ECHO"=> (value) -> Main.print_value(value),
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
		variables[end-1][name] = value
	end,
	"!"=> value -> !value,
	"EXIST"=> (name) -> first(get_var(name)),
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
			trow("The parameter_string should look like: \"first_param,second_param\"")
		end

		parameters = parameter_names == "" ? [] : split(parameter_names, ",")
		functions[name] = UserFunction(index+1, parameters)
		skip(1)
	end,
	"EXIT"=> () -> exit(),
	";"=> (left, right) -> right,
	"GLOBAL="=> function(name, value)
		if !occursin(r"[a-z_]", name)
			throw("Please use snake_case in variable names")
		end
		if typeof(name) != String
			throw("Why are you trying to assign a value to a non-string name?")
		end
		variables[begin][name] = value
	end,
	"ARRAY"=> () -> [],
	","=> (left, right) -> vcat(left,right),
	"INDEX"=> function(index, array)
		if typeof(index) != Int
			throw("Array indeces should be integers, not $index")
		end
		if !(array isa Array)
			throw("Attempting to access an array that ins't an array")
		end
		array[index]
	end,
	"PUSH"=> function(value,array)
		if !(array isa Array)
			throw("Attempting to push to an array that ins't an array")
		end
		push!(array,value)
	end,
	"POP"=> function(array)
		if !(array isa Array)
			throw("Attempting to pop an array that ins't an array")
		end
		pop!(array)
	end,
	"-"=> function(left, right)
		if (typeof(left) == Int && typeof(right) != Int)
			throw("You can only subtract integers from integers")
		end
		left - right
	end,
	"=="=> (left, right) -> left == right
)

export native_functions
