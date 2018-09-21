package gs.femto_ui.util;

class DumpDefines
{
	static macro function getDefines() : haxe.macro.Expr
	{
		var defines : Map<String, String> = haxe.macro.Context.getDefines();
		var arr : Array<haxe.macro.Expr> = [];
		for (key in defines.keys())
		{
			arr.push(macro $v{key} => $v{Std.string(defines.get(key))});
		}
		//arr.sort();
		return macro $a{arr};
	}

	public static function dump()
	{
		trace(getDefines());
	}

}