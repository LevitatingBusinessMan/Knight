module Logger
	function error(exception)
		if !in(:line, fieldnames(typeof(exception)))
			println("\e[31m[ERROR line] $(exception.msg)")
		else
			println("\e[31m[ERROR line $(exception.line)] $(exception.msg)\e[0m")
		end 
	end
end
