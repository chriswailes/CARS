# Author:		Chris Wailes <chris.wailes@gmail.com>
# Project: 	Chris's Advanced RPC Suite
# Date:		2012/04/05
# Description:	This file contains the LibXML-based parser.

############
# Requires #
############

# Standard Library
require 'time'
require 'base64'

# Gems
require 'rubygems'
require 'libxml'

# CARS
require 'rpctime'
require 'rpc'

#######################
# Classes and Modules #
#######################

include LibXML::XML

module CARS

	# This class uses the libxml wrapped ruby library to handle conversion
	# from XMLRPC XML representation of objects to Ruby objects and vice
	# versa.
	class LibXMLParser
		def initialize
			@nonprintable = /[\x00-\x08\x0b-\x0c\x0e-\x1f\x7f-\xff]/
		end

		# Take a Ruby object (arrays and hashes too) and return the XML
		# document string that represents the XMLRPC methodResponse,
		# methodCall, or fault for the data.
		def to_XML(input, format = false)
			case input
			when RPC
				result =  Node.new('methodCall')
				result << Node.new('methodName', input.name)
				params =  Node.new('params')
				
				input.args.each do |a|
					param	=  Node.new('param')
					param	<< recToDOM(a)
					params	<< param
				end
				
				result << params
				
			when RPCFault
				h				= Hash.new
				h['faultCode']		= input.code
				h['faultString']	= input.message
				
				payload	=  Node.new('fault')
				payload	<< recToDOM(h)
				result	=  Node.new('methodResponse') << payload
				
			else
				payload	=  Node.new('params')
				param	=  Node.new('param') << recToDOM(input)
				payload	<< param
				result	=  Node.new('methodResponse') << payload
			end
			
			(doc = Document.new()).root = result
			
			return doc.to_s(format)
		end

		# Given some XML that should be an XMLRPC request, convert it to a
		# Ruby object.  This may result in some complex collections as well.
		def from_XML(xml)
			p, p.string = LibXML::XML::Parser.new, xml
			
			root = p.parse.root
			
			return from_DOM(root)
		end

		# Takes an object and returns an XML node containing its XMLRPC
		# representation.  These operate recursively, in case you have
		# weirdly nested data structures.  These can be used to build an XML
		# document (in to_XML above).
		def to_DOM(v)
			rpc_val(
				case v
					when Hash			then hash_to_struct(v)
					when Fixnum		then Node.new('int', v.to_s)
					when Float		then Node.new('double', v.to_s)
					when String		then rpc_string(v)
					when TrueClass		then Node.new('boolean', '1')
					when FalseClass	then Node.new('boolean', '0')
					when Time			then Node.new('dateTime.iso8601', v.iso8601.to_s)
					when Array		then Node.new('array') << v.inject(Node.new('data')) {|i,j| i << to_DOM(j); i}
				end
			)
		end

		# If a string has non-printable characters in it, it should be Base64
		# encoded.  This handles returning the appropriate DOM object.
		def rpc_string(s)
			return Node.new('string', s) unless s =~ @nonprintable
			return Node.new('base64', Base64::encode64(s))
		end

		# Given a hash, create the correct DOM represenation for including in
		# an XML document.
		def hash_to_struct(h)
			struct = Node.new('struct')
			
			h.each_pair do |key, val|
				pair		=  Node.new('member')
				pair		<< Node.new('name', key.to_s)
				pair		<< to_DOM(val)
				struct	<< pair
			end
			
			return struct
		end

		# This is "ugly", so I decided to abstract it out.
		def rpc_value(node)
			return Node.new('value') << node
		end

		# This recursively handles conversion of XMLRPC data types to Ruby objects.
		# Lists of hashes of weird things should work too.
		def from_DOM(node)
			case node.name
			when 'methodCall'		then build_fun(node)
			when 'methodResponse'	then build_response(node.children[0])
			when 'int', 'i4'		then node.content.to_i
			when 'string'			then node.content
			when 'boolean'			then node.content == '1'
			when 'double'			then node.content.to_f
			when 'array'			then node.find("#{node.path}/data/value/*").map {|i| from_DOM i}
			when 'dateTime.iso8601'	then RPCTime.fromiso8601(node.content)
			when 'base64'			then Base64::decode64(node.content)
			when 'struct'			then build_hash(node)
			else					return "<nil:#{node.name}>"
			end
		end

		# Based on the type of incoming node we build an appropriate Ruby objects.
		def build_response(node)
			case node.name
			when 'fault'
				s = from_DOM(node.find("#{node.path}/value/*")[0])
				return RPCFault.new(s['faultCode'], s['faultString'].to_s)
				
			when 'params'
				return node.find("#{node.path}/param/value/*").map {|i| recFromDOM i}
				
			else
				raise 'Unrecognized XMLRPC response'
			end
		end

		# Construct a function call object from the provided DOM node.  This will
		# recursively call from_DOM.
		def build_fun(node)
			name = node.find('methodName/child::text()').map[0].content
			args = node.find('params/param/value/*').map {|i| recFromDOM i }
			call = RPC.new(name, *args)
			
			return call
		end

		# Take an XMLRPC "struct" DOM node and produce a ruby hash out of it.
		# This will recursively call from_DOM.
		def build_hash(node)
			keys = node.find("#{node.path}/member/name").map {|i| i.content}
			vals = node.find("#{node.path}/member/value/*").map {|i| from_DOM i}
			
			return keys.zip(vals).inject({}) {|h, (i,j)| h[i] = j; h}
		end
	end
end

