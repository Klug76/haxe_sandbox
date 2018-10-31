package gs.konsole;

import gs.femto_ui.Edit;
import gs.femto_ui.Root;
import gs.femto_ui.util.RingBuf;
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

	public function new(owner : DisplayObjectContainer, k : Konsole)
	{
		k_ = k;
		super(owner, null);
		init_Ex_Ex();
	}
//.............................................................................
	private function init_Ex_Ex() : Void
	{
		history_ = new RingBuf<String>(k_.cfg_.cmd_history_size_);
		history_.push("/commands");

		dummy_color = k_.cfg_.cmd_bg_color_;
	}
//.............................................................................
	override private function alloc_TextField(): Void
	{
		super.alloc_TextField();
		tf_.addEventListener(KeyboardEvent.KEY_DOWN, on_Key_Down_Edit, false, 1);
		tf_.addEventListener(KeyboardEvent.KEY_UP, on_Key_Up_Edit, false, 1);
		if (null == k_.cfg_.password_)
			tf_.restrict = "^`";
	}
//.............................................................................
	override public function get_Default_Text_Format() : TextFormat
	{
		var r: Root = Root.instance;
		return new TextFormat(k_.cfg_.cmd_font_, Std.int(r.input_text_size_), k_.cfg_.cmd_text_color_);
	}
//.............................................................................
	//override private function get_Edit_Option(opt: Int): Bool
	//{
		//switch(opt)
		//{
		//case Edit.TAB_ENABLED:
			//return false;
		//}
		//return true;
	//}
//.............................................................................
	private function stop_Event(ev: KeyboardEvent): Void
	{
		//trace("cmd::key " + ev.type + ": 0x" + Util.toHex(ev.keyCode));
		ev.preventDefault();
		ev.stopImmediatePropagation();
	}
//.............................................................................
	private function on_Key_Down_Edit(ev : KeyboardEvent) : Void
	{
		//trace("cmd::key down: 0x" + ev.keyCode.toString(16));
		switch (ev.keyCode)
		{
		case Keyboard.ENTER,
			 Keyboard.DOWN,
			 Keyboard.UP,
			 Keyboard.F1:
			stop_Event(ev);
		default:
			if (9 == ev.charCode)
			{
				if (!ev.ctrlKey && !ev.shiftKey && !ev.altKey)
				{
					//trace("*** TAB down");
					stop_Event(ev);
#if flash			//:!openfl
					tf_.tabIndex = 0;//:ugly hack hack hack hack hack!
#end
				}
			}
		}
	}
//.............................................................................
	private function on_Key_Up_Edit(ev : KeyboardEvent) : Void
	{
		//trace("cmd::key up: 0x" + ev.keyCode.toString(16));
		switch (ev.keyCode)
		{
		case Keyboard.ENTER:
			stop_Event(ev);
			exec();
		case Keyboard.UP:
			stop_Event(ev);
			get_History_Up();
		case Keyboard.DOWN:
			stop_Event(ev);
			get_History_Down();
		//case Keyboard.TAB://:review: conflict with tab focus!??
		case Keyboard.F1:
			stop_Event(ev);
			complete();
		default:
			if (9 == ev.charCode)
			{
				if (!ev.ctrlKey && !ev.shiftKey && !ev.altKey)
				{
					//trace("*** TAB up");
					stop_Event(ev);
					complete();
				}
			}
		}
	}
//.............................................................................
	private function complete() : Void
	{
		var s : String = get_Base_Text();
		if (s.length < 2)
		{
			return;
		}
		var t = k_.try_Complete_Command(s);
		if (t != s)
		{
			set_Base_Text(t);
			set_Caret_To_End();
		}
	}
//.............................................................................
	private function exec() : Void
	{
		var s : String = get_Base_Text();
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
			//trace("already in history: " + s);
			return;
		}
		//trace("history.push: " + s);
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
		var t : String = get_Base_Text();
		if ((null == stash_) || !history_.have(t))
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
			set_Base_Text(history_.item(history_.head + len - cur_idx_ - 1));
			set_Caret_To_End();
			return;
		}
		set_Base_Text("");
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
			set_Base_Text(history_.item(history_.head + len - cur_idx_ - 1));
			set_Caret_To_End();
			return;
		}
		if (stash_ != null)
		{
			set_Base_Text(stash_);
			stash_ = null;
			set_Caret_To_End();
		}
		else
		{
			set_Base_Text("");
		}
	}
//.............................................................................
	private function set_Caret_To_End() : Void
	{
		var len : Int = tf_.length;
		tf_.setSelection(len, len);
	}
}
