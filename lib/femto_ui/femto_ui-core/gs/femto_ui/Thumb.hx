package gs.femto_ui;

@:allow(gs.femto_ui.ThumbBase)
class Thumb extends ThumbBase
{
	public var is_drag_mode(get, never) : Bool;

	public function new(owner : Scrollbar)
	{
		super(owner);
#if debug
		name = "thumb";
#end
	}
//.............................................................................
//.............................................................................
	private function get_is_drag_mode() : Bool
	{
		return (state_ & Visel.STATE_DRAG) != 0;
	}
//.............................................................................
//.............................................................................
//.............................................................................
}
