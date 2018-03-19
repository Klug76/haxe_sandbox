package com.gs.console;

import hscript.Interp;
import hscript.Parser;

class Eval
{
	private var parser_: Parser = new Parser();
	private var interp_: Interp = new Interp();

	public function new()
	{
		register_Object("Math", Math);
#if flash
		register_Object("Number", untyped __global__["Number"]);
#end
		//TODO add reset command!?
	}
//.............................................................................
	public function register_Object(name: String, obj: Dynamic) : Void
	{
		interp_.variables.set(name, obj);
	}
//.............................................................................
	public function interpretate(s : String) : Dynamic
	{
		try
		{

			var program = parser_.parseString(s);
			var result = interp_.execute(program);
			return result;
		}
		catch (err: Dynamic)
		{
			return err;
		}
		return null;
	}
//.............................................................................
}
