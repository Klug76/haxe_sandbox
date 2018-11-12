package gs.konsole;

import gs.femto_ui.Edit;
import gs.femto_ui.Root;
import flash.events.KeyboardEvent;
import flash.text.TextFormat;
import flash.ui.Keyboard;

using gs.femto_ui.RootBase.NativeUIContainer;

class CmdLineBase extends Edit
{
	public function new(owner : NativeUIContainer)
	{
		super(owner, null);
	}
//.............................................................................
	override private function alloc_TextField(): Void
	{
		super.alloc_TextField();
		tf_.addEventListener(KeyboardEvent.KEY_DOWN, on_Key_Down_Edit, false, 1);
		tf_.addEventListener(KeyboardEvent.KEY_UP, on_Key_Up_Edit, false, 1);
		var cmd: CmdLine = cast this;
		if (null == cmd.k_.cfg_.password_)
			tf_.restrict = "^`";
	}
//.............................................................................
	override public function get_Default_Text_Format() : TextFormat
	{
		var r: Root = Root.instance;
		var cmd: CmdLine = cast this;
		var cfg: KonsoleConfig = cmd.k_.cfg_;
		return new TextFormat(cfg.cmd_font_, Std.int(cfg.cmd_font_size_), cfg.cmd_text_color_);
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
		var cmd: CmdLine = cast this;
		//trace("cmd::key up: 0x" + ev.keyCode.toString(16));
		switch (ev.keyCode)
		{
		case Keyboard.ENTER:
			stop_Event(ev);
			cmd.exec();
		case Keyboard.UP:
			stop_Event(ev);
			cmd.get_History_Up();
		case Keyboard.DOWN:
			stop_Event(ev);
			cmd.get_History_Down();
		case Keyboard.F1:
			stop_Event(ev);
			cmd.complete();
		//case Keyboard.TAB://:review: conflict with tab focus!??
		default:
			if (9 == ev.charCode)
			{
				if (!ev.ctrlKey && !ev.shiftKey && !ev.altKey)
				{
					//trace("*** TAB up");
					stop_Event(ev);
					cmd.complete();
				}
			}
		}
	}
//.............................................................................
}
