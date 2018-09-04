package;

class DumpDefines
{
	static macro function getDefines() : haxe.macro.Expr
	{
		var defines : Map<String, String> = haxe.macro.Context.getDefines();
		// Construct map syntax so we can return it as an expression
		var map : Array<haxe.macro.Expr> = [];
		for (key in defines.keys())
		{
			map.push(macro $v{key} => $v{Std.string(defines.get(key))});
		}
		return macro $a{map};
	}

	public static function dump()
	{
		trace(getDefines());
	}

}