#!/usr/bin/ruby

require 'benchmark'
require 'uri'
require 'xmlrpc/client'

require 'common'

if ARGV[0]
	begin
		address = URI.parse(ARGV[0])
	rescue URI::InvalidURIError
		puts "Usage: ./ire_client.rb <server address>"
		exit(1)
	end
else
	puts "Usage: ./ire_client.rb <server address>"
	exit(1)
end

client = XMLRPC::Client.new(address.host, address.path, address.port)

Benchmark.bm(11) do |reporter|
	args = makeArgs(10)
	
	reporter.report("1 Run") do
		client.call('performanceTest', *args)
	end
	
	reporter.report("10 Runs") do
		10.times {client.call('performanceTest', *args)}
	end
	
	reporter.report("100 Runs") do
		100.times {client.call('performanceTest', *args)}
	end
	
	reporter.report("1000 Runs") do
		1000.times {client.call('performanceTest', *args)}
	end
end
