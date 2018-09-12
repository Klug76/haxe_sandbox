package com.gs.console;


#if (flash || openfl)
import flash.errors.Error;
#end
#if flash
import flash.Lib;
import flash.utils.ByteArray;
import flash.xml.XML;
#end

class StrUtil
{
	static private inline var MAX_LEN: Int = 32;

//.............................................................................
	static private var regexp_amp = ~/&/g;
	static private var regexp_lt = ~/</g;
	static private var regexp_gt = ~/>/g;
	static private var regexp_quot = ~/"/g;
	static private var regexp_apos = ~/'/g;
	static private var regexp_lspace = ~/^[ \t]+/gm;
	static private var regexp_br = ~/\n/g;
//.............................................................................
	static public function encode_Plain_Text(s: String): String
	{
		if (s.indexOf("&") >= 0)
		{
			s = regexp_amp.replace(s, "&amp;");
		}
		if (s.indexOf("<") >= 0)
		{
			s = regexp_lt.replace(s, "&lt;");
		}
		if (s.indexOf(">") >= 0)
		{
			s = regexp_gt.replace(s, "&gt;");
		}
		if (s.indexOf('"') >= 0)
		{
			s = regexp_quot.replace(s, "&quot;");
		}
		if (s.indexOf("'") >= 0)
		{
			s = regexp_apos.replace(s, "&apos;");
		}
		if (s.indexOf("\n") >= 0)
		{//:looks like a code
			s = regexp_lspace.map(s, escape_LSpace);
			s = regexp_br.replace(s, "<br>");
		}
		return s;
	}
//.............................................................................
	static private function escape_LSpace(re: EReg): String
	{
		var s: String = re.matched(0);
		var temp: Array<String> = [for (i in 0...s.length + 1) ""];
		return temp.join("&nbsp;");
	}
//.............................................................................
	static private var regexp_new_line = ~/<\/p>|<br>/g;
	static private var regexp_tag = ~/<.*?>/g;
	static private var regexp_lt_code = ~/&lt;/g;
	static private var regexp_gt_code = ~/&gt;/g;
	static private var regexp_quot_code = ~/&quot;/g;
	static private var regexp_apos_code = ~/&apos;/g;
	static private var regexp_amp_code = ~/&amp;/g;
//.............................................................................
	static public function strip_Tags(s: String): String
	{
		s = regexp_new_line.replace(s, '\n');
		s = regexp_tag.replace(s, "");
		s = regexp_lt_code.replace(s, '<');
		s = regexp_gt_code.replace(s, '>');
		s = regexp_quot_code.replace(s, '"');
		s = regexp_apos_code.replace(s, "'");
		//:must be last one:
		s = regexp_amp_code.replace(s, '&');
		return s;
	}
//.............................................................................
	static private var regexp_last_lf = ~/\n$/;
//.............................................................................
	static public function remove_Last_Lf(s: String): String
	{
		return regexp_last_lf.replace(s, "");
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	static public function nice_Dump(v : Dynamic): String
	{
#if flash
		if (untyped __is__(v, String))
		{//:usual case - no additional allocs required
			return Lib.as(v, String);
		}
		else if (untyped __is__(v, Bool))
		{
			var b: Bool = cast v;
			return b ? "true" : "false";
		}
		else if (untyped __is__(v, Int))
		{
			var n: Int = cast v;
			return untyped n.toString();
		}
		else if (untyped __is__(v, untyped __global__ ["uint"]))
		{
			var u: UInt = cast v;
			var s: String = untyped u.toString();
			s += "u == 0x";
			s += untyped u.toString(16);
			return s;
		}
		else if (untyped __is__(v, Float))
		{
			var f: Float = cast v;
			var s: String = untyped f.toString();
			return s;
		}
		else if (untyped __is__(v, Error))
		{
			var err: Error = Lib.as(v, Error);
			var s: String = err.getStackTrace();
			if (s != null)
				return s;
			return err.message;
		}
		else if (untyped __is__(v, Array))
		{
			return dump_Array(v);
		}
		else if (untyped __is__(v, ByteArray))
		{
			return dump_ByteArray(Lib.as(v, ByteArray));
		}
		else if (untyped __is__(v, XML))
		{
			return dump_XML(Lib.as(v, XML));
		}
		else
		{
			var cname: String = untyped __global__["flash.utils.getQualifiedClassName"](v);
			//trace("***** type==" + cname);
			if (cname.indexOf("__AS3__.vec::Vector.") == 0)
			{
				return dump_Vector(v, cname);
			}
		}
#else
#if openfl
		if (Std.is(v, Error))
		{
			var err: Error = cast v;
			var s: String = err.getStackTrace();
			if (s != null)
				return err.toString() + "\n" + s;
		}
		else
#end
		if (Std.is(v, Array))
		{
			return dump_Array(v);
		}
		else if (Std.is(v, Xml))
		{
			var x: Xml = cast v;
			return haxe.xml.Printer.print(x, /*pretty=*/true);
		}
		//else
		//{
			//var cname = Type.typeof(v);
			//trace("***** type==" + cname);
		//}
#end
		return Std.string(v);//:if flash - call flash.Boot.__string_rec
	}
//.............................................................................
#if flash
	static private function dump_XML(x: XML): String
	{
		var old_pri = XML.prettyPrinting;
		var old_idn = XML.prettyIndent;
		XML.prettyPrinting = true;
		XML.prettyIndent = 4;
		var s: String = x.toXMLString();
		XML.prettyPrinting = old_pri;
		XML.prettyIndent = old_idn;
		return s;
	}
#end
//.............................................................................
#if flash
	static private function dump_ByteArray(ba: ByteArray): String
	{
		return "ByteArray: position=" + ba.position + ", length=" + ba.length;
	}
#end
//.............................................................................
	static private function dump_Array(arr: Array<Dynamic>): String
	{
		var len: Int = arr.length;
		var len0: Int = len;
		if (len > MAX_LEN)
			len = MAX_LEN;
		var s: String = "[";
		for (i in 0...len)
		{
			if (i > 0)
				s += ", ";
			s += nice_Dump(arr[i]);
		}
		if (len != len0)
			s += ", ..";
		s += "], length=" + len0;
		return s;
	}
//.............................................................................
	static private function dump_Vector(v: Dynamic, cname: String): String
	{
		var len: Int = v.length;
		var len0: Int = len;
		if (len > MAX_LEN)
			len = MAX_LEN;
		var s: String = cname.substr(13) + ": [";
		for (i in 0...len)
		{
			if (i > 0)
				s += ", ";
			s += nice_Dump(v[i]);
		}
		if (len != len0)
			s += ", ..";
		s += "], length=" + len0;
		return s;
	}
//.............................................................................
//.............................................................................
//.............................................................................
}