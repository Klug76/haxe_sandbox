package com.gs.con_test;

import com.gs.console.Konsole;
import com.gs.console.KonsoleConfig;
import haxe.unit.TestCase;

class TestConsole extends TestCase
{
	public function new()
	{
		super();
	}

	public function test1()
	{
		var cfg: KonsoleConfig = new KonsoleConfig();

		var k: Konsole = new Konsole(cfg);
		k.add("foo");
		k.add_Html("<p>1</p>");
		var s = k.get_Html();
		assertEquals("<p>foo</p><p>1</p>", s);
		var t = k.get_Text();
		assertEquals("foo\n1\n", t);
	}
}
