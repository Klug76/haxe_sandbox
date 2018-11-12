package gs.konsole;

import gs.femto_ui.util.RingBuf;

using gs.femto_ui.RootBase.NativeUIContainer;

@:allow(gs.konsole.CmdLineBase)
class CmdLine extends CmdLineBase
{
	private var k_ : Konsole;
	private var history_ : RingBuf<String>;
	private var cur_idx_ : Int = -1;
	private var stash_ : String = null;

	public function new(owner : NativeUIContainer, k : Konsole)
	{
		k_ = k;
		super(owner);
	}
//.............................................................................
//.............................................................................
	override private function init_Base() : Void
	{
		super.init_Base();
		history_ = new RingBuf<String>(k_.cfg_.cmd_history_size_);
		history_.push("/commands");

		dummy_color = k_.cfg_.cmd_bg_color_;
	}
//.............................................................................
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
		set_Base_Text("");
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
}
