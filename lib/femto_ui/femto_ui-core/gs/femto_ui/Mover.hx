package gs.femto_ui;
import gs.femto_ui.util.Util;

using gs.femto_ui.RootBase.NativeUIContainer;

@:allow(gs.femto_ui.MoverBase)
class Mover extends MoverBase
{
	private var start_x_ : Float;
	private var start_y_ : Float;

	public function new(owner : NativeUIContainer)
	{
		super(owner);
	}
//.............................................................................
	private function handle_Tap(mx: Float, my: Float): Void
	{
		start_x_ = parent.x - mx;
		start_y_ = parent.y - my;
	}
//.............................................................................
//.............................................................................
	private function handle_Move(mx: Float, my: Float): Void
	{
		var r : Root = Root.instance;
		var nx: Float = Util.fclamp(start_x_ + mx, 0, r.stage_width - r.tool_width_ * .5);
		var ny: Float = Util.fclamp(start_y_ + my, 0, r.stage_height - r.tool_height_ * .5);
		parent.x = nx;
		parent.y = ny;
	}
//.............................................................................
//.............................................................................

}

