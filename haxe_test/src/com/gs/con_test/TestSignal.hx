package com.gs.con_test;

import com.gs.console.Eval;
import com.gs.console.StrUtil;
import com.gs.femto_ui.util.Signal;
import haxe.unit.TestCase;
import com.gs.femto_ui.util.RingBuf;

class TestSignal extends TestCase
{

	public function new()
	{
		super();
	}

	var debug_state_: UInt = 0;

	public function test1()
	{
		var g: Signal = new Signal();
		g.add(on_Fire);
		g.add(on_Fire2);
		debug_state_ = 0;
		g.fire();
		assertEquals(3, debug_state_);
		debug_state_ = 0;
		g.fire();
		assertEquals(3, debug_state_);
		g.remove(on_Fire2);
		g.add(on_Fire);
		debug_state_ = 0;
		g.fire();
		assertEquals(1, debug_state_);
		g.remove(on_Fire);
		debug_state_ = 0;
		g.fire();
		assertEquals(0, debug_state_);
	}

	function on_Fire()
	{
		debug_state_ |= 1;
	}
	function on_Fire2()
	{
		debug_state_ |= 2;
	}
}
