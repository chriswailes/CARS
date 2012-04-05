# =Author(s)
# Joshua Stone (joshs@illinois.edu)
#
# =Project
# Illinois xmlRpc Engine (IRE)
#
# =File Description
# Used to test basic RPC classes.
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

require 'rpc'

include IRE

class RPCTest < Test::Unit::TestCase
  def test_rpc
    assert rpc = RPC.new("test.function", 1, 2, "3"), "Could not create RPC object"
    assert rpc.name == "test.function", "RPC object name field broken"
    assert rpc.args == [1,2,"3"], "RPC object args field broken"
    nother = RPC.new("test.function", 1, 2, "3")
    assert rpc == nother, "RPC object equality operator broken"
  end

  def test_rpcfault
    assert fault = RPCFault.new(123, "test message"), "Could not create RPCFault"
    assert fault.code == 123, "RPCFault code field broken"
    assert fault.message == "test message", "RPCFault message field broken"
    assert_raise(Exception) { RPCFault.new("123", "test message") }
    assert_raise(Exception) { RPCFault.new(123, 123) }
    assert_raise(Exception) { RPCFault.new("123", 123) }
    nother = RPCFault.new(123, "test message")
    assert fault == nother, "RPCFault equality operator broken"
  end
end
