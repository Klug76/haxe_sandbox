package gs.femto_ui;

import gs.femto_ui.util.Util;

using gs.femto_ui.RootBase.NativeUIContainer;

@:allow(gs.femto_ui.ResizerBase)
class Resizer extends ResizerBase
{
	private var owner_: Visel;

	private var start_w_ : Float;
	private var start_h_ : Float;

	public var min_width_ : Float = 0;
	public var min_height_ : Float = 0;

	public function new(owner: Visel)
	{
		super(owner);
#if debug
		name = "resizer";
#end
		owner_ = owner;
	}
//.............................................................................
//.............................................................................
	private var tap_id(default, null): Int = 0;
	private function handle_Tap(tapId: Int, mx: Float, my: Float): Void
	{
		tap_id = tapId;
		start_w_ = owner_.width - mx;
		start_h_ = owner_.height - my;
	}
//.............................................................................
	private function handle_Move(tapId: Int, mx: Float, my: Float): Void
	{
		if (tap_id != tapId)
			return;
		var r : Root = Root.instance;
		var nw: Float = Util.fclamp(start_w_ + mx, min_width_, r.stage_width);
		var nh: Float = Util.fclamp(start_h_ + my, min_height_, r.stage_height);
		owner_.resize_Visel(nw, nh);
	}
}

