# Author:		Chris Wailes <chris.wailes@gmail.com>
# Project: 	Chris's Advanced RPC Suite
# Date:		2012/04/05
# Description:	This file sets up autoloads for the CARS module.

# The CARS module provides the classes needed to build RPC servers and clients.
module CARS
	autoload :Client, 'cars/client'
	autoload :Server, 'cars/server'
end
