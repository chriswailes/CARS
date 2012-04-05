#!/usr/bin/ruby

$: << File.expand_path(File.join(File.dirname(__FILE__), '../'))

require 'rubygems'
require 'activesupport'

require 'server'

server = IRE::Server.new(:address => '0.0.0.0', :port => 3000)

server.addProcedure('foo.bar') do ||
	"In Xanadu did Kubla Khan\nA stately pleasure-dome decree:"
end

server.addProcedure('foo.baz') do ||
	"Where Alph, the sacred river, ran\nThrough caverns measureless to man\nDown to a sunless sea."
end

server.run
