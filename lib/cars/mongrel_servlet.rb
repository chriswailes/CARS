# Author:		Chris Wailes <chris.wailes@gmail.com>
# Project: 	Chris's Advanced RPC Suite
# Date:		2012/04/05
# Description:	This file contains the mongrel servlet.

############
# Requires #
############

# Gems
require 'rubygems'
require 'mongrel'

#######################
# Classes and Modules #
#######################

module CARS

	# This is the Mongrel server for CARS.  It is the default HTTP server.
	class MongrelServlet
		# Creates a new Mongrel HTTP server for handling XML-RPC.  All of
		# the arguments are filled in by the CARS::Server.new function based
		# on the options it receives.
		def initialize(xmlrpc_engine, address, port, path)
			@http_server = Mongrel::HttpServer.new(address, port)
			@http_server.register(path, XMLRPCHandler.new(xmlrpc_engine))
			trap('INT') { puts "\nStopping server."; @http_server.stop; }
		end
		
		# Starts the Mongrel server.
		def run
			@http_server.run.join
		end
		
		class XMLRPCHandler < Mongrel::HttpHandler
			def initialize(xmlrpc_engine)
				super()
				@xmlrpc_engine = xmlrpc_engine
			end
			
			def process(request, response)
				response.start do |head, body|
					head['Content-Type'] = 'text/xml'
					
					input =
						if request.params['HTTP_CONTENT_ENCODING'] == 'gzip'
							Zipper.unzip(request.body)
						else
							request.body.read
						end
					
					output = @xmlrpc_engine.doRequest(input, request.params)
					
					if @xmlrpc_engine.zip and
						output.length >= @xmlrpc_engine.zip_threshold and
						request.params['HTTP_ACCEPT_ENCODING'] and
						request.params['HTTP_ACCEPT_ENCODING'].split(/\s,\s/).include?('gzip')
						
						head['Content-Encoding'] = 'gzip'
						output = Zipper.zip(output, @xmlrpc_engine.zip_level)
					end
					
					body.write(output)
				end
			end
		end
	end
end
