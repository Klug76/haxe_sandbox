package com.gs.con_test;

import com.gs.femto_ui.util.Util;
import haxe.unit.TestCase;

class TestNumUtils extends TestCase
{

	public function test1()
	{
		var f: Float = 1. / 3.;
		var s: String = Util.ftoPrecision(f, 3);
		assertEquals("0.333", s);
		f *= 2.;
		s = Util.ftoPrecision(f, 2);
		assertEquals("0.67", s);
	}
}