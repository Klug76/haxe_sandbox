package gs.femto_ui;

import gs.femto_ui.util.Signal;
import flash.display.Stage;
import flash.events.Event;

class EnterFrameSignal extends Signal
{
	private var stage_ : Stage = null;

	public function new()
	{
		super();
	}

	public function init(stg: Stage) : Void
	{
		stage_ = stg;
		if ((state_ & Signal.ACTIVE) != 0)
			on_Start();
	}


	override private function on_Start() : Void
	{
		if (stage_ != null)
			stage_.addEventListener(Event.ENTER_FRAME, on_Enter_Frame);
	}

	override private function on_Stop() : Void
	{
		if (stage_ != null)
			stage_.removeEventListener(Event.ENTER_FRAME, on_Enter_Frame);
	}

	private function on_Enter_Frame(e : Event) : Void
	{
		fire();
	}

}

