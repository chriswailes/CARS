#!/usr/bin/ruby

$: << File.expand_path(File.join(File.dirname(__FILE__), '../../'))

# require 'profile'

require 'server'
require 'common'

server = IRE::Server.new(:address => '0.0.0.0', :port => 3000, :zip => false)

server.addProcedure(:performanceTest) do |*args|
	args
end

server.run
