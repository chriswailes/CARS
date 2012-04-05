# Author:		Chris Wailes <chris.wailes@gmail.com>
# Project: 	Chris's Advanced RPC Suite
# Date:		2012/04/05
# Description:	This is CARS's Rakefile.

##############
# Rake Tasks #
##############

require 'rake/testtask'
require 'bundler'

require File.expand_path("../lib/rltk/version", __FILE__)

begin
	require 'rdoc/task'
	
	RDoc::Task.new do |t|
		t.title		= 'The Ruby Language Toolkit'
		t.main		= 'README'
		t.rdoc_dir	= 'doc'
	
		t.rdoc_files.include('README', 'lib/*.rb', 'lib/rltk/*.rb', 'lib/rltk/**/*.rb')
	end

rescue LoadError
	warn 'RDoc is not installed.'
end

begin
	require 'yard'

	YARD::Rake::YardocTask.new do |t|
		t.options = ["--no-private"]
		t.files   = Dir['lib/**/*.rb']
	end
	
rescue LoadError
	warn 'Yard is not installed.'

end

Rake::TestTask.new do |t|
	t.libs << 'test'
	t.loader = :testrb
	t.test_files = FileList['test/ts_cars.rb']
end

if RUBY_VERSION.match(/1\.8/)
	begin
		require 'rcov/rcovtask'
		
		Rcov::RcovTask.new do |t|
			t.libs      << 'test'
			t.rcov_opts << '--exclude gems,ruby'
			
			t.test_files = FileList['test/tc_*.rb']
		end
		
	rescue LoadError
		warn 'Rcov not installed.'
	end
end

# Bundler tasks.
Bundler::GemHelper.install_tasks

