package com.gs.femto_ui;

import flash.Vector;
import flash.display.Stage;
import flash.events.Event;

class EnterFrameSignal extends Signal
{
	private var stage_ : Stage;

	public function new(stage : Stage)
	{
		stage_ = stage;
		super();
	}

	override private function on_Start() : Void
	{
		//trace("stage_.addEventListener(Event.ENTER_FRAME, on_Enter_Frame);");
		stage_.addEventListener(Event.ENTER_FRAME, on_Enter_Frame);
	}

	override private function on_Stop() : Void
	{
		//trace("stage_.removeEventListener(Event.ENTER_FRAME, on_Enter_Frame);");
		stage_.removeEventListener(Event.ENTER_FRAME, on_Enter_Frame);
	}

	private function on_Enter_Frame(e : Event) : Void
	{
		fire();
	}

}

