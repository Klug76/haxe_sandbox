package;

import com.gs.console.Util;
import flash.Lib;
import flash.Memory;
import flash.utils.ByteArray;
import haxe.ds.Vector;
import haxe.unit.TestCase;

class TestAlchemy extends TestCase
{
	private static inline var N: Int = 1024;
	private static inline var M: Int = #if debug 1000 #else 40000 #end;

	public function test1()
	{
		trace("\n");
		var begin_time: Int = Lib.getTimer();
		var bytes: ByteArray = new ByteArray();
		bytes.length = N * 4;
		Memory.select(bytes);
		for (i in 0...M)
		{
			fill_Memory(bytes);
			process_Memory(bytes);
		}
		trace("dt=" + (Lib.getTimer() - begin_time));
		dump_Memory(bytes);
		assertTrue(true);
	}

	public function test2()
	{
		var begin_time: Int = Lib.getTimer();
		var v = new Vector<Float>(N);
		for (i in 0...M)
		{
			fill_Vector(v);
			process_Vector(v);
		}
		trace("dt=" + (Lib.getTimer() - begin_time));
		dump_Vector(v);
		assertTrue(true);
	}

	function fill_Vector(v: Vector<Float>)
	{
		var len = v.length;
		for (i in 0...len - 1)
		{
			v[i] = i;
		}
	}

	function process_Vector(v: Vector<Float>)
	{
		var len = v.length;
		for (i in 0...len - 1)
		{
			v[i] = Math.sqrt(v[i]);
		}
	}

	function dump_Vector(v: Vector<Float>)
	{
		var len: Int = v.length;
		var arr: Array<String> = [];
		for (i in 0...Util.imin(6, len - 1))
		{
			var f: Float = v[i];
			arr.push(Util.ftoPrecision(f, 5));
		}
		trace(arr.join(","));
	}

	function process_Memory(bytes: ByteArray)
	{
		var len: Int = bytes.length >> 2;
		for (i in 0...len - 1)
		{//Quake Fast Inverse Square Root
			var addr: Int = i << 2;
			var f: Float = Memory.getFloat(addr);
			var n: Int = Memory.getI32(addr);
			//n = 0x5f3759df - (n >> 1);
			n = 0x5f375a86 - (n >> 1);//Lomont update
			Memory.setI32(addr, n);
			var nf = Memory.getFloat(addr);
			nf = nf * (1.5 - f * .5 * nf * nf);
			//nf = 1 / nf;//?
			nf *= f;
			Memory.setFloat(addr, nf);
		}
	}

	function fill_Memory(bytes: ByteArray)
	{
		var len: Int = bytes.length >> 2;
		for (i in 0...len - 1)
		{
			flash.Memory.setFloat(i << 2, i);
		}
	}

	function dump_Memory(bytes: ByteArray)
	{
		var len: Int = bytes.length >> 2;
		var arr: Array<String> = [];
		for (i in 0...Util.imin(6, len - 1))
		{
			var f: Float = flash.Memory.getFloat(i << 2);
			arr.push(Util.ftoPrecision(f, 5));
		}
		trace(arr.join(","));
	}

}