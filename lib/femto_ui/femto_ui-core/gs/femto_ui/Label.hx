package gs.femto_ui;

using gs.femto_ui.RootBase.NativeUIContainer;

@:allow(gs.femto_ui.LabelBase)
class Label extends LabelBase
{
	public var text(get, set) : String;
	public var safe_text(get, never) : String;
	public var h_align(get, set) : Align;
	public var v_align(get, set) : Align;

	private var text_ : String = null;
	private var align_ : Int = 0;

	public function new(owner : NativeUIContainer, txt : String)
	{
		super(owner);
#if debug
		name = "label";
#end
		text = txt;//:call setter
	}
//.............................................................................
//.............................................................................
	private function get_safe_text() : String
	{
		return if (text_ != null) text_ else "";
	}
//.............................................................................
	private function get_text() : String
	{
		return text_;
	}
	private function set_text(value : String) : String
	{
		if (text_ != value)
		{
			if (safe_text != if (value != null) value else "")
				invalidate_Visel(Visel.INVALIDATION_FLAG_TEXT);
			text_ = value;
		}
		return value;
	}
//.............................................................................
	private function get_h_align() : Align
	{
		return cast (align_ & 0xFF);
	}
	private function set_h_align(value : Align) : Align
	{
		if (h_align != value)
		{
			align_ = (cast value: Int) | (align_ & 0xFF00);
			invalidate_Visel(Visel.INVALIDATION_FLAG_ALIGN);
		}
		return value;
	}
//.............................................................................
//.............................................................................
	private function get_v_align() : Align
	{
		return cast ((align_ & 0xFF00) >>> 8);
	}
	private function set_v_align(value : Align) : Align
	{
		if (v_align != value)
		{
			align_ = (align_ & 0xFF) | ((cast value: Int) << 8);
			invalidate_Visel(Visel.INVALIDATION_FLAG_ALIGN);
		}
		return value;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
}

