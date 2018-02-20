package com.gs.console;

class Util
{

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
}