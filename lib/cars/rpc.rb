# Author:		Chris Wailes <chris.wailes@gmail.com>
# Project: 	Chris's Advanced RPC Suite
# Date:		2012/04/05
# Description:	This file contains defitions of various classes involved in
#			remote procedure calls.

############
# Requires #
############

#######################
# Classes and Modules #
#######################

module CARS
	# This class is used internally to represent an incoming procedure call.
	# The name is used to identify the procedure that is to be run, the args
	# variable holds the arguments of the call, the response is what will be
	# returned when processing is done, and state is available for storing
	# information by proc objects in the before and after chains.
	class RPC
		attr_accessor :name, :args, :response, :state
		
		# Takes the name of the process to be called and its arguments.
		def initialize(name, *args)
			@name	= name.to_s
			@args	= args
			@response	= nil
			
			@state = {}
		end
		
		# A simple comparison operator.
		def == (a)
			return @name == a.name && @args == a.args
		end
	end
	
	# RPCFault represents a fault as described by the XML-RPC spec.  They can
	# be raised at any time inside procedures, but before and after proc
	# objects should instead set the response of the call they are handling
	# and return true.
	class RPCFault < Exception
		attr_accessor :code
		
		# Creates a new RPCFault.  The first argument is the integer fault
		# code, the second is the message to be returned in the fault.
		def initialize(code, message)
			raise Exception.new('Fault code must be integer.') unless code.is_a?(Fixnum)
			raise Exception.new('Fault message must be string.') unless message.is_a?(String)
			
			super(message)
			@code = code
		end
		
		# A simple comparison operator.
		def == (a)
			return @code == a.code && self.message == a.message
		end
	end
end
