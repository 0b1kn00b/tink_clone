package tink.clone;

@:genericBuild(tink.clone.Macro.buildCloner())
class Cloner<T> {}

class BasicCloner {
	var deepCopyArray:Bool = true;
	var deepCopyMap:Bool = true;
	var deepCopyBytes:Bool = true;
	var deepCopyEnum:Bool = true;
	
	public function new(?options:ClonerOptions) {
		if(options != null) {
			if(options.deepCopyArray == false) deepCopyArray = false;
			if(options.deepCopyMap == false) deepCopyMap = false;
			if(options.deepCopyBytes == false) deepCopyBytes = false;
			if(options.deepCopyEnum == false) deepCopyEnum = false;
		}
	}
}

typedef ClonerOptions = {
	?deepCopyArray:Bool,
	?deepCopyMap:Bool,
	?deepCopyBytes:Bool,
	?deepCopyEnum:Bool,
}