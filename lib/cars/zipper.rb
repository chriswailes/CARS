# Author:		Chris Wailes <chris.wailes@gmail.com>
# Project: 	Chris's Advanced RPC Suite
# Date:		2012/04/05
# Description:	This file contains wrapper functions for zipping and unzipping
#			strings using ZLib.

############
# Requires #
############

# Standard Library
require 'stringio'
require 'zlib'

#######################
# Classes and Modules #
#######################

module CARS

	# Zipper is a simple module that contains wrapper functions for zipping
	# and unzipping String or StringIO objects using ZLib.
	module Zipper

		# Unzip a String or StringIO object using gzip and ZLib.
		def Zipper.unzip(input)
			if input.is_a?(String) then input = StringIO.new(input) end
			
			reader	= Zlib::GzipReader.new(input)
			response	= reader.read
			reader.close
			
			return response
		end
		
		# Zip a string using gzip and ZLib.
		def Zipper.zip(string, level = 5)
			writer = Zlib::GzipWriter.new(StringIO.new, level)
			writer.write(string)
			writer.close.string
		end
	end
end
