# Author:		Chris Wailes <chris.wailes@gmail.com>
# Project: 	Chris's Advanced RPC Suite
# Date:		2012/04/05
# Description:	The WEBrick servlet for CARS.

############
# Requires #
############

# Standard Library
require 'webrick'

#######################
# Classes and Modules #
#######################

module CARS

	# This is the WEBrick server for CARS.  If you really want to use it you
	# can set the :server option to :webrick when you create an CARS::Server.
	class WEBrickServlet
	
		# Creates a new WEBrick HTTP server for handling XML-RPC.  All of
		# the arguments are filled in by the CARS::Server.new function based
		# on the options it receives.
		def initialize(xmlrpc_engine, address, port, path)
			@http_server = WEBrick::HTTPServer.new(:Port => port, :BindAddress => address)
			@http_server.mount(path, XMLRPCHandler, xmlrpc_engine)
			trap('INT') { @http_server.shutdown }
		end
		
		# Start the WEBrick server.
		def run
			@http_server.start
		end

		class XMLRPCHandler < WEBrick::HTTPServlet::AbstractServlet #:nodoc:
			def do_POST(request, response)
				response['Content-Type'] = 'text/xml'
				
				input =
				if request['Content-Encoding'] == 'gzip'
					Zipper.unzip(request.body)
				else
					request.body
				end
				
				response.body = @xmlrpc_engine.doRequest(input, request.header)
				
				if @xmlrpc_engine.zip and
					output.length >= @xmlrpc_engine.zip_threshold and
					request['Accept-Encoding'] and
					request['Accept-Encoding'].include?('gzip')
				
					response['Content-Encoding'] = 'gzip'
					response.body = Zipper.zip(response.body, @xmlrpc_engine.zip_level)
				else
					@xmlrpc_engine.doRequest(input, request.header)
				end
			end
			
			def initialize(server, xmlrpc_engine)
				super(server)
				@xmlrpc_engine = xmlrpc_engine
			end
		end
	end
end
