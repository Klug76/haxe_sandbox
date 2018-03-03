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
	public static inline function ftoPrecision(f: Float, precision: Int): String
	{
		#if (flash || js)
			return untyped f.toPrecision(precision);
		#else
			return Std.string(Math.round( f * Math.pow(10, precision) ) / Math.pow(10, precision));
		#end
	}
//.............................................................................
    public static inline function fclamp(val : Float, min : Float, max : Float) : Float
    {
        return fmax(min, fmin(max, val));
    }
//.............................................................................
//.............................................................................
//.............................................................................
    public static function Offset_Path(ppt : Array<Float>, offset : Float) : Void
    //:stupid but work, lets threat bug as effect
    {

        var len : Int = ppt.length;
        for (i in 0...len)
        {
            var d : Float = ppt[i];
            if (d > 0)
            {
                d = offset;
            }
            else
            {
                d = -offset;
            }
            ppt[i] += d;
        }
    }
}