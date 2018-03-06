// js-like eval
package com.gs.console;

import flash.errors.Error;
import haxe.Constraints.Function;

class Eval
{
	public var def_ : Dynamic = Math.NaN;
	public var const_context_ : Dynamic;  //:read-only  
	private var global_context_ : Dynamic;
	private var branch_context_ : Dynamic;
	private var local_context_ : Dynamic;
	//.............................................................................
	private static var regexp_float : as3hx.Compat.Regex = new as3hx.Compat.Regex('^(?:\\d*\\.\\d+(?:[Ee][+-]?\\d{1,3})?)|^(?:\\d+\\.\\d*(?:[Ee][+-]?\\d{1,3})?)', "");
	private static var regexp_hex : as3hx.Compat.Regex = new as3hx.Compat.Regex('^0[xX][0-9a-fA-F]{1,8}', "");
	private static var regexp_int : as3hx.Compat.Regex = new as3hx.Compat.Regex('^\\d+', "");
	private static var regexp_string : as3hx.Compat.Regex = new as3hx.Compat.Regex('^".*?"', "");
	private static var regexp_var : as3hx.Compat.Regex = new as3hx.Compat.Regex('^[a-zA-Z_]\\w*', "");
	//.............................................................................
	//.............................................................................
	//.............................................................................
	public function new()
	{
	}
	//.............................................................................
	//.............................................................................
	public function parse(s : String) : Dynamic
	{
		def_ = Math.NaN;
		local_context_ = null;
		branch_context_ = null;
		global_context_ = null;
		try
		{
			return parse_Formula(s);
		}
		catch (err : Error)
		{
			return "WARNING: " + err.message;
		}
	}
	//.............................................................................
	private function parse_Formula(s : String) : Dynamic
	{
		s = trim(s);
		var result : EvalResult = parse_Bitwise(s);
		if (result.tail_.length > 0)
		{
			throw_Error(result.tail_);
		}
		return result.acc_;
	}
	//.............................................................................
	private static var regexp_space_ : as3hx.Compat.Regex = new as3hx.Compat.Regex('(".*?")|(\\s+)', "g");
	//.............................................................................
	private static function trim(s : String) : String
	{
		return regexp_space_.replace(s, "$1");
	}
	//.............................................................................
	private function get_Context_Var(key : String) : Dynamic
	{
		var v : Dynamic;
		var ctx : Dynamic = local_context_;
		if ((ctx != null) && (Lambda.has(ctx, key)))
		{
			v = Reflect.field(ctx, key);
		}
		else
		{
			ctx = branch_context_;
			if ((ctx != null) && (Lambda.has(ctx, key)))
			{
				v = Reflect.field(ctx, key);
			}
			else
			{
				ctx = global_context_;
				if ((ctx != null) && (Lambda.has(ctx, key)))
				{
					v = Reflect.field(ctx, key);
				}
				else
				{
					ctx = const_context_;  //:read-only  
					if ((ctx != null) && (Lambda.has(ctx, key)))
					{
						return Reflect.field(ctx, key);
					}
					trace("WARNING: eval - variable not found: '" + key + "'");
					return def_;
				}
			}
		}
		if (Std.is(v, String))
		{
			var s : String = Std.string(v);
			if ((s.length > 1) && (s.charAt(0) == "="))
			{
				Reflect.setField(ctx, key, def_);  //:avoid recursion  
				v = parse_Formula(s.substr(1));
				Reflect.setField(ctx, key, v);
			}
		}
		return v;
	}
	//.............................................................................
	//.............................................................................
	//.............................................................................
	private function parse_Bitwise(s : String) : EvalResult
	{
		var current : EvalResult = parse_BitShift(s);
		var sym : String = "|&^";
		while (true)
		{
			var sign : String = current.tail_.charAt(0);
			if ((sign.length == 0) || (sym.indexOf(sign) < 0))
			{
				break;
			}
			var acc : Int = current.acc_;  //:?usually, acc is hex color!?  
			current = parse_BitShift(current.tail_.substr(1));
			switch (sign)
			{
				case "|":
					acc = acc | current.acc_;
				case "&":
					acc = acc & current.acc_;
				case "^":
					acc = acc ^ current.acc_;
			}
			current.acc_ = acc;
		}
		return current;
	}
	//.............................................................................
	private function parse_BitShift(s : String) : EvalResult
	{
		var current : EvalResult = parse_PlusMinus(s);
		var sym : Array<Dynamic> = ["<<", ">>"];
		while (true)
		{
			var sign : String = current.tail_.substr(0, 2);
			if (Lambda.indexOf(sym, sign) < 0)
			{
				break;
			}
			var acc : Int = current.acc_;  //:?usually, acc is hex color!?  
			current = parse_PlusMinus(current.tail_.substr(2));
			switch (sign)
			{
				case "<<":
					acc <<= current.acc_;
				case ">>":
					acc >>>= current.acc_;  //:threat as unsigned!?  
					break;
			}
			current.acc_ = acc;
		}
		return current;
	}
	//.............................................................................
	private function parse_PlusMinus(s : String) : EvalResult
	{
		var current : EvalResult = parse_MulDiv(s);
		while (true)
		{
			var sign : String = current.tail_.charAt(0);
			if ((sign != "+") && (sign != "-"))
			{
				break;
			}
			var acc : Dynamic = current.acc_;
			current = parse_MulDiv(current.tail_.substr(1));
			if ("+" == sign)
			{
				acc += current.acc_;
			}
			else
			{
				acc -= current.acc_;
			}
			current.acc_ = acc;
		}
		return current;
	}
	//.............................................................................
	private function parse_MulDiv(s : String) : EvalResult
	{
		var current : EvalResult = parse_Unary(s);
		var sym : String = "*/%";
		while (true)
		{
			var sign : String = current.tail_.charAt(0);
			if ((sign.length == 0) || (sym.indexOf(sign) < 0))
			{
				break;
			}
			var acc : Dynamic = current.acc_;
			current = parse_Unary(current.tail_.substr(1));
			switch (sign)
			{
				case "*":
					acc *= current.acc_;
				case "/":
					acc /= current.acc_;
				case "%":
					acc %= current.acc_;
			}
			current.acc_ = acc;
		}
		return current;
	}
	//.............................................................................
	private function parse_Unary(s : String) : EvalResult
	{
		var ch : String = s.charAt(0);
		var current : EvalResult;
		switch (ch)
		{
			case "-":
				current = parse_Func(s.substr(1));
				current.acc_ = -current.acc_;
				return current;
			case "~":
				current = parse_Func(s.substr(1));
				current.acc_ = ~current.acc_;
				return current;
		}
		return parse_Func(s);
	}
	//.............................................................................
	private function parse_Func(s : String) : EvalResult
	{
		var current : EvalResult = parse_Var(s);
		var acc : Dynamic;
		while (true)
		{
			var sign : String = current.tail_.charAt(0);
			if ("(" == sign)
			
			//:function call{
				
				var f : Function = try cast(current.acc_, Function) catch(e:Dynamic) null;
				if (null == f)
				{
					throw_Error(s);
					return null;
				}
				var argv : Array<Dynamic> = null;
				var tail : String = current.tail_.substr(1);
				if (tail.charAt(0) != ")")
				{
					argv = [];
					current = parse_Brackets(tail, ")", argv);
				}
				//:no args - just ()
				else
				{
					
					current.tail_ = tail.substr(1);
				}
				current.acc_ = Reflect.callMethod(null, f, argv);
				continue;
			}
			if ("[" == sign)
			
			//:array index{
				
				acc = current.acc_;
				current = parse_Brackets(current.tail_.substr(1), "]");
				current.acc_ = Reflect.field(acc, Std.string(current.acc_));
				continue;
			}
			if (sign != ".")
			{
				break;
			}
			acc = current.acc_;
			current = parse_Field(current.tail_.substr(1));
			//?test? (Object(acc).hasOwnProperty)
			current.acc_ = Reflect.field(acc, Std.string(current.acc_));
		}
		return current;
	}
	//.............................................................................
	private function parse_Field(s : String) : EvalResult
	{
		var arr : Array<Dynamic>;
		var subs : String;
		arr = s.match(regexp_var);
		if (arr != null)
		{
			subs = arr[0];
			s = s.substr(subs.length);
			return new EvalResult(subs, s);
		}
		return parse_Literal(s);
	}
	//.............................................................................
	private function parse_Var(s : String) : EvalResult
	{
		var arr : Array<Dynamic>;
		var subs : String;
		var sign : String = s.charAt(0);
		if ("(" == sign)
		{
			return parse_Brackets(s.substr(1), ")");
		}
		if ("[" == sign)
		
		//:[array]{
			
			arr = [];
			var current : EvalResult = parse_Brackets(s.substr(1), "]", arr);
			current.acc_ = arr;
			return current;
		}
		arr = s.match(regexp_var);
		if (arr != null)
		{
			subs = arr[0];
			var r : Dynamic = get_Context_Var(subs);
			return new EvalResult(r, s.substr(subs.length));
		}
		return parse_Literal(s);
	}
	//.............................................................................
	private function parse_Literal(s : String) : EvalResult
	{
		var arr : Array<Dynamic>;
		var subs : String;
		arr = s.match(regexp_float);
		if (arr != null)
		{
			subs = arr[0];
			var f : Float = as3hx.Compat.parseFloat(subs);
			return new EvalResult(f, s.substr(subs.length));
		}
		arr = s.match(regexp_hex);
		if (arr != null)
		{
			subs = arr[0];
			var u : Int = as3hx.Compat.parseInt(subs, 16);
			return new EvalResult(u, s.substr(subs.length));
		}
		arr = s.match(regexp_int);
		if (arr != null)
		{
			subs = arr[0];
			var i : Int = as3hx.Compat.parseInt(subs, 10);
			return new EvalResult(i, s.substr(subs.length));
		}
		arr = s.match(regexp_string);
		if (arr != null)
		{
			subs = arr[0];
			return new EvalResult(subs.substr(1, subs.length - 2), s.substr(subs.length));
		}
		throw_Error(s);
		return null;
	}
	//.............................................................................
	//.............................................................................
	private function parse_Brackets(s : String, endChar : String, arr : Array<Dynamic> = null) : EvalResult
	{
		var current : EvalResult;
		while (true)
		{
			current = parse_Bitwise(s);
			var char : String = current.tail_.charAt(0);
			if (arr != null)
			{
				arr.push(current.acc_);
				if ("," == char)
				{
					s = current.tail_.substr(1);
					continue;
				}
			}
			if (char != endChar)
			{
				throw_Error(current.tail_);
			}
			current.tail_ = current.tail_.substr(1);
			break;
		}
		return current;
	}
	//.............................................................................
	//.............................................................................
	//.............................................................................
	//.............................................................................
	//.............................................................................
	//.............................................................................
	private static function throw_Error(s : String) : Void
	{
		throw new Error("unable to parse \"" + s + "\"");
	}
}
//.............................................................................
//.............................................................................

//.............................................................................
class EvalResult
{
	public var acc_ : Dynamic;  //:sic  
	public var tail_ : String;
	
	public function new(acc : Dynamic, tail : String)
	{
		acc_ = acc;
		tail_ = tail;
	}
}
