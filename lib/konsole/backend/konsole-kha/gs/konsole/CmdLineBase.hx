package gs.konsole;

import gs.femto_ui.Edit;
import gs.femto_ui.Root;
import gs.femto_ui.util.Util;
import gs.femto_ui.kha.Event;
import kha.input.KeyCode;

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
		var cmd: CmdLine = cast this;
		var cfg: KonsoleConfig = cmd.k_.cfg_;
		if (null == cfg.password_)
		{
			tf_.restrict = "^" + cfg.toggle_char_;
			tf_.filter_key_.push(cfg.toggle_key_);
		}
		tf_.add_Listener(on_TF_Event);
	}
//.............................................................................
//.............................................................................
	private function on_TF_Event(ev: Event): Void
	{
		switch(ev.type)
		{
		case Event.KEY_DOWN:
			on_Key_Down_Edit(ev);
		case Event.KEY_UP:
			on_Key_Up_Edit(ev);
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
	inline private function stop_Event(ev: Event): Void
	{
		ev.stop_propagation = true;
	}
//.............................................................................
	private function on_Key_Down_Edit(ev : Event) : Void
	{
		//trace("cmd::key down: 0x" + Util.toHex(ev.code, 2));
		switch (ev.code)
		{
		case KeyCode.Return,
			 KeyCode.Down,
			 KeyCode.Up,
			 KeyCode.F1,
			 KeyCode.Tab:
			stop_Event(ev);
		}
	}
//.............................................................................
	private function on_Key_Up_Edit(ev : Event) : Void
	{
		//trace("cmd::key up: 0x" + Util.toHex(ev.code, 2));
		var cmd: CmdLine = cast this;
		switch (ev.code)
		{
		case KeyCode.Return:
			stop_Event(ev);
			cmd.exec();
		case KeyCode.Up:
			stop_Event(ev);
			cmd.get_History_Up();
		case KeyCode.Down:
			stop_Event(ev);
			cmd.get_History_Down();
		case KeyCode.F1:
			stop_Event(ev);
			cmd.complete();
		case KeyCode.Tab:
			stop_Event(ev);
			cmd.complete();
		}
	}
//.............................................................................
}
