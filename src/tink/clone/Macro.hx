package tink.clone;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import tink.typecrawler.Crawler;
import tink.typecrawler.FieldInfo;
import tink.typecrawler.Generator;

using haxe.macro.Tools;
using tink.MacroApi;
using tink.CoreApi;

class Macro {
	static var counter = 0;
	
	static function getType(name)
		return 
			switch Context.getLocalType() {
				case TInst(_.toString() == name => true, [v]): v;
				case v: throw 'assert ' + v;
			}
	
	public static function buildCloner():Type {
		var t = getType('tink.clone.Cloner');
		var name = 'Cloner${counter++}';
		var ct = t.toComplex();
		var pos = Context.currentPos();
		
		var cl = macro class $name extends tink.clone.Cloner.BasicCloner {
			
		}
		
		function add(t:TypeDefinition)
			cl.fields = cl.fields.concat(t.fields);
		
		var ret = Crawler.crawl(t, pos, GenCloner);
		cl.fields = cl.fields.concat(ret.fields);
		
		add(macro class {
			public function clone(value) @:pos(ret.expr.pos) {
				return ${ret.expr};
			}
		});
		
		Context.defineType(cl);
		return Context.getType(name);
	}
}

class GenCloner {
	
	static public function wrap(placeholder:Expr, ct:ComplexType)
		return placeholder.func(['value'.toArg(ct)]);
		
	static public function nullable(e)
		return macro if(value != null) $e else null;
		
	static public function string()
		return macro value;
		
	static public function int()
		return macro value;
		
	static public function float()
		return macro value;
		
	static public function bool()
		return macro value;
		
	static public function date()
		return macro value;
		
	static public function bytes()
		return macro if(!deepCopyBytes) value else {
			var bytes = haxe.io.Bytes.alloc(value.length);
			bytes.blit(0, value, 0, value.length);
			bytes;
		}
		
	static public function map(k, v)
		return macro if(!deepCopyMap) value else {
			var src = value;
			var dst = new Map();
			for(key in src.keys()) {
				var value = src.get(key);
				dst.set(key, $v);
			}
			dst;
		}
		
	static public function anon(fields:Array<FieldInfo>, ct)
		return macro {
			var __ret:Dynamic = {};
			$b{[for(f in fields) {
				var name = f.name;
				// var assert = f.optional ? macro null : macro if(!Reflect.hasField(value, $v{name})) throw $v{'Field `${f.name}` should not be null'};
				var e = macro {
					var value = value.$name;
					__ret.$name = ${f.expr};
				}
				f.optional ? macro if(Reflect.hasField(value, $v{name})) $e : e;
			}]}
			__ret;
		}
		
	static public function array(e:Expr)
		return macro if(!deepCopyArray) value else {
			[for(value in value) $e];
		}
		
	static public function enm(constructors:Array<EnumConstructor>, type, _, _) {
		var cases = [];
		for(ctor in constructors) {
			var args = ctor.inlined ? [macro value] : [for(f in ctor.fields) macro $i{f.name}];
			cases.push({
				values: [macro @:pos(ctor.ctor.pos) $i{ctor.ctor.name}($a{args})],
				expr: {
					var args = [for(f in ctor.fields) {
						var name = f.name;
						macro {
							var value = ${ctor.inlined ? macro value.$name : macro $i{f.name}};
							${f.expr};
						}
					}];
					var qualifiedName = switch type {
						case TPath({pack: pack, name: name, sub: sub}):
							(pack.length == 0 ? '' : pack.join('.')) + '$name.' + (sub == null ? '' : '$sub.') + '${ctor.ctor.name}';
						default:
							throw "assert";
					}
					macro $p{qualifiedName.split('.')}($a{args});
				}
			});
		}
		return macro if(!deepCopyEnum) value else ${ESwitch(macro value, cases, null).at()};
	}
		
	static public function dyn(_, _)
		return macro value;
		
	static public function dynAccess(_)
		return macro value;
		
	static public function reject(t:Type)
		return 'Cannot handle ${t.toString()}';
		
	static public function rescue(t:Type, _, _)
		return switch t {
			case TDynamic(t) if (t == null):
				Some(dyn(null, null));
			default: 
				None;
		}
	
	static public function shouldIncludeField(c:ClassField, owner:Option<ClassType>):Bool
		return Helper.shouldIncludeField(c, owner);

	static public function drive(type:Type, pos:Position, gen:Type->Position->Expr):Expr
		return gen(type, pos);
}