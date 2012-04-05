# Author:		Chris Wailes <chris.wailes@gmail.com>
# Project: 	Chris's Advanced RPC Suite
# Date:		2012/03/08
# Description:	This is CARS's Gem specification.

require File.expand_path("../lib/rltk/version", __FILE__)

Gem::Specification.new do |s|
	s.platform = Gem::Platform::RUBY
	
	s.name		= 'cars'
	s.version		= RLTK::VERSION
	s.summary		= "Chris's Advanced RPC Suite"
	s.description	=
		'CARS is a collection of classes for building various RPC servers and' +
		'clients.'
	
	s.files = [
			'LICENSE',
			'AUTHORS',
			'README',
			'Rakefile',
			] +
			Dir.glob('lib/cars/**/*.rb')
			
			
	s.require_path	= 'lib'
	
	s.author		= 'Chris Wailes'
	s.email		= 'chris.wailes+cars@gmail.com'
	s.homepage	= 'http://github.com/chriswailes/CARS'
	s.license		= 'University of Illinois/NCSA Open Source License'
	
	s.add_development_dependency('bundler')
	s.add_development_dependency('rake')
	s.add_development_dependency('rcov')
	s.add_development_dependency('simplecov')
	s.add_development_dependency('yard')
	
	s.test_files	= Dir.glob('test/tc_*.rb') + Dir.glob('test/ts_*.rb')
end
