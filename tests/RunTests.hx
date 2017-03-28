package;

import haxe.io.Bytes;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import tink.Clone;
using Lambda;

class RunTests extends TestCase {
	static function main() {
		var t = new TestRunner();
		t.add(new RunTests());
		if(!t.run()) {
			#if sys
			Sys.exit(500);
			#end
		}
	}
	
	function testDate() {
		var now = new Date(2016,1,1,1,1,1);
		var source:Dynamic = {date: now, other: now, extra: now};
		var r:{date:Date, ?other:Date, ?optional:Date} = Clone.clone(source);
		
		assertEquals(now.getTime(), r.date.getTime());
		assertEquals(now.getTime(), r.other.getTime());
		assertFalse(Reflect.hasField(r, "optional"));
		assertEquals(null, r.optional);
		assertFalse(Reflect.hasField(r, "extra"));
	}
	
	function testEnum() {
		var arr = [2,3,4];
		var a = EnumA(1, arr);
		var source:Dynamic = {e: a};
		var result:{e:TestEnum} = Clone.clone(source);
		
		switch result.e {
			case EnumA(int, array):
				assertEquals(1, int);
				assertFalse(arr == array);
				assertEquals(3, array.length);
				assertEquals(2, array[0]);
				assertEquals(3, array[1]);
				assertEquals(4, array[2]);
		}
		
		var result:{e:TestEnum} = Clone.clone(source, {deepCopyArray: false});
		
		switch result.e {
			case EnumA(int, array):
				assertEquals(1, int);
				assertTrue(arr == array);
		}
	}
	
	function testDynamic() {
		var source:Dynamic = {date: Date.now(), float: 1.1, string: '1', array: [1,2,3]};
		var r:{date:Dynamic, float:Dynamic, string:Dynamic, array:Dynamic} = Clone.clone(source);
		
		assertEquals(source.date, r.date);
		assertEquals(source.float, r.float);
		assertEquals(source.string, r.string);
		assertEquals(source.array, r.array);
	}
	
	function testComplex() {
		var source:Dynamic= {a:1, b:2, c:"c", d:{a:1, b:1}, e:{a:1, b:1}, f:[{a:1},{a:2}]};
		var r:{?c:String, b:Float, f:Array<{a:Int}>, ?g:Bool} = Clone.clone(source);
		
		assertFalse(Reflect.hasField(r, 'a'));
		assertEquals(source.b, r.b);
		assertEquals(source.c, r.c);
		assertFalse(Reflect.hasField(r, 'd'));
		assertFalse(Reflect.hasField(r, 'e'));
		
		assertEquals(2, r.f.length);
		assertEquals(source.f[0].a, r.f[0].a);
		assertEquals(source.f[1].a, r.f[1].a);
		
		assertFalse(Reflect.hasField(r, 'g'));
		assertEquals(null, r.g);
	}
	
	function testArray() {
		var source:Dynamic = {a:[1,2,3]};
		
		var result:{a:Array<Int>} = Clone.clone(source);
		assertFalse(result.a == source.a);
		assertEquals(3, result.a.length);
		assertEquals(1, result.a[0]);
		assertEquals(2, result.a[1]);
		assertEquals(3, result.a[2]);
		
		var result:{a:Array<Int>} = Clone.clone(source, {deepCopyArray: false});
		assertTrue(result.a == source.a);
	}
	
	function testBytes() {
		var source:Dynamic = {a:Bytes.ofString("test")};
		
		var result:{a:Bytes} = Clone.clone(source);
		assertFalse(result.a == source.a);
		assertEquals('test', result.a.toString());
		
		var result:{a:Bytes} = Clone.clone(source, {deepCopyBytes: false});
		assertTrue(result.a == source.a);
	}
	
	function testMap() {
		var source:Dynamic = {a:['key1' => 1, 'key2' => 2]};
		
		var result:{a:Map<String, Int>} = Clone.clone(source);
		assertFalse(result.a == source.a);
		assertEquals(2, result.a.count());
		assertEquals(1, result.a['key1']);
		assertEquals(2, result.a['key2']);
		
		var result:{a:Map<String, Int>} = Clone.clone(source, {deepCopyMap: false});
		assertTrue(result.a == source.a);
	}
}


enum TestEnum {
	EnumA(int:Int, array:Array<Int>);
}