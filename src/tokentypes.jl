@enum TokenType begin
	FUNCTION_NAME
	IDENTIFIER
	STRING
	NUMBER
end

#=
You might thing you are missing these:

BANG, BANG_EQUAL,
EQUAL, EQUAL_EQUAL,
GREATER, GREATER_EQUAL,
LESS, LESS_EQUAL,

MINUS, PLUS, SEMICOLON, SLASH, ASTERISK

But these are really all just function identifiers
=#
