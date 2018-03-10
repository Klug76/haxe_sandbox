package com.gs.console;

import flash.errors.Error;
import haxe.Constraints.Function;
import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.system.System;
import flash.utils.ByteArray;

class Konsole extends RingBuf<LogLine>
{
    private var password_idx_ : Int = 0;
    //private var eval_ : Eval;

    private var default_view_class_ : Class<Dynamic>;
    private var default_view_ : DisplayObject;

    //public var cmd_list_ : Dynamic = { };
    //public var cmd_hint_ : Dynamic = { };
    public var cfg_ : KonsoleConfig;
    public var stage_ : Stage;

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
        //eval_ = new Eval();
        //eval_.const_context_ =
                //{
                    //Number : Float,
                    //Math : Math
                //};
        //add_Command("commands", list_All_Commands, "Show a list of all slash commands");
    }
//.............................................................................
/*
    public function add_Command(cmd : String, f : Function, hint : String = null) : Void
    {
		#if debug
        {
            if (cmd in cmd_list_)
            {
                throw new Error("command " + cmd + " already exist");
            }
        }
        Reflect.setField(cmd_list_, cmd, f);
        if (hint != null)
        {
            Reflect.setField(cmd_hint_, cmd, hint);
        }
    }
*/
    //.............................................................................
/*
    public function add_Scope(id : String, obj : Dynamic) : Void
    {
        eval_.const_context_[id] = obj;
    }
*/
    //.............................................................................
    //.............................................................................
    //.............................................................................
    //.............................................................................
    //.............................................................................
    public function add(v: Dynamic) : Void
    {
        var s: String = Std.string(v);
        trace(s);
        var it : LogLine = add_Line();
        it.html_ = null;
        it.text_ = s;
    }
//.............................................................................
//html must be in simple format surrounded by <p> tag
    public function add_Html(html : String) : Void
    {
        var s : String = StrUtil.strip_Tags(html);
        s = StrUtil.remove_Last_Lf(s);  //:remove last </p>=>\n
        trace(s);  //:will add \n
        var it : LogLine = add_Line();
        it.html_ = html;
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
	/*
    public function eval(s : String) : Void
    {
        if (s.charCodeAt(0) == '/'.code)
		{
			if (eval_Command(s.substr(1)))
			{
				return;
			}
        }
        add(eval_.parse(s));
    }
    //.............................................................................
    private function eval_Command(s : String) : Bool
    {
        var word_end : Int = s.search(new as3hx.Compat.Regex('[^\\w]', ""));
        var cmd : String;
        var argv : String;
        if (word_end > 0)
        {
            cmd = s.substring(0, word_end);
            argv = s.substr(word_end + 1);
        }
        else
        {
            cmd = s;
            argv = "";
        }
        if (Lambda.has(cmd_list_, cmd))
        {
            var f : Function = try cast(Reflect.field(cmd_list_, cmd), Function) catch(e:Dynamic) null;
            if (argv.length > 0)
            {
                f(argv);
            }
            else
            {
                f();
            }
            return true;
        }
        return false;
    }
    //.............................................................................
    //.............................................................................
    //.............................................................................
    //.............................................................................
    private function list_All_Commands() : Void
    {
        var s : String = "<p>command list:</p>";
        var v : Array<String> = new Array<String>();
        for (key in Reflect.fields(cmd_list_))
        {
            var t : String = "<p>/";
            t += key;
            if (Lambda.has(cmd_hint_, key))
            {
                t += " <font color='#0000ff'>";
                t += Reflect.field(cmd_hint_, key);
                t += "</font></p>";
            }
            v.push(t);
        }
        v.sort(0);  //:Array.ascending not defined but mentioned in help
        s += v.join("");
        add_Html(s);
    }
	*/
    //.............................................................................
    //.............................................................................
    //.............................................................................
    public function copy() : Void
    {
        var text : String = get_Text();
        if (text.length <= 0)
        {
            return;
        }  //?
        //?System.setClipboard(text);//:ios - doesn't work
        Clipboard.generalClipboard.clear();
        Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, text);
        var html : String = get_Html();
        Clipboard.generalClipboard.setData(ClipboardFormats.HTML_FORMAT, html);
        add_Html("<p><font color='#0080C0' size='-2'>Copied log to clipboard.</font></p>");
    }
    //.............................................................................
    public function set_View(viewClass : Class<Dynamic>) : Void
    {
        default_view_class_ = viewClass;
    }
    //.............................................................................
    //.............................................................................
    //.............................................................................
    public function start(stage : Stage) : Void
    {
        stage_ = stage;
        stage.addEventListener(KeyboardEvent.KEY_DOWN, on_Key_Down_Stage, false, 1);
        stage.addEventListener(KeyboardEvent.KEY_UP, on_Key_Up_Stage, false, 1);
    }
    //.............................................................................
    public function toggle_View() : Void
    {
        if (null == default_view_)
        {
            default_view_ = Type.createInstance(default_view_class_, [this]);
            return;
        }
        default_view_.visible = !default_view_.visible;
    }
    //.............................................................................
    //.............................................................................
    private function on_Key_Down_Stage(e : KeyboardEvent) : Void
    {
        trace("stage::key down: 0x" + Std.string(e.keyCode));
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
        trace("stage::key up: 0x" + Std.string(e.keyCode));
        if (null != cfg_.password_)
        {
            if (e.keyCode == cfg_.password_.charCodeAt(password_idx_))
            {
                ++password_idx_;
                if (password_idx_ == cfg_.password_.length)
                {
                    toggle_View();
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
                toggle_View();
        }
    }
}