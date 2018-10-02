package gs.femto_ui;
import gs.femto_ui.util.Util;

using gs.femto_ui.RootBase.NativeUIContainer;

@:allow(gs.femto_ui.MoverBase)
class Mover extends MoverBase
{
	private var owner_: Visel;

	private var start_x_ : Float;
	private var start_y_ : Float;

	public function new(owner: Visel)
	{
		super(owner);
#if debug
		name = "mover";
#end
		owner_ = owner;
	}
//.............................................................................
	private var tap_id(default, null): Int = 0;
	private function handle_Tap(tapId: Int, mx: Float, my: Float): Void
	{
		tap_id = tapId;
		start_x_ = parent.x - mx;
		start_y_ = parent.y - my;
	}
//.............................................................................
//.............................................................................
	private function handle_Move(tapId: Int, mx: Float, my: Float): Void
	{
		if (tap_id != tapId)
			return;
		var r : Root = Root.instance;
		var nx: Float = Util.fclamp(start_x_ + mx, 0, r.stage_width - r.tool_width_ * .5);
		var ny: Float = Util.fclamp(start_y_ + my, 0, r.stage_height - r.tool_height_ * .5);
		owner_.move_Visel(nx, ny);
	}
//.............................................................................
//.............................................................................

}

