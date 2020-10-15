module Logger
	function error(exception)
		if !in(:line, fieldnames(typeof(exception)))
			println("\e[31m[ERROR] $(exception)\e[0m")
		else
			println("\e[31m[ERROR line $(exception.line)] $(exception.msg)\e[0m")
		end 
	end
end
