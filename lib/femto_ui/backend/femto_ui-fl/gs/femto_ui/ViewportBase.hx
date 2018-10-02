package gs.femto_ui;

import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;

class ViewportBase extends Visel
{
	static private var layer_: Sprite = null;

	public function new()
	{
		if (null == layer_)
		{
			layer_ = new Sprite();
			Root.instance.stage_.addChild(layer_);
		}
		super(layer_);
	}
//.............................................................................
//.............................................................................
	override private function destroy_Base(): Void
	{
		super.destroy_Base();
		if (stage != null)
			remove_Listeners();
	}
//.............................................................................
//.............................................................................
//.............................................................................
	private function add_Listeners() : Void
	{
		stage.addEventListener(Event.RESIZE, on_Stage_Resize);
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down_Phase0, true, 100);
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
	}
//.............................................................................
	private function remove_Listeners() : Void
	{
		stage.removeEventListener(Event.RESIZE, on_Stage_Resize);
		removeEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down_Phase0, true);
		removeEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
	}
//.............................................................................
	private function on_Mouse_Down_Phase0(ev: Event): Void
	{
		//trace("Viewport::on_Mouse_Down_Phase0, target=" + ev.target);
		activate();
	}
//.............................................................................
	private function on_Mouse_Down(ev: MouseEvent): Void
	{
		//trace("Viewport::on_Mouse_Down, target=" + ev.target);
		ev.stopPropagation();
		activate();
	}
//.............................................................................
//.............................................................................
	private function on_Stage_Resize(ev: Event): Void
	{
		//?if (StageScaleMode.NO_SCALE == stage.scaleMode)
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
