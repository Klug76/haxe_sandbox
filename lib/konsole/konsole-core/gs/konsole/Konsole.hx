package gs.konsole;

import gs.femto_ui.util.Util;
import gs.konsole.KonsoleConfig;
import gs.femto_ui.util.RingBuf;
import gs.femto_ui.util.Signal;
import haxe.PosInfos;

import haxe.Log;

#if (flash || openfl)
import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.errors.Error;
import flash.Lib;
#end

class Konsole extends RingBuf<LogLine>
{
	private var eval_ : Eval = null;

	public var map_cmd_ : Map<String, Command> = new Map<String, Command>();
	public var vec_obj_ : Array<EvalObject> = new Array<EvalObject>();
	public var cfg_ : KonsoleConfig;

	public var signal_show_: Signal = new Signal();

	private var prev_trace_: Dynamic = null;

	public static inline var APPEND : Int = 1;
	public static inline var REPLACE : Int = 2;

	private static inline var MAX_LEN : Int = 32;
	//static private const MAX_LEN: int = 3;

	public function new(cfg : KonsoleConfig)
	{
		set_Config(cfg);
		super(cfg.max_lines_);
		init_Ex();
	}
//.............................................................................
	inline private function set_Config(cfg: KonsoleConfig) : Void
	{
		cfg_ = cfg;
		var max_lines: Int = cfg.max_lines_;
		#if debug
		{
			if (!((max_lines > 0) && ((max_lines & (max_lines - 1)) == 0)))
			{
				throw
#if (flash || openfl)
					new Error
#end
						("max_lines must be 2^N");
			}
		}
		#end
	}
//.............................................................................
	private function init_Ex() : Void
	{
		data_[0] = new LogLine();//:prealloc

		register_Object("Std", Std);
		register_Object("Math", Math);
#if flash
		register_Object("Number", untyped __global__["Number"]);
#end

		register_Command("commands", list_All_Commands, "Show a list of all slash commands");
		register_Command("objects", list_All_Objects, "Show a list of all eval objects");

		if (cfg_.redirect_trace_)
		{
			prev_trace_ = Log.trace;
			Log.trace = custom_trace;
		}
	}
//.............................................................................
	public function register_Command(cmd : String, f : Array<String>->Void, hint : String = null) : Void
	{
		#if debug
		{
			if (map_cmd_.exists(cmd))
			{
				throw "command " + cmd + " already exist";
			}
		}
		#end
		var c: Command = new Command(f, hint);
		map_cmd_.set(cmd, c);
	}
//.............................................................................
	public function register_Object(name : String, obj: Dynamic) : Void
	{
		vec_obj_.push(new EvalObject(name, obj));
		if (eval_ != null)
			eval_.register_Object(name, obj);
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	private function custom_trace(v : Dynamic, ?infos : PosInfos) : Void
	{
		prev_trace_(v, infos);
		var s: String = StrUtil.nice_Dump(v);
		if (null == s)
			s = "";
		var it: LogLine = add_Line();
		it.html_ = null;
		it.text_ = s;
	}
//.............................................................................
	private function native_trace(s: String): Void
	{
#if (flash || openfl)
			Lib.trace(s);
#else
		if (prev_trace_ != null)
		{
			prev_trace_(s);
		}
		else
		{
			Log.trace(s);//TODO fix me: how to omit line #?
		}
#end
	}
//.............................................................................
	public function log(v: Dynamic) : Void
	{
		var s: String = StrUtil.nice_Dump(v);
		if (null == s)
			s = "";
		native_trace(s);
		var it: LogLine = add_Line();
		it.html_ = null;
		it.text_ = s;
	}
//.............................................................................
//.............................................................................
//html must be in simple format surrounded by <p> tag
	public function log_Html(html: String) : Void
	{
		if (!validate_Html(html))
		{
			log("WARNING: unsupported or bad html:");
			log(html);
			return;
		}
		var s : String = StrUtil.strip_Tags(html);
		s = StrUtil.remove_Last_Lf(s);  //:remove last </p>=>\n
		native_trace(s);
		var it : LogLine = add_Line();
		it.text_ = null;
		it.html_ = html;
	}
//.............................................................................
	private function validate_Html(s : String) : Bool
	{//:TODO tag/pair validation
		var len: Int = s.length;
		if ((null == s) || (len <= 0))
			return false;
		if ((s.indexOf("<p>") != 0) && (s.lastIndexOf("</p>") != len - 4))
			return false;
		return true;
	}
//.............................................................................
//.............................................................................
//.............................................................................
	private function add_Line() : LogLine
	{
		if (length == capacity_)
		{//:full

			++head_;
		}
		var idx : Int = tail_++;
		var it : LogLine = data_[idx & and_mask_];
		if (null == it)
		{
			it =
			data_[idx & and_mask_] = new LogLine();
		}
		//it.id_ = idx;
		return it;
	}
//.............................................................................
//.............................................................................
	public function get_Text() : String
	{
		return get_Text_From(head_);
	}
//.............................................................................
	public function get_Text_From(idx : Int) : String
	{
		var result : String = "";
		while (idx < tail_)
		{
			var it : LogLine = data_[idx & and_mask_];
			result += it.get_Text();
			result += "\n";
			++idx;
		}
		return result;
	}
//.............................................................................
	public function get_Html() : String
	{
		return get_Html_From(head_);
	}
//.............................................................................
	public function get_Html_From(idx : Int) : String
	{
		var result : String = "";
		while (idx < tail_)
		{
			var it : LogLine = data_[idx & and_mask_];
			result += it.get_Html();
			++idx;
		}
		return result;
	}
//.............................................................................
	public function query_Update(last_seen_head : Int, last_seen_tail : Int) : Int
	{
		if ((last_seen_head == head_) && (last_seen_tail == tail_))
		{//:nop
			return 0;
		}
		if (head_ == tail_)
		{//:to clear
			return REPLACE;
		}
		if (head_ > last_seen_tail)
		{//:unable to close gap between last_seen_tail & new head_
			return REPLACE;
		}
		//if (head_ == last_seen_tail)
			//trace("***** " + head_);
		return APPEND;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public function eval(s : String) : Void
	{
		if (s.charCodeAt(0) == '/'.code)
		{
			if (eval_Command(s.substr(1)))
			{
				return;
			}
		}
		log(s + "=" + get_Eval().interpretate(s));
	}
//.............................................................................
	private function get_Eval() : Eval
	{
		if (null == eval_)
		{
			eval_ = new Eval();
			var count: Int = vec_obj_.length;
			for (i in 0...count)
			{
				var it: EvalObject = vec_obj_[i];
				eval_.register_Object(it.name_, it.obj_);
			}
		}
		return eval_;
	}
//.............................................................................
	public function eval_Command(s : String) : Bool
	{
		var arr: Array<String> = s.split(' ');
		var cmd : String = arr[0];
		if (map_cmd_.exists(cmd))
		{
			var it: Command = map_cmd_[cmd];
			var f: Array<String>->Void = it.func_;
			arr.shift();
			f(arr);
			return true;
		}
		return false;
	}
//.............................................................................
	public function have_Command(cmd : String) : Bool
	{
		return map_cmd_.exists(cmd);
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	private function list_All_Commands(dummy: Array<String>) : Void
	{
		var fnt_open: String = "<font color='#" + cfg_.con_hint_color_ + "'>";
		var fnt_close: String = "</font>";
		var s : String = "<p>command list:</p>";
		var v : Array<String> = new Array<String>();
		for (key in map_cmd_.keys())
		{
			var it: Command = map_cmd_[key];
			var t : String = "<p>/";
			t += key;
			if (it.hint_ != null)
			{
				t += ' ';
				t += fnt_open;
				t += it.hint_;
				t += fnt_close;
			}
			t += "</p>";
			v.push(t);
		}
		v.sort(sort_Ascending);  //:Array.ascending not defined but mentioned in help
		s += v.join("");
		log_Html(s);
	}
//.............................................................................
	function sort_Ascending(a: String, b: String): Int
	{
		if (a < b) return -1;
		if (a > b) return 1;
		return 0;
	}
//.............................................................................
//.............................................................................
	private function list_All_Objects(dummy: Array<String>) : Void
	{
		var s : String = "<p>object list:</p>";
		var v : Array<String> = new Array<String>();
		var count: Int = vec_obj_.length;
		for (i in 0...count)
		{
			var it: EvalObject = vec_obj_[i];
			var t : String = "<p>";
			t += it.name_;
			t += "</p>";
			v.push(t);
		}
		v.sort(sort_Ascending);  //:Array.ascending not defined but mentioned in help
		s += v.join("");
		log_Html(s);
	}
//.............................................................................
//.............................................................................
	public function copy() : Void
	{
		var text : String = get_Text();
		if (text.length <= 0)
		{
			return;
		}
#if (flash || openfl)
		Clipboard.generalClipboard.clear();
		Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, text);
		//:System.setClipboard(text);//:ios - doesn't work
#else
		trace("TODO fix me: Clipboard::copy");
		return;
#end
//#if flash
		////TODO if desktop mode!?
		//var html : String = get_Html();
		//Clipboard.generalClipboard.setData(ClipboardFormats.HTML_FORMAT, html);
//#end
		log_Html("<p><font color='#0080C0' size='-2'>Copied log to clipboard.</font></p>");
	}
//.............................................................................
	public function try_Complete_Command(s: String) : String
	{
		if (s.charCodeAt(0) == '/'.code)
		{
			var part: String = s.substr(1);
			var v : Array<String> = [];
			for (key in map_cmd_.keys())
			{
				if (key.indexOf(part) == 0)
					v.push(key);
			}
			var len = v.length;
			if (len > 0)
			{
				if (1 == len)
					return '/' + v[0];
				v.sort(sort_Ascending);
				var s0 = v[0];
				var s1 = v[len - 1];
				var i: Int = 0;
				var s_len = Util.imin(s0.length, s1.length);
				while (i < s_len)
				{
					if (s0.charCodeAt(i) != s1.charCodeAt(i))
						break;
					++i;
				}
				return '/' + s0.substr(0, i);
			}
		}
		return s;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	}
//.............................................................................
//.............................................................................
class Command
{
	public var func_: Array<String>->Void;
	public var hint_: String;

	public function new(f: Array<String>->Void, h: String)
	{
		func_ = f;
		hint_ = h;
	}
}
class EvalObject
{
	public var name_: String;
	public var obj_: Dynamic;

	public function new(name: String, obj: Dynamic)
	{
		name_ = name;
		obj_ = obj;
	}
}