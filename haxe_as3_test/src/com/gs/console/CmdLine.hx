package com.gs.console;

import com.gs.femto_ui.Edit;
import com.gs.femto_ui.Root;
import com.gs.femto_ui.util.RingBuf;
import flash.display.DisplayObjectContainer;
import flash.events.KeyboardEvent;
import flash.text.TextFormat;
import flash.ui.Keyboard;

class CmdLine extends Edit
{
	private var k_ : Konsole;
	private var history_ : RingBuf<String>;
	private var cur_idx_ : Int = -1;
	private var stash_ : String = null;
	private static inline var history_size_: Int = 64;
	//private static inline var history_size_ : Int = 4;

	public function new(owner : DisplayObjectContainer, k : Konsole)
	{
		k_ = k;
		super(owner, "");
		init_Ex_Ex();
	}
//.............................................................................
	private function init_Ex_Ex() : Void
	{
		history_ = new RingBuf<String>(history_size_);
		history_.push("/commands");
		addEventListener(KeyboardEvent.KEY_DOWN, on_Key_Down_Edit, false, 1);
		addEventListener(KeyboardEvent.KEY_UP, on_Key_Up_Edit, false, 1);
	}
//.............................................................................
	override public function get_Default_Text_Format() : TextFormat
	{
		var r: Root = Root.instance;
		return new TextFormat(k_.cfg_.cmd_font_, Std.int(r.input_text_size_), k_.cfg_.cmd_text_color_);
	}
//.............................................................................
//.............................................................................
	private function on_Key_Down_Edit(e : KeyboardEvent) : Void
	{
		//trace("cmd::key down: 0x" + e.keyCode.toString(16));
		var key = e.keyCode;
		/*
		switch (key)
		{
			case 0xc0:
				if (null == k_.cfg_.password_)
				{
					e.preventDefault();
				}
			case Keyboard.ENTER:
				e.preventDefault();
			case Keyboard.UP:
				e.preventDefault();
		}
		*/
		if (0xc0 == key)
		{
			if (null == k_.cfg_.password_)
			{
				e.preventDefault();
			}
		}
		else if ((Keyboard.ENTER == key) || (Keyboard.DOWN == key) || (Keyboard.UP == key))
		{
			e.preventDefault();
		}
	}
//.............................................................................
	private function on_Key_Up_Edit(e : KeyboardEvent) : Void
	{
		//trace("cmd::key up: 0x" + e.keyCode.toString(16));
		var key = e.keyCode;
		/*
		switch (key)
		{
			case 0xc0:
				if (null == k_.cfg_.password_)
				{
					e.preventDefault();
				}
			case Keyboard.ENTER:
				e.preventDefault();
				exec();
			//case Keyboard.TAB: conflict with tab focus
			//e.preventDefault();
			//complete();
			//break;
			case Keyboard.UP:
				get_History_Up();
				e.preventDefault();
			case Keyboard.DOWN:
				get_History_Down();
				e.preventDefault();
		}
		*/
		if (0xc0 == key)
		{
			if (null == k_.cfg_.password_)
			{
				e.preventDefault();
			}
		}
		else if (Keyboard.ENTER == key)
		{
			e.preventDefault();
			exec();
		}
		else if (Keyboard.DOWN == key)
		{
			e.preventDefault();
			get_History_Down();
		}
		else if (Keyboard.UP == key)
		{
			e.preventDefault();
			get_History_Up();
		}
	}
//.............................................................................
	private function complete() : Void
	{
		tf_.text = "foo";
	}
//.............................................................................
	private function exec() : Void
	{
		var s : String = tf_.text;
		if (s.length <= 0)
		{
			return;
		}
		//trace("eval: '" + s + "'");
		add_To_History(s);
		cur_idx_ = -1;
		stash_ = null;
		tf_.text = "";
		k_.eval(s);
	}
//.............................................................................
	private function add_To_History(s : String) : Void
	{
		if (s.length <= 0)
		{
			return;
		}
		if (!history_.is_Empty() && (history_.back == s))
		{
			trace("already in history: " + s);
			return;
		}
		trace("history.push: " + s);
		history_.push(s);
	}
	//.............................................................................
	//.............................................................................
	private function get_History_Up() : Void
	{
		var len : Int = history_.length;
		if (len <= 0)
		{
			return;
		}
		if (cur_idx_ >= len)
		{
			return;
		}
		var t : String = tf_.text;
		if ((null == stash_) || (history_.index_Of(t) < 0))
		{
			stash_ = t;
		}
		if (cur_idx_ < 0)
		{
			cur_idx_ = 0;
		}
		else
		{
			++cur_idx_;
		}
		if (cur_idx_ < len)
		{
			tf_.text = history_.item(history_.head + len - cur_idx_ - 1);
			set_Caret_To_End();
			return;
		}
		tf_.text = "";
	}
//.............................................................................
	private function get_History_Down() : Void
	{
		var len : Int = history_.length;
		if (len <= 0)
		{
			return;
		}
		if (cur_idx_ < 0)
		{
			return;
		}
		--cur_idx_;
		if (cur_idx_ >= 0)
		{
			if (cur_idx_ >= len)
			{
				cur_idx_ = len - 1;
			}
			tf_.text = history_.item(history_.head + len - cur_idx_ - 1);
			set_Caret_To_End();
			return;
		}
		if (stash_ != null)
		{
			tf_.text = stash_;
			stash_ = null;
			set_Caret_To_End();
		}
		else
		{
			tf_.text = "";
		}
	}
//.............................................................................
	private function set_Caret_To_End() : Void
	{
		var len : Int = tf_.length;
		tf_.setSelection(len, len);
	}
}
