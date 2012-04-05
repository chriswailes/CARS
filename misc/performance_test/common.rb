def makeArgs(x, stringLength = 32)
	accumulator = []
	
	x.times do
		#Add in the basic types.
		accumulator += makeBasicArgs(stringLength)
		#Push on an array type that contains all of the basic types.
		accumulator.push(makeBasicArgs(stringLength))
		#Push on a hash type that contains all of the baisc types.
		hash_values = makeBasicArgs(stringLength)
		hash_keys = hash_values.map {|val| val.class.to_s}
		accumulator.push(hash_keys.zip(hash_values).inject({}) {|hash,pair| hash[pair.first] = pair.last; hash})
	end
	
	return accumulator
end

def makeBasicArgs(stringLength)
	[rand(1000000000), rand(), (0 == rand(2)), Time.now - rand(100000000), randString(stringLength)]
end

def randString(length)
	chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

	accumulator = ''
	length.times do
		accumulator += chars[rand(chars.length)].chr
	end
	
	return accumulator
end
