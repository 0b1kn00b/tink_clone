package tink;

import haxe.macro.*;

#if macro
using tink.MacroApi;
using tink.macro.Types;
#end

class Clone
{
	public static macro function clone(e:Expr, ?options:Expr){
		return switch e {
			case macro ($e:$ct):
				if(options == null) options = macro null;
				macro new tink.clone.Cloner<$ct>($options).clone($e);
			case _:
				switch Context.getExpectedType() {
					case null:
						e.reject('Cannot determine expected type');
					case _.toComplex() => ct:
						if(options == null) options = macro null;
						macro @:pos(e.pos) new tink.clone.Cloner<$ct>($options).clone($e);
				}
		}
	}
}