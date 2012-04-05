# Author:		Chris Wailes <chris.wailes@gmail.com>
# Project: 	Chris's Advanced RPC Suite
# Date:		2012/04/05
# Description:	The Time.parse function was pretty slow and the Time.xmlschema
#			didn't handle all of the ISO 8601 formats that were needed so
#			this is a custom parser for quite a few (but not all) of the
#			formats described in ISO 8601.

############
# Requires #
############

# Standard Library
require 'time'

#######################
# Classes and Modules #
#######################

module IRE

	# CARS::RPCTime is a fast library for parsing strings in one of the many
	# ISO 8601 format into Ruby Time objects.
	module RPCTime
	
		# Takes a string in many (but not all) ISO 8601 formats and returns a
		# Time object.
		def self.fromiso8601(s)
			date, time = s.split(/T/)
			delta = 0
			
			year, month, day =
			case date.length
				when 10	then [date[0..3], date[5..6], date[8..9]]
				when 8	then [date[0..3], date[4..5], date[6..7]]
				when 4	then [date, 1, 1]
			end
			
			if time
				time, sep, zone = if time[-1] == 90 then time[0..-2], nil, '' else time.split(/([\+\-])/) end
				
				mul = if sep and sep == '-' then 1 else -1 end
				
				hour, min, sec =
				case time.length
					when 8 then [time[0..1], time[3..4], time[6..7]]
					when 6 then [time[0..1], time[2..3], time[4..5]]
					when 5 then [time[0..1], time[3..4], 0         ]
					when 4 then [time[0..1], time[2..3], 0         ]
					when 2 then [time[0..1], 0         , 0         ]
				end
				
				if zone
					dh, dm = [0, 0]
					dh, dm = [zone[0..1], zone[3..4]].map {|i| i.to_i} if zone.length == 5
					dh, dm = [zone[0..1], zone[2..3]].map {|i| i.to_i} if zone.length == 4
					dh, dm = [zone.to_i, 0] if zone.length == 2
					
					delta = mul * (60 * dh + dm)
				end
				
			else
				hour, min, sec = [0, 0, 0]
			end
			
			ret =
			if zone
				(Time.utc(year, month, day, hour, min, sec) + (delta * 60)).getlocal
			else
				Time.local(year, month, day, hour, min, sec)
			end
			
			return ret
		end
	end
end
