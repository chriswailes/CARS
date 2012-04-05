# Author:		Chris Wailes <chris.wailes@gmail.com>
# Project: 	Chris's Advanced RPC Suite
# Date:		2012/04/05
# Description:	This file contains the server code for CARS.

############
# Requires #
############

#######################
# Classes and Modules #
#######################

module CARS

	# This class implements a {standards compliant}[http://www.xmlrpc.com/spec]
	# XML-RPC server.  It offers several advanced features such as before and
	# after chains, wildcard functions, multiple parser and http server
	# backends, and output compression.
	class Server
		attr_reader :zip
		attr_reader :zip_level
		attr_reader :zip_threshold
		
		# Creates a new server object configured as specified by the options
		# hash.  Options:
		# * address - The address the http server should bind to. (Default: 127.0.0.1)
		# * port - The port the server should listen on. (Default: 3000)
		# * path - The path the XMLRPC server should be mounted on. (Default: /)
		# * httpd - The http server backend to be used.  Either :webrick or :mongrel.  (Default: :mongrel)
		# * parser - The XML parser to be used.  Currently only libxml is implemented.  (Default: :libxml)
		# * wildcard - The character that is treated as a wildcard when processing procedure definitions.  (Default: _)
		# * zip - Indicates if the server should support gziped output.  Output will only be zipped if the client supports it.  (Default: true)
		# * zip_level - The level of zipping to be done. 1-9 (Default: 9)
		# * zip_threshold - Anything below this number (in bytes) will not be zipped if zipping is enabled. (Default: 524288 a.k.a. 500KiB)
		def initialize(options = {})
			@procedures	= {}
			@wildcards	= []
			@befores		= []
			@afters		= []
			
			@default_procedure = default_procedure()
			
			address	= options[:address] || '127.0.0.1'
			port		= options[:port] || 3000
			path		= options[:path] || '/'
			
			# set up the server
			@httpd =
			if options[:httpd] == :webrick
				require 'webrick_servlet'
				WEBrickServlet.new(self, address, port, path)
			else
				require 'mongrel_servlet'
				MongrelServlet.new(self, address, port, path)
			end

			# set up the parser
			@parser =
			if options[:parser] == :rexml
				require 'rexml_parser'
				REXMLParser.new()
			else
				require 'libxml_parser'
				LibXMLParser.new()
			end

			@zip =
			if options[:zip] == false
				false
			else
				require 'zipper'
			
				true
			end
			
			@wildcard = Regexp.escape(options[:wildcard] || '_')
			
			@zip_level	= options[:zip_level] || 9
			@zip_threshold	= options[:zip_threshold] || 500000
		end
		
		# Used to append a proc object to affters list.
		def add_after(&block)
			@afters << block
		end
		
		# Used to append a proc object to the befores list.
		def add_before(&block)
			@befores << block
		end
		
		# Used to add either a normal or wildcard procedure to the server.
		# If you want to have a procedure that only accepts 0 arguments
		# remember to put an empty parameters list on your proc object,
		# otherwise it will have an arity of -1 and will accept calls to it
		# with any number of paramaters.  Examples:
		#	server.addProcedure('foo') do
		#		# Accepts any number of arguments.
		#		...
		#	end
		#
		#	server.addProcedure('bar') do ||
		#		# Accepts only calls with 0 arguments.
		#		...
		#	end
		#
		# When definting wildcard procedures it is important to know that
		# when the server is looking for matches it will rank the
		# definitions as follows, and select the first one:
		# * A.B.C
		# * _.B.C
		# * A._.C
		# * A.B._
		# * _._.C
		# * _.B._
		# * A._._
		# * _._._
		def add_procedure(name, &block)
			if name.to_s.match(Regexp.new("((^|\.)#{@wildcard}\.|\.#{@wildcard}(\.|$))"))
				@wildcards << WildcardProcedure.new(name.to_s, block, @wildcard)
				
			else
				@procedures[name.to_s] = Procedure.new(block)
			end
		end
		
		# This is the method that the HTTP server calls when a request comes
		# in.  It handles decoding, the before and after chains, calling the
		# procedure handler, and re-encoding.
		def do_request(request, headers = nil)
			call = @parser.from_XML(request)

			@befores.each do |before|
				if before.call(call, headers)
					return @parser.to_XML(call.response)
				end
			end

			# If a call contains a wildcard section it needs to be processed
			# by the default procedure as there is no good way to define an
			# actual handler for it.
			call.response =
			if call.name.split('.').include?(@wildcard)
				@defaultProcedure.call(call.name, call.args, headers)
			else
				doProcedureCall(call.name, call.args, headers)
			end

			@afters.each do |after|
				if after.call(call, headers)
					break
				end
			end

			@parser.to_XML(call.response)
		end
		
		# Start the server running and accepting requests.  Procedures should
		# be registered by now.
		def run
			@httpd.run
		end
		
		# Sets the procedure that should be called when no other match is
		# found.  Default procedures should accept the name of the procedure
		# called, an array of given arguments, and the headers from the HTTP
		# server as arguments.
		def set_default_procedure(&block)
			@default_procedure = block
		end
		
		# This is just a handy way to store the default procedure so that it
		# can be set in initalize.
		private
		def default_procedure
			Proc.new do |name, args, headers|
				raise RPCFault.new(-99, "No such procedure #{name} with #{args.length} arguments.")
			end
		end
		
		# This hides some of the nastier parts of actually calling a
		# procedure's proc object.  It catches errors and tries to find a
		# matching wildcard procedure if no definition can be found.
		def do_procedure_call(name, args, headers)
			if @procedures.key?(name)
				begin
					@procedures[name].call(*args)
					
				rescue ArgumentError
					do_wildcard(name, args, headers)
					
				rescue RPCFault => e
					e
					
				rescue Exception
					puts e.message
					puts e.backtrace
					
					RPCFault.new(-1, 'An error has occured in the server.  Please contact the server administrator.')
				end
				
			else
				do_wildcard(name, args)
			end
		end
		
		# Searches the defined wildcard functions to find the best match.  If
		# one can't be found it calls the default procedure.
		def do_wildcard(name, args, headers)
			if (procedure = @wildcards.select {|wildcard| wildcard.accepts?(name)}.sort.first)
				begin
					procedure.call(name, args)
					
				rescue ArgumentError
					RPCFault.new(-99, "No such procedure #{name} with #{args.length} arguments.")
					
				rescue Exception => e
					puts e.message
					puts e.backtrace
					
					RPCFault.new(-1, 'An error has occured in the server.  Please contact the server administrator.')
				end
			else
				@default_procedure.call(name, args, headers)
			end
		end
		
		# A wrapper class used to handle the uglier parts of checking arity.
		class Procedure
			
			# Does what you think it does.
			def initialize(proc)
				@proc = proc
			end
		
			# This is just here to hide the arity checking from the control
			# flow of the rest of the code.
			def call(*args)
				if @proc.arity >= 0 and args.length == @proc.arity
					@proc.call(*args)
					
				elsif @proc.arity < 0 and args.length >= @proc.arity.abs - 1
					@proc.call(*args)
					
				else
					raise ArgumentError
				end
			end
		end
		
		# A wrapper class to help identify matching wildcard procedures and
		# picking the correct one to call.
		class WildcardProcedure
			# Create a new WildcardProcedure object.  Needs its name, a proc
			# object and the wildcard character used as arguments.
			def initialize(name, proc, wildcard)
				@proc	= proc
				@wildcard	= wildcard
				
				@sections		= name.split('.')
				@wildcards	= count_wildcards(name)
				
				@score = 0
				@sections.each_with_index do |section, index|
					if section == @wildcard then @score += index + 1 end
				end
			end
			
			def <=>(other)
				self.score <=> other.score
			end
			
			def accepts?(name)
				split_name = name.split('.')
				
				result = (split_name.length == @sections.length)
				@sections.each_with_index do |section, index|
					result &=
					if section == @wildcard
						true
					else
						section == split_name[index]
					end
				end
				
				return result
			end
			
			# Call the actual procedure.
			def call(name, args)
				if @proc.arity >= 0 and (args.length + 1) == @proc.arity
					@proc.call(*(getNameArgs(name) + args))
					
				elsif @proc.arity < 0 and args.length >= @proc.arity.abs
					#This else would have args.length + 1 >= @proc.arity.abs -1
					#but I simplified it.
					@proc.call(*(getNameArgs(name) + args))
					
				else
					raise ArgumentError
				end
			end
			
			protected
			
			# Used to expose the score variable so sorting can occur.
			def score
				@score
			end
			
			private
			
			# Counts the number of wildcards in a procedure definition.
			def count_wildcards(name)
				name.split('.').inject(0) do |count, section|
					if section == @wildcard
						count + 1
					else
						count
					end
				end
			end
			
			# Pulls parts of called procedures name's out that correspond to
			# wildcard sections for this procedure.
			def get_name_args(name)
				split_name	= name.split('.')
				result		= []
				
				@sections.each_with_index do |section, index|
					result << split_name[index] if section == @wildcard
				end
				
				return result
			end
		end
	end
end
