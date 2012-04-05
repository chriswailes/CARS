# =Author(s)
# Joshua Stone (joshs@illinois.edu)
#
# =Project
# Illinois xmlRpc Engine (IRE)
#
# =File Description
# Used to test the libxml parser.
#
# =Copyright
# Copyright 2008, The Board of Trustees of the University of Illinois.
#
# =License
# IRE is open source software, released under the University of Illinois/NCSA
# Open Source License.  A copy of this license is included in the root
# directory of the distributed source.

require 'test/unit'

require 'libxml_parser'

include IRE

def node2xml(node, format = false)
  a = LibXML::XML::Document.new()
  a.root = node
  return a.to_s(format)
end

def xml2node(xml)
  p, p.string = LibXML::XML::Parser.new, xml
  return p.parse.root
end

class LIBXMLText < Test::Unit::TestCase
  def test_to_dom
    assert node2xml(@p.recToDOM(1)) == "<?xml version=\"1.0\"?>\n<value><int>1</int></value>\n", "int -> XML broken"
    assert node2xml(@p.recToDOM(true)) == "<?xml version=\"1.0\"?>\n<value><boolean>1</boolean></value>\n", "true -> XML broken"
    assert node2xml(@p.recToDOM(false)) == "<?xml version=\"1.0\"?>\n<value><boolean>0</boolean></value>\n", "false -> XML broken"
    assert node2xml(@p.recToDOM("pi")) == "<?xml version=\"1.0\"?>\n<value><string>pi</string></value>\n", "string -> XML broken"
    assert node2xml(@p.recToDOM(3.141)) == "<?xml version=\"1.0\"?>\n<value><double>3.141</double></value>\n", "double -> XML broken"
    assert node2xml(@p.recToDOM(Time.parse("2008-10-15"))) == "<?xml version=\"1.0\"?>\n<value><dateTime.iso8601>2008-10-15T00:00:00-05:00</dateTime.iso8601></value>\n", "time -> XML broken"
    assert node2xml(@p.recToDOM("\x00password")) == "<?xml version=\"1.0\"?>\n<value><base64>AHBhc3N3b3Jk\n</base64></value>\n", "binary-string -> XML broken"
    assert node2xml(@p.recToDOM({1=>2,3=>4})) == "<?xml version=\"1.0\"?>\n<value><struct><member><name>1</name><value><int>2</int></value></member><member><name>3</name><value><int>4</int></value></member></struct></value>\n", "struct -> XML broken"
    assert node2xml(@p.recToDOM([1,2,3])) == "<?xml version=\"1.0\"?>\n<value><array><data><value><int>1</int></value><value><int>2</int></value><value><int>3</int></value></data></array></value>\n", "array -> XML broken"
  end

  def test_from_dom
    assert @p.recFromDOM(xml2node("<?xml version=\"1.0\"?>\n<int>1</int>\n")) == 1, "XML -> int broken"
    assert @p.recFromDOM(xml2node("<?xml version=\"1.0\"?>\n<boolean>1</boolean>\n")) == true, "XML -> true broken"
    assert @p.recFromDOM(xml2node("<?xml version=\"1.0\"?>\n<boolean>0</boolean>\n")) == false, "XML -> false broken"
    assert @p.recFromDOM(xml2node("<?xml version=\"1.0\"?>\n<string>pi</string>\n")) == "pi", "XML -> string broken"
    assert @p.recFromDOM(xml2node("<?xml version=\"1.0\"?>\n<double>3.141</double>\n")) == 3.141, "XML -> double broken"
    assert @p.recFromDOM(xml2node("<?xml version=\"1.0\"?>\n<dateTime.iso8601>2008-10-15T00:00:00-05:00</dateTime.iso8601>\n")) == Time.parse("2008-10-15"), "XML -> time broken"
    assert @p.recFromDOM(xml2node("<?xml version=\"1.0\"?>\n<base64>AHBhc3N3b3Jk\n</base64>\n")) == "\x00password", "binary-XML -> string broken"
    assert @p.recFromDOM(xml2node("<?xml version=\"1.0\"?>\n<struct><member><name>1</name><value><int>2</int></value></member><member><name>3</name><value><int>4</int></value></member></struct>\n")) == {"1"=>2,"3"=>4}, "XML -> struct broken"
    assert @p.recFromDOM(xml2node("<?xml version=\"1.0\"?>\n<array><data><value><int>1</int></value><value><int>2</int></value><value><int>3</int></value></data></array>\n")) == [1,2,3], "XML -> array broken"
  end

  def test_rpc_fault_toxml
    assert fault = RPCFault.new(123, "test message"), "Error creating RPCFault"
    faultxml = "<?xml version=\"1.0\"?>\n<methodResponse><fault><value><struct><member><name>faultCode</name><value><int>123</int></value></member><member><name>faultString</name><value><string>test message</string></value></member></struct></value></fault></methodResponse>\n"
    assert faultxml == @p.toXML(fault), "Error converting RPCFault to XML"
  end

  def test_rpc_call_toxml
    assert call = RPC.new("test.fun", [1,2,"3"])
    callxml = "<?xml version=\"1.0\"?>\n<methodCall><methodName>test.fun</methodName><params><param><value><array><data><value><int>1</int></value><value><int>2</int></value><value><string>3</string></value></data></array></value></param></params></methodCall>\n"
    assert callxml == @p.toXML(call), "Error converting RPC object to XML"
  end
  
  def test_rpc_response_toxml
    assert resp = [1,2,"3"]
    respxml = "<?xml version=\"1.0\"?>\n<methodResponse><params><param><value><array><data><value><int>1</int></value><value><int>2</int></value><value><string>3</string></value></data></array></value></param></params></methodResponse>\n"
    assert respxml == @p.toXML(resp), "Error converting response to XML"
  end

  def test_rpc_fault_toobj
    f = RPCFault.new(123, "test message")
    faultxml = "<?xml version=\"1.0\"?>\n<methodResponse><fault><value><struct><member><name>faultCode</name><value><int>123</int></value></member><member><name>faultString</name><value><string>test message</string></value></member></struct></value></fault></methodResponse>\n"
    assert a = @p.fromXML(faultxml), "Couldn't convert XML to RPCFault"
    assert a == f, "fromXML didn't create equal XMLRPCFault"
  end

  def test_rpc_call_toobj
    c = RPC.new("test.fun", [1,2,"3"])
    callxml = "<?xml version=\"1.0\"?>\n<methodCall><methodName>test.fun</methodName><params><param><value><array><data><value><int>1</int></value><value><int>2</int></value><value><string>3</string></value></data></array></value></param></params></methodCall>\n"
    assert a = @p.fromXML(callxml), "Couldn't convert RPC call from XML"
    assert a.class == RPC, "fromXML didn't return RPC object"
    assert a == c, "XML -> RPC, fromXML didn't return equal RPC object"
  end

  def test_rpc_response_toobj
    respxml = "<?xml version=\"1.0\"?>\n<methodResponse><params><param><value><array><data><value><int>1</int></value><value><int>2</int></value><value><string>3</string></value></data></array></value></param></params></methodResponse>\n"
    assert [[1,2,"3"]] == @p.fromXML(respxml), "Failed converting XMLRPC response to obj"
  end

  def setup
    @p = LibXMLParser.new
  end
end

class LIBXMLSpecTest < Test::Unit::TestCase
  def setup
    @p = LibXMLParser.new
  end

  def test_request
    req = "<?xml version=\"1.0\"?>\n<methodCall><methodName>examples.getStateName</methodName><params><param><value><int>41</int></value></param></params></methodCall>\n"
    rpc = RPC.new("examples.getStateName", 41)
    assert @p.fromXML(req) == rpc
    assert @p.toXML(@p.fromXML(req)) == req
  end

  def test_values
    structx = "<struct><member><name>lowerBound</name><value><i4>18</i4></value></member><member><name>upperBound</name><value><i4>139</i4></value></member></struct>"
    structr = {"lowerBound" => 18, "upperBound" => 139}
    assert @p.recFromDOM(xml2node(structx)) == structr
    
    arrayx = "<?xml version=\"1.0\"?>\n<array><data><value><i4>12</i4></value><value><string>Egypt</string></value><value><boolean>0</boolean></value><value><i4>-31</i4></value></data></array>\n"
    arrayr = [12,"Egypt",false,-31]
    assert @p.recFromDOM(xml2node(arrayx)) == arrayr
  end

  def test_fault
    respx = "<?xml version=\"1.0\"?>\n<methodResponse><fault><value><struct><member><name>faultCode</name><value><int>4</int></value></member><member><name>faultString</name><value><string>Too many parameters.</string></value></member></struct></value></fault></methodResponse>\n"
    respr = RPCFault.new(4, "Too many parameters.")
    assert @p.fromXML(respx).class == RPCFault, "fromXML doesn't return RPCFault when passed sample from spec"
    assert @p.fromXML(respx) == respr, "fromXML doesn't return correct RPCFault when passed sample from spec"
  end
end
