#!/usr/bin/ruby

require 'xmlrpc/server'

server = XMLRPC::Server.new(3000, '0.0.0.0')

Signal.trap(2) { server.shutdown }

server.add_handler('performanceTest') do |*args|
	args
end

server.serve
