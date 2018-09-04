package com.gs.con_test;

import com.gs.console.Eval;
import haxe.unit.TestCase;

class TestEval extends TestCase
{

	public function new()
	{
		super();
	}


	public function foo(): String
	{
		return "1100101";
	}

	public function test1()
	{
		var eval: Eval = new Eval();
		eval.register_Object("Std", Std);
		eval.register_Object("Math", Math);
		eval.register_Object("Self", this);
		var res = eval.interpretate("2+3");
		assertEquals(5, res);
		var r2 = eval.interpretate("Std.parseInt(Self.foo())");
		assertEquals(1100101, r2);
	}

}
