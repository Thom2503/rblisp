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

# Environments is mapping variables to their values. Normally this will use standard functions
# but this environment can be augmented with user defined variables. Like:
# (define r 10) => r = 10 in ruby
# This will go to an evaluator which makes the code into something real.

# Example program:
# This begins by making a variable r with value 10 and then calculating the area of a circle
program = "(begin (define r 10) (* 3.14 (* r r)))"

## Types
# Symbol, List, Number
# to_s  , []  , to_i or to_f

# Environment Class
class Env < Hash
	attr_reader :outer
	
	def initialize(params = [], args = [], outer = nil)
		@outer = outer
		(params.is_a? Array) ? update(Hash[params.zip(args)]) : update(Hash[params, args])
	end

	#TODO:
	# This can't handle an constant like PI.
	# find the innermost env where var is.
	def find(var)
		include?(var)? self : outer.find(var)
	end
end

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
			token.to_sym
		end
	end
end

##
# addGlobals
# An environment with standard Scheme procedures
# In: Env - environment
# Out: Env - for using in eval
def addGlobals(env)
	# standard arithmetic operators
	env.update({:+ => lambda {|x,y| x + y},
	            :- => lambda {|x,y| x - y},
	            :* => lambda {|x,y| x * y},
	            :/ => lambda {|x,y| x / y}})
	# equality operators
	env.update({:>      => lambda {|x,y| x > y},
	            :<      => lambda {|x,y| x < y},
	            :'='    => lambda {|x,y| x == y},
	            :>=     => lambda {|x,y| x >= y},
	            :<=     => lambda {|x,y| x <= y},
	            :eq?    => lambda {|x,y| x == y},
	            :equal? => lambda {|x,y| x == y}})
	# Other non math Scheme procedures
	env.update({:not    => lambda {|x| !x},
	            :length => lambda {|x| x.length},
	            :cons   => lambda {|x,y| [x] + y},
	            :cdr    => lambda {|x| x[1..-1]},
	            :car    => lambda {|x| x[0]},
	            :null?  => lambda {|x| x.nil?}})
	# the methods from the math module can be added to the global env.
	mathMethods = Math.singleton_methods.map{|x| x.to_s}
	env.update(Hash[mathMethods.zip(mathMethods.map{|x| lambda {|*args| Math.send(x, args)}})])

	env
end

$global_env = addGlobals(Env.new)

##
# evaluate
# Evaluate the expressions in the environment.
# In: Exp, env - Expressions and the environment together will be evaluated for execution.
# Out: Exp - expressions will leave to be executed
def evaluate(exp, env = $global_env)
  exp = exp[0] if exp.is_a? Array and exp.length == 1 
  
	if exp.is_a?(Symbol)
		return env.find(exp)[exp]
	elsif not exp.is_a?(Array)
		return exp
	end
	if exp[0] == :quote # (quote <expr>)
		if exp.length == 2
			return exp[1]
		else
			puts("Error: can't be quoted!")
		end
	elsif exp[0] == :if # (if <predicate> <consequent> <alternative>)
		if exp.length == 4
			(_, pred, conseq, alt) = exp
			return evaluate((evaluate(pred, env) ? conseq : alt), env)
		else
			puts("Error: there is something wrong in the if expression")
		end
	elsif exp[0] == :define # (define <var> <expr>)
		if exp.length == 3
			(_, var, expr) = exp
			return env[var] = evaluate(expr, env)
		else
			puts("Error: value cannot be defined")
		end
	elsif exp[0] == :lambda # (lambda (var*) <expr>
		if exp.length == 3
			(_, vars, expr) = exp
			return lambda {|*args| evaluate(expr, Env.new(vars, args, env))}
		else
			puts("Error: lambda is wrong")
		end
	elsif exp[0] == :begin # (begin <expr>)
		for expr in exp[1..-1]
			val = evaluate(expr, env)
		end
		return val
	else # (proc <expr>)
		exps = exp.map {|expr| evaluate(expr, env)}
		func = exps.shift
		return func&.call(*exps)
	end
end

puts(evaluate(parse(program: program)))