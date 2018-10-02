package gs.femto_ui;

import gs.femto_ui.kha.Event;
import kha.Color;
import kha.graphics2.Graphics;
import kha.input.Mouse;

class ViewportBase extends Visel
{
	static private var layer_: Visel = null;

	public function new()
	{
		if (null == layer_)
		{
			layer_ = new Visel(Root.instance.stage_);
			layer_.hit_test_bits = ViselBase.HIT_TEST_CHILDREN;
#if debug
			layer_.name = "viewport:layer";
#end
		}
		super(layer_);
	}
//.............................................................................
	override private function init_Base() : Void
	{
		super.init_Base();
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	private function add_Listeners() : Void
	{
		//stage.addEventListener(Event.RESIZE, on_Stage_Resize);
		add_Listener(on_Event);
	}
//.............................................................................
	private function remove_Listeners() : Void
	{
		//stage.removeEventListener(Event.RESIZE, on_Stage_Resize);
		remove_Listener(on_Event);
	}
//.............................................................................
	private function on_Event(ev: Event): Void
	{
		switch(ev.type)
		{
		case Event.MOUSE_DOWN_CAPTURING:
			activate();
		case Event.MOUSE_DOWN:
			activate();
			ev.stop_propagation = true;
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
	private function on_Stage_Resize(_): Void
	{
		invalidate_Visel(Visel.INVALIDATION_FLAG_STAGE_SIZE);
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public function activate(): Void
	{
		//trace("viewport::activate");
		//:some sort of bring_To_Top()?
		layer_.bring_To_Top();
		bring_To_Top();
	}
//.............................................................................
//.............................................................................
//.............................................................................
}
