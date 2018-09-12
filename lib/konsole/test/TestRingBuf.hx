package com.gs.con_test;

import haxe.unit.TestCase;
import com.gs.femto_ui.util.RingBuf;

class TestRingBuf extends TestCase
{

	public function testFloat()
	{
		var r = new RingBuf<Float>(3);
		assertEquals(0, r.length);
		assertEquals(4, r.capacity);
		r.push(1.);
		r.push(2.);
		r.push(3.);
		assertEquals(3, r.length);
		r.push(4.);
		assertEquals(1., r.item(r.tail));
		r.push(5.);
		assertEquals(2., r.item(r.head));
		assertEquals(2., r.item(r.tail));
		assertEquals(4, r.length);
		r.clear();
		assertEquals(0, r.length);
		r.push(6.);
		assertEquals(1, r.length);
		assertEquals(6., r.item(r.head));
		//r.length = 2;
		//r.capacity = 2;
	}

	public function testInt()
	{
		var r = new RingBuf<Int>(3);
		assertEquals(0, r.length);
		assertEquals(4, r.capacity);
		r.push(1);
		r.push(2);
		r.push(3);
		assertEquals(3, r.length);
		r.push(4);
		assertEquals(1, r.item(r.tail));
		r.push(5);
		assertEquals(2, r.item(r.head));
		assertEquals(2, r.item(r.tail));
		assertEquals(4, r.length);
		r.clear();
		assertEquals(0, r.length);
		r.push(6);
		assertEquals(1, r.length);
		assertEquals(6, r.item(r.head));
	}

}