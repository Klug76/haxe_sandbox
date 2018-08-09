package com.gs.console;

import com.gs.femto_ui.Root;
import com.gs.femto_ui.Signal;
import com.gs.femto_ui.util.RingBuf;
import flash.Lib;
import flash.Vector;
import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.KeyboardEvent;

class Konsole extends RingBuf<LogLine>
{
	private var password_idx_ : Int = 0;
	private var eval_ : Eval = null;

	private var default_view_class_ : Class<Dynamic>;
	private var default_view_ : DisplayObject = null;

	public var map_cmd_ : Map<String, Command> = new Map<String, Command>();
	public var vec_obj_ : Vector<EvalObject> = new Vector<EvalObject>();
	public var cfg_ : KonsoleConfig;

	public var signal_show_: Signal = new Signal();

	public static inline var APPEND : Int = 1;
	public static inline var REPLACE : Int = 2;

	private static inline var MAX_LEN : Int = 32;
	//static private const MAX_LEN: int = 3;

	public function new(cfg : KonsoleConfig)
	{
		cfg_ = cfg;
		super(cfg.max_lines_);
		init_Ex();
	}
//.............................................................................
	private function init_Ex() : Void
	{
		data_[0] = new LogLine();//:prealloc

		register_Object("Math", Math);
#if flash
		register_Object("Number", untyped __global__["Number"]);
#end

		register_Command("commands", list_All_Commands, "Show a list of all slash commands");
		register_Command("objects", list_All_Objects, "Show a list of all eval objects");
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
	public function start() : Void
	{
		var stage: Stage = Root.instance.stage_;
		stage.addEventListener(KeyboardEvent.KEY_DOWN, on_Key_Down_Stage, false, 1);
		stage.addEventListener(KeyboardEvent.KEY_UP, on_Key_Up_Stage, false, 1);
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public function add(v: Dynamic) : Void
	{
		var s: String = StrUtil.dump_Dynamic(v);
		if (null == s)
			s = "";
		Lib.trace(s);
		var it : LogLine = add_Line();
		it.html_ = null;
		it.text_ = s;
	}
//.............................................................................
//.............................................................................
//html must be in simple format surrounded by <p> tag
	public function add_Html(html : String) : Void
	{
		if (!validate_Html(html))
		{
			add("WARNING: unsupported or bad html:");
			add(html);
			return;
		}
		var s : String = StrUtil.strip_Tags(html);
		s = StrUtil.remove_Last_Lf(s);  //:remove last </p>=>\n
		Lib.trace(s);//:will add \n
		var it : LogLine = add_Line();
		it.html_ = html;
	}
//.............................................................................
	private function validate_Html(s : String) : Bool
	{//:perform very simple validation
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
		add(s + "=" + get_Eval().interpretate(s));
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
		var v : Vector<String> = new Vector<String>();
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
		add_Html(s);
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
		var fnt: String = " <font color='#" + cfg_.con_hint_color_ + "'>";
		var s : String = "<p>object list:</p>";
		var v : Vector<String> = new Vector<String>();
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
		add_Html(s);
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
		//?System.setClipboard(text);//:ios - doesn't work
		Clipboard.generalClipboard.clear();
		Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, text);
//#if flash
		////TODO if desktop mode!?
		//var html : String = get_Html();
		//Clipboard.generalClipboard.setData(ClipboardFormats.HTML_FORMAT, html);
//#end
		add_Html("<p><font color='#0080C0' size='-2'>Copied log to clipboard.</font></p>");
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public function set_View(viewClass : Class<Dynamic>) : Void
	{
		default_view_class_ = viewClass;
	}
//.............................................................................
//.............................................................................
	public var visible (get, set) : Bool;
	public function get_visible(): Bool
	{
		if (default_view_ != null)
			return default_view_.visible;
		return false;
	}
	public function set_visible(value: Bool): Bool
	{
		if (value)
		{
			if (null == default_view_)
			{
				default_view_ = Type.createInstance(default_view_class_, [this]);
				signal_show_.fire();
				return value;
			}
			default_view_.visible = true;
			signal_show_.fire();
		}
		else
		{
			if (default_view_ != null)
				default_view_.visible = false;
		}
		return value;
	}
//.............................................................................
//.............................................................................
	private function on_Key_Down_Stage(e : KeyboardEvent) : Void
	{
		//trace("stage::key down: 0x" + Std.string(e.keyCode));
		if (null != cfg_.password_)
		{
			return;
		}
		switch (e.keyCode)
		{
			case 0xc0:
				e.preventDefault();
		}
	}
//.............................................................................
	private function on_Key_Up_Stage(e : KeyboardEvent) : Void
	{
		//trace("stage::key up: 0x" + Std.string(e.keyCode));
		if (null != cfg_.password_)
		{
			if (e.charCode == cfg_.password_.charCodeAt(password_idx_))
			{
				++password_idx_;
				if (password_idx_ == cfg_.password_.length)
				{
					visible = true;//?
					password_idx_ = 0;
				}
				return;
			}
			password_idx_ = 0;
			return;
		}
		switch (e.keyCode)
		{
			case 0xc0:
				e.preventDefault();
				visible = !visible;
		}
	}
}
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