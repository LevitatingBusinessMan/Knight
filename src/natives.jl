native_functions = Dict(
	"ECHO"=> function(value)
		Main.print_value(value)
		return nothing
	end,
	"+"=> function(left,right)
		if (typeof(left) == Int && typeof(right) != Int)
			error("Can only add ints to ints and strings/ints to strings")
		end
		if (typeof(left) == String)
			return string(left, right)
		end
		if (typeof(left) == Int)
			return left + right
		end
		error("You can only add strings or integers")
	end,
	"="=> function(name, value)
		if !occursin(r"[a-z_]", name)
			error("Please use snake_case in variable names")
		end
		if typeof(name) != String
			error("Why are you trying to assign a value to a non-string name?")
		end
		variables[end-1][name] = value
	end,
	"!"=> value -> !value,
	"EXIST"=> (name) -> first(get_var(name)),
	"IF"=> function(value)
		global index
		global tokens

		old_index = index
		index += 1
		if value == true
			evaluate(tokens[index])
		end
		index = old_index
		skip(1)
	end,
	"FN"=> function(name, parameter_names)
		if !occursin(r"[A-Z_]", name)
			error("User-Made function names can only use characters 'A' to 'Z' and '_'")
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
			error("Please use snake_case in variable names")
		end
		if typeof(name) != String
			error("Why are you trying to assign a value to a non-string name?")
		end
		variables[begin][name] = value
	end,
	"ARRAY"=> () -> [],
	","=> (left, right) -> vcat(left,right),
	"INDEX"=> function(index, value)
		if typeof(index) != Int
			error("Array indeces should be integers, not $index")
		end
		value[index]
	end,
	"PUSH"=> function(value,array)
		if !(array isa Array)
			error("Attempting to push to an array that ins't an array")
		end
		push!(array,value)
	end,
	"POP"=> function(array)
		if !(array isa Array)
			error("Attempting to pop an array that ins't an array")
		end
		pop!(array)
	end,
	"-"=> function(left, right)
		if (typeof(left) == Int && typeof(right) != Int)
			error("You can only subtract integers from integers")
		end
		left - right
	end,
	"=="=> (left, right) -> left == right,
	"!="=> (left, right) -> left != right,
	"&&"=> (left, right) -> left && right,
	"||"=> (left, right) -> left || right,
	"<"=> function(left, right) 
		if (typeof(left) == Int && typeof(right) != Int)
			error("You can only compare integers to integers")
		end
		left < right
	end,
	">"=> function(left, right) 
		if (typeof(left) == Int && typeof(right) != Int)
			error("You can only compare integers to integers")
		end
		left > right
	end,
	"INPUT"=> () -> readline(),
	"OPEN_FD"=> function(filename, mode)
		try
			fd(open(filename, mode))
		catch err
			nothing
		end
	end,
	"READ_FD"=> function(fd)
		read(fdio(fd, false), String)
	end,
	"WRITE_FD"=> function(fd, string)
		io = fdio(fd, false)
		write(io, string)
		flush(io)
	end,
	"CLOSE_FD" => (fd) -> close(fdio(fd)),
	"SPLIT"=> function(string, split_string)
		if typeof(string) != String && typeof(split_string) != String
			error("You can only split strings")
		end
		split(string,split_string)
	end,
	"ARGS"=> () -> ARGS,
	"LENGTH"=> (value) -> length(value),
	"INDEX="=> function(index, array, value)
		if typeof(index) != Int
			error("Array indeces should be integers, not $index")
		end
		array[index] = value
	end
)

#These contain a branch
skippers = ["IF","FN"]

export native_functions, skippers
