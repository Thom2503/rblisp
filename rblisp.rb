# An implementation of lis.py (from Peter Norvig) but in ruby.
# This is more or less an exercise to understand ruby and to now more about interpreters.
# By: Thom2503
# Date: Jan 2022

# Scheme is a dialect of lisp.
# Scheme only needs 5 keywords and 8 syntactic forms.

# What does a language interpreter do?
# 1. Parsing   - makes an abstract syntax tree of the expressions and statements. 
#                this is done in the parse method.
# 2. Execution - Carrying out the parsed code in the semantic rules of the implementation language,
#                in this case ruby. 

# Example program:
program = "(begin (define r 10) (* pi (* r r)))"

## Types
# Symbol, List, Number
# to_s  , []  , to_i or to_f

# Parsing is done in two parts parsing and tokenizing
##
# Tokenize
# Convert a string to a list of tokens
# In: String   - input program
# Out Array    - syntax tree
def tokenize(str)
	str.gsub("(", " ( ").gsub(")", " ) ").split
end

##
# Parse
# Reading the scheme expr from the string also removing the "(" and ")"
# In: String - The program
# Out: Exp   - For execution
def parse(program: str)
	readFromTokens(tokens: tokenize(program))
end

##
# readFromTokens
# Read an expression from a sequence of tokens
# In: Array - list of tokens
# Out: Exp  - For execution
def readFromTokens(tokens: list)
	if tokens.length == 0
		return puts("Unexpected EOF")
	end
	token = tokens.shift
	if token == "("
		l = []
		while tokens[0] != ")"
			l << readFromTokens(tokens: tokens)
		end
		tokens.shift
		return l
	elsif token == ")"
		return puts("Unexpected ')'")
	else
		return atom(token: token)
	end
end

##
# Atom
# Numbers become numbers every other token is a symbol
# In: String - Token
# Out: Atom  - Number or Symbol
def atom(token: str)
	begin
		Integer(token)
	rescue TypeError, ArgumentError
		begin
			Float(token)
		rescue TypeError, ArgumentError
			token.to_s
		end
	end
end

puts(parse(program: program))