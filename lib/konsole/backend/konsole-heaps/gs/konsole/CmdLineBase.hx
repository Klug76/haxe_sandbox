package gs.konsole;

import hxd.Event;
import hxd.Key;
import gs.femto_ui.Edit;
import gs.femto_ui.util.Util;

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
		tf_.onKeyDown = on_Key_Down_Edit;
		tf_.onTextInput = on_Key_Press_Edit;
		tf_.onKeyUp = on_Key_Up_Edit;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	inline private function stop_Event(ev: Event): Void
	{
		ev.cancel = true;
	}
//.............................................................................
	private function on_Key_Down_Edit(ev : Event) : Void
	{
		//trace("cmd::key down: 0x" + Util.toHex(ev.keyCode, 2));
		switch (ev.keyCode)
		{
		case Key.ENTER,
			 Key.NUMPAD_ENTER,
			 Key.DOWN,
			 Key.UP,
			 Key.F1,
			 Key.TAB:
			stop_Event(ev);
		}
	}
//.............................................................................
	private function on_Key_Press_Edit(ev : Event) : Void
	{
		//trace("cmd::key press: 0x" + Util.toHex(ev.charCode, 2));
		var cmd: CmdLine = cast this;
		var cfg: KonsoleConfig = cmd.k_.cfg_;
		if (null == cfg.password_)
		{
			if (ev.charCode == cfg.toggle_char_.charCodeAt(0))
				stop_Event(ev);
		}
	}
//.............................................................................
	private function on_Key_Up_Edit(ev : Event) : Void
	{
		//trace("cmd::key up: 0x" + Util.toHex(ev.keyCode, 2));
		var cmd: CmdLine = cast this;
		switch (ev.keyCode)
		{
		case Key.ENTER,
			 Key.NUMPAD_ENTER:
			stop_Event(ev);
			cmd.exec();
		case Key.UP:
			stop_Event(ev);
			cmd.get_History_Up();
		case Key.DOWN:
			stop_Event(ev);
			cmd.get_History_Down();
		case Key.F1:
			stop_Event(ev);
			cmd.complete();
		case Key.TAB:
			stop_Event(ev);
			cmd.complete();
		}
	}
//.............................................................................
}
