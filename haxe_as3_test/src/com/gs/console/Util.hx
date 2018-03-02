package com.gs.console;

class Util
{
	//TODO IntUtil, FloatUtil, StringUtil!?

	public static function next_Power_Of_2(size : Int) : Int
	{
		if (!(size > 0 && ((size & (size - 1)) == 0)))
		{//pow 2
			size |= (size >> 1);
			size |= (size >> 2);
			size |= (size >> 4);
			size |= (size >> 8);
			size |= (size >> 16);
			++size;
		}
		return size;
	}

	public static inline function imin(x: Int, y: Int): Int
	{
		return (x < y) ? x : y;
	}

	public static inline function imax(x: Int, y: Int): Int
	{
		return (x > y) ? x : y;
	}

	public static inline function iabs(x: Int): Int
	{
		return (x ^ (x >> 31)) - (x >> 31);
	}

	public static inline function ftoPrecision(f: Float, precision: Int): String
	{
		//TODO fix me: js
		#if flash
			return untyped f.toPrecision(precision);
		#else
			var mult: Int = precision * 10;
			return Std.string(Std.int(f * mult) / mult);
		#end
	}
}