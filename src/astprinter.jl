import Main.Parser

module ASTPrinter
	depth = 0

	function print_tree(statements)
		for statement in statements
			print_node(statement)
			print("\n")
		end
	end

	function print_node(statement)

		global depth

		print("\t" ^ depth)

		if (typeof(statement) == Main.Parser.FUNC_CALL)
			depth += 1
			print("$(statement.name)(\n")
			for i in 1:length(statement.arguments)
				print_node(statement.arguments[i])
				if i != length(statement.arguments)
					print(",")
				end
				print("\n")
			end
			depth -= 1
			print("\t" ^ depth)
			print(")")
			return
		end

		if (typeof(statement) == Main.Parser.LITERAL)
			if typeof(statement.value) == String
				print("\"$(statement.value)\"")
			else
				print("$(statement.value)")
			end
			return
		end

		if (typeof(statement) == Main.Parser.VARIABLE)
			print("$(statement.name)")
			return
		end

		throw("impossible")

	end

	export print_tree

end
