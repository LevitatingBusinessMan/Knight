function print_value(value, newline=true)

	print_ = newline ? println : print

	if typeof(value) == nothing
		return print_("null")
	end

	if value isa Array
		print("[")
		for i in 1:length(value)
			print_value(value[i], false)
			if length(value) != i
				print(", ")
			end
		end
		return print_("]")
	end

	# Assuming it'll print fine
	print_(value)
end

export print_value
