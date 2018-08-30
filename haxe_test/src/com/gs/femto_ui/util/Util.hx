package com.gs.femto_ui.util;

import flash.Vector;

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
//.............................................................................
	public static inline function imin(x: Int, y: Int): Int
	{
		return (x < y) ? x : y;
	}
//.............................................................................
	public static inline function imax(x: Int, y: Int): Int
	{
		return (x > y) ? x : y;
	}
//.............................................................................
	public static inline function iabs(x: Int): Int
	{
		return (x ^ (x >> 31)) - (x >> 31);
	}
//.............................................................................
//.............................................................................
//.............................................................................
	public static inline function fmin(x: Float, y: Float): Float
	{
		return (x < y) ? x : y;
	}
//.............................................................................
	public static inline function fmax(x: Float, y: Float): Float
	{
		return (x > y) ? x : y;
	}
//.............................................................................
	public static inline function fabs(x: Float): Float
	{
		return (x < 0) ? -x: x;
	}
//.............................................................................
	public static inline function toHex(n: Int, ?digits : Int): String
	{
		var s : String;
		#if flash
			var x : UInt = n;
			s = untyped x.toString(16);
			s = s.toUpperCase();
		#else
			s = "";
			var hexChars = "0123456789ABCDEF";
			do
			{
				s = hexChars.charAt(n & 15) + s;
				n >>>= 4;
			} while ( n > 0 );
		#end
		if ( digits != null )
			while ( s.length < digits )
				s = "0" + s;
		return s;
	}
//.............................................................................
	public static inline function ftoPrecision(f: Float, precision: Int): String
	{
		#if (flash || js)
			return untyped f.toPrecision(precision);
		#else
			return Std.string(Math.round( f * Math.pow(10, precision) ) / Math.pow(10, precision));
		#end
	}
//.............................................................................
	public static #if (flash || js) inline #end function ftoFixed(v: Float, digits: Int): String
	{
		#if (flash || js)
			return untyped v.toFixed(digits);
		#else
			#if debug
			if (digits < 0 || digits > 20)
				throw 'toFixed have a range of 0 to 20. Specified value is not within expected range.';
			#end
			var b = Math.pow(10, digits);
			var s = Std.string(v);
			var dotIndex = s.indexOf('.');
			if (dotIndex >= 0)
			{
				var diff = digits - (s.length - (dotIndex + 1));
				if (diff > 0)
					s = StringTools.rpad(s, "0", s.length + diff);
				else
					s = Std.string(Math.round(v * b) / b);
			}
			else
			{
				s += ".";
				s = StringTools.rpad(s, "0", s.length + digits);
			}
			return s;
		#end
	}
//.............................................................................
	public static inline function fclamp(val : Float, min : Float, max : Float) : Float
	{
		return fmax(min, fmin(max, val));
	}
//.............................................................................
	public static inline function iclamp(val : Int, min : Int, max : Int) : Int
	{
		return imax(min, imin(max, val));
	}
//.............................................................................
//.............................................................................
	public static function inflate_Vector(ppt : Vector<Float>, value : Float) : Void
	{
		//:stupid but work, lets threat bug as effect
		var len : Int = ppt.length;
		for (i in 0...len)
		{
			var d : Float = ppt[i];
			if (d > 0)
			{
				d = value;
			}
			else
			{
				d = -value;
			}
			ppt[i] += d;
		}
	}
//.............................................................................
}