package com.gs.con_test;

import com.gs.console.StrUtil;
import haxe.unit.TestCase;

//import flash.utils.ByteArray;
//import flash.errors.Error;

class TestStrUtils extends TestCase
{
	public function test1()
	{
		var arr = [1, 3, 2];
		var s = StrUtil.nice_Print(arr);
		//trace(s);
		assertEquals("[1, 3, 2], length=3", s);
	}
/*
	public function _test2()
	{
		try
		{
			throw new Error("foo");
		}
		catch (err: Error)
		{
			var s = StrUtil.dump_Dynamic(err);
			trace("ERROR: '" + s + "'");
		}
		assertEquals(1, 1);
	}

	public function _test3()
	{
		var rs: Serializer = new Serializer();

		var ba: ByteArray = new ByteArray();
		ba.writeByte(0x66);
		ba.writeByte(0x6f);
		ba.writeByte(0x6f);

		rs.serialize(ba);//:crash with openfl 8.4.1
		trace(rs.toString());
		assertEquals(1, 1);
	}

	public function _test4()
	{//:doesn't work - with openfl 8.4.1
		var ba: ByteArray = new ByteArray();
		ba.writeByte(0x66);
		ba.writeByte(0x6f);
		ba.writeByte(0x6f);
		//$type(ba);//WTF?
		switch(Type.typeof(ba))
		{
		case TClass(c):
			switch(c)
			{
			case cast Bytes:
				trace("ByteArray");
			default:
				trace("!ByteArray");
			}
		default:
			trace("!ByteArray");
		}
		var s = StrUtil.dump_Dynamic(ba);
		trace("s = '" + s + "'");
		assertEquals("ByteArray: position=3, length=3", s);
	}
*/

	public function test5()
	{
		var s = StrUtil.encode_Plain_Text("2 > 0");
		assertEquals("2 &gt; 0", s);
	}

}