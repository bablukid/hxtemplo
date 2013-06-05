class Test extends haxe.unit.TestCase {
	
	static var whitespaceEreg = ~/[\t\n\r]*/g;
	
	static function main() {
		var r = new haxe.unit.TestRunner();
		r.add(new Test());
		r.run();
	}
	
	function testParse() {
		var s = '<html><body onload="Hello World">Hello World</body></html>';
		weq(s, mkt(s, [""=>""]));
	}
	
	function testReplace() {
		var s = '<html><body onload="::myValue::">::myValue::</body></html>';
		weq('<html><body onload="Hello Var">Hello Var</body></html>', mkt(s, ["myValue" => "Hello Var"]));
	}
	
	function testIf() {
		var s = 'abc::if myVar == 3::def::end::ghi';
		weq('abcghi', mkt(s, ["myVar" => 2]));
		weq('abcdefghi', mkt(s, ["myVar" => 3]));
	}
	
	function testElse() {
		var s = 'abc::if myVar == 3::def::else::ghi::end::jkl';
		weq('abcghijkl', mkt(s, ["myVar" => 2]));
		weq('abcdefjkl', mkt(s, ["myVar" => 3]));		
	}
	
	function testElseIf() {
		var s = 'abc::if myVar == 3::def::elseif myVar == 2::ghi::else::jkl::end::mno';
		weq('abcjklmno', mkt(s, ["myVar" => 1]));
		weq('abcghimno', mkt(s, ["myVar" => 2]));
		weq('abcdefmno', mkt(s, ["myVar" => 3]));		
	}
	
	function testCond() {
		var s = '<node1><node2 ::cond myVar == 3::>v</node2></node1>';
		weq('<node1></node1>',mkt(s, ["myVar" => 1]));
		weq('<node1><node2>v</node2></node1>',mkt(s, ["myVar" => 3]));
	}
	
	function testForeach() {
		var s = 'abc::foreach n myIterable::value::n::::end::def';
		weq('abcdef', mkt(s, ["myIterable" => []]));
		weq('abcvalue1def', mkt(s, ["myIterable" => [1]]));
		weq('abcvalue1value2value3def', mkt(s, ["myIterable" => [1, 2, 3]]));
	}
	
	function testRepeat() {
		var s = '<node1><node2 ::repeat n myIterable::>value::n::</node2></node1>';
		weq('<node1></node1>', mkt(s, ["myIterable" => []]));
		weq('<node1><node2>value1</node2></node1>', mkt(s, ["myIterable" => [1]]));
	}
	
	function testForeachContext() {
		var s = '::foreach n myIterable::index::repeat.n.index::,number::repeat.n.number::,odd::repeat.n.odd::,even::repeat.n.even::,first::repeat.n.first::,last::repeat.n.last::::end::';
		weq("", mkt(s, ["myIterable" => []]));
		weq("index0,number1,oddfalse,eventrue,firsttrue,lasttrue", mkt(s, ["myIterable" => [1]]));
		weq("index0,number1,oddfalse,eventrue,firsttrue,lastfalseindex1,number2,oddtrue,evenfalse,firstfalse,lastfalseindex2,number3,oddfalse,eventrue,firstfalse,lasttrue", mkt(s, ["myIterable" => [1,2,3]]));
	}
	
	function testSet() {
		var s = 'before::myValue::::set myValue=1::after::myValue::';
		weq('before2after1', mkt(s, ["myValue" => 2]));
	}
	
	function mkt(s:String, map:Map<String, Dynamic>) {
		return new templo.Template(new haxe.io.StringInput(s)).execute(map);
	}
	
	function weq(expected:String, actual:String, ?p) {
		assertEquals(whitespaceEreg.replace(expected, ""), whitespaceEreg.replace(actual, ""), p);
	}
}