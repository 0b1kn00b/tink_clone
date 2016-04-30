# tink_clone [![Build Status](https://travis-ci.org/haxetink/tink_clone.svg?branch=master)](https://travis-ci.org/haxetink/tink_clone)

Compile-time type-based object cloning code generator.

## Usage

```haxe
var source:Dynamic = {a:1, b:"2"};
var result:{a:Int, b:String} = Clone.clone(source); // result is {a:1, b:"2"}
```

## Note

The type of the source is not enforced. If you need runtime type checking, consider using [tink_validation](https://github.com/haxetink/tink_validation)
