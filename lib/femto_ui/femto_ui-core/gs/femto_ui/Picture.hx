package gs.femto_ui;

using gs.femto_ui.RootBase.NativeUIContainer;
using gs.femto_ui.RootBase.NativeBitmap;

@:allow(gs.femto_ui.PictureBase)
class Picture extends PictureBase
{
	public var bitmap(default, set) : NativeBitmap = null;
	public var mode(default, set) : Int = PictureMode.DEFAULT;

	public function new(owner : NativeUIContainer)
	{
		super(owner);
#if debug
		name = "picture";
#end
	}
//.............................................................................
	function set_bitmap(value: NativeBitmap): NativeBitmap
	{
		if (bitmap != value)
		{
			bitmap = value;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE | Visel.INVALIDATION_FLAG_DATA);
		}
		return value;
	}
//.............................................................................
	function set_mode(value: Int): Int
	{
		if (mode != value)
		{
			mode = value;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		}
		return value;
	}
//.............................................................................
//.............................................................................
//.............................................................................
}