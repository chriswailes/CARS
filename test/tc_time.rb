# =Author(s)
# Joshua Stone (joshs@illinois.edu)
#
# =Project
# Illinois xmlRpc Engine (IRE)
#
# =File Description
# Used to test RPCTime class.
#
# =Copyright
# Copyright 2008, The Board of Trustees of the University of Illinois.
#
# =License
# IRE is open source software, released under the University of Illinois/NCSA
# Open Source License.  A copy of this license is included in the root
# directory of the distributed source.

require 'test/unit'
require 'time'

require 'rpctime'

class RPCTimeTest < Test::Unit::TestCase
	def test_parseiso8601
		assert IRE::RPCTime.fromiso8601("2008-10-17") == Time.parse("2008-10-17")
		assert IRE::RPCTime.fromiso8601("20081017") == Time.parse("20081017")
		assert IRE::RPCTime.fromiso8601("2008") == Time.local(2008)
		assert IRE::RPCTime.fromiso8601("2008-10-17T15:31:10") == Time.parse("2008-10-17T15:31:10")
		assert IRE::RPCTime.fromiso8601("2008-10-17T15:31") == Time.parse("2008-10-17T15:31")
		assert IRE::RPCTime.fromiso8601("2008-10-17T153110") == Time.local(2008,10,17,15,31,10)
		assert IRE::RPCTime.fromiso8601("2008-10-17T1531") == Time.local(2008,10,17,15,31)
		assert IRE::RPCTime.fromiso8601("2008-10-17T15") == Time.local(2008,10,17,15)
		assert IRE::RPCTime.fromiso8601("20081017T153110") == Time.parse("20081017T153110")
		assert IRE::RPCTime.fromiso8601("20081017T15:31:10") == Time.parse("20081017T15:31:10")
		assert IRE::RPCTime.fromiso8601("2008T15:31:10") == Time.local(2008,1,1,15,31,10)
		assert IRE::RPCTime.fromiso8601("2008T153100") == Time.local(2008,1,1,15,31,0)
		assert IRE::RPCTime.fromiso8601("2008-10-17T15:31:10-05:00") == Time.parse("2008-10-17T15:31:10-05:00")
		assert IRE::RPCTime.fromiso8601("2008-10-17T15:31Z") == Time.utc(2008,10,17,15,31,0)
		assert IRE::RPCTime.fromiso8601("2008-10-17T153110Z") == Time.utc(2008,10,17,15,31,10)
		assert IRE::RPCTime.fromiso8601("2008-10-17T1531-05:30") == Time.local(2008,10,17,16,01)
		assert IRE::RPCTime.fromiso8601("2008-10-17T15+05:30") == Time.utc(2008,10,17,9,30)
		assert IRE::RPCTime.fromiso8601("20081017T153100+0530") == Time.parse("20081017T153100+0530")
		assert IRE::RPCTime.fromiso8601("20081017T15:31:00-0530") == Time.parse("20081017T15:31:00-0530")
		assert IRE::RPCTime.fromiso8601("2008T15:31:00+05") == Time.utc(2008,1,1,10,31)
		assert IRE::RPCTime.fromiso8601("2008T153100-05") == Time.utc(2008,1,1,20,31)
		assert IRE::RPCTime.fromiso8601("2008-10-17T15:31:00Z"  ) == Time.parse("2008-10-17T15:31:00Z")
	end
end
