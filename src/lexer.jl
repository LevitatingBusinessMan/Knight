module Lexer

	include("tokentypes.jl")

	struct Token
		type::TokenType
		lexeme::String
	end

	#type declarations on global variables are not yet supported
	index = 1
	source = ""
	line = 0

	function lex(source_)

		global index
		global source
		global line

		line = 0
		index = 1
		source = source_
		tokens = []
	
		while index <= length(source)
			current_char = source[index]

			#function_name
			if occursin(r"[A-Z!=<>\-=+*/;_]", string(current_char))
				lexeme = consume(r"[A-Z!=<>\-=+*/;_]")
				push!(tokens, Token(FUNCTION_NAME, lexeme))

			#identifier
			elseif occursin(r"[a-z_]", string(current_char))
				lexeme = consume(r"[a-z_]")

				type = (lexeme == "true" ? TRUE
					: lexeme == "false" ? FALSE
					: lexeme == "null" ? NULL
					: IDENTIFIER)

				push!(tokens, Token(type, lexeme))

			#numbers
			# I'll add floats later
			elseif occursin(r"[0-9]", string(current_char))
				lexeme = consume(r"[0-9]")
				push!(tokens, Token(NUMBER, lexeme))

			#string
			elseif '"' == current_char
				lexeme = consume_till('"')
				push!(tokens, Token(STRING, lexeme))

			#comments
			elseif "#" == current_char
				consume_till("\n")
	
			#increase linenum
			elseif "\n" == current_char
				line += 1
				index += 1
			
			#unknown
			elseif occursin(r"\s", string(current_char))
				index += 1
			else
				error("Unknown token '$(current_char)'")
			end
		end

		return tokens
	end

	function consume(regex)
		global index
		global source
		next = index + 1
		while length(source)+1 != next && occursin(regex, string(source[next]))
			next += 1
		end
		lexeme = source[index:next-1]
		index = next
		return lexeme
	end

	function consume_till(char)
		global index
		global source
		next = index + 1
		while length(source)+1 != next && char != source[next]
			next += 1
		end
		lexeme = source[index:next]
		index = next+1
		return lexeme
	end

	struct LexingError <: Exception
		msg::String
		line::Integer
	end

	function error(msg)
		throw(LexingError(msg, line))
	end

	export lex
end
