package gs.femto_ui;

import h2d.Object;
import hxd.Cursor;
import hxd.Event;
import h2d.Interactive;

class ViewportBase extends Visel
{
	static private var layer_: Object = null;

	public function new()
	{
		if (null == layer_)
		{
			layer_ = new Object();
			Root.instance.scene_.addChild(layer_);
		}
		super(layer_);
	}
//.............................................................................
	override private function init_Base() : Void
	{
		super.init_Base();

		var ni: Interactive = alloc_Interactive(Cursor.Default, false);
		ni.onPush = on_Mouse_Down;
	}
//.............................................................................
	//override public function handleEvent(ev : Event): Void
	//{
		//super.handleEvent(ev);
	//}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	private function add_Listeners() : Void
	{
		//stage.addEventListener(Event.RESIZE, on_Stage_Resize);
	}
//.............................................................................
	private function remove_Listeners() : Void
	{
		//stage.removeEventListener(Event.RESIZE, on_Stage_Resize);
	}
//.............................................................................
	private function on_Mouse_Down_Phase0(_): Void
	{
		//trace("Viewport::on_Mouse_Down_Phase0, target=" + ev.target);
		activate();
	}
//.............................................................................
	private function on_Mouse_Down(ev : Event): Void
	{
		//trace("Viewport::" + ev.kind + ": " + ev.button + ": " + ev.touchId + ": " + ev.propagate);
		ev.propagate = false;
		activate();
	}
//.............................................................................
//.............................................................................
	private function on_Stage_Resize(_): Void
	{
		//TODO fix me
		invalidate_Visel(Visel.INVALIDATION_FLAG_STAGE_SIZE);
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public function activate() : Void
	{
		//:some sort of bring_To_Top()?
		if (layer_.parent != null)
			layer_.parent.addChild(layer_);
		bring_To_Top();
	}
//.............................................................................
//.............................................................................
//.............................................................................
}
