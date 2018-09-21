package gs.femto_ui;

using gs.femto_ui.RootBase.NativeUIContainer;

@:allow(gs.femto_ui.RootBase)
class Root extends RootBase
{
	public static var instance(get, never) : Root;

	private static var instance_ : Root = null;

	public var color_gripper_	: Int = 0x95D13A;
	public var color_movesize_	: Int = 0x0040c0;
	public var color_pressed_	: Int = 0x00aaaa;
	public var color_disabled_	: Int = 0x505050;
	public var color_ui_text_	: Int = 0xFAC8D9;
    public var color_graph_		: Int = 0x408080;
    public var color_bg_graph_	: Int = 0x202080;
	public var color_close_		: Int = 0xFF9800;
	public var color_edit_		: Int = 0x0070A6;
	public var color_scroller_	: Int = 0x414c74;
	public var color_thumb_		: Int = 0x8080FF;
	public var color_updown_	: Int = 0x5581D2;
	public var color_bg_ruler_	: Int = 0x40000040;

    public var graph_width_ : Int = 256;
    //public var graph_width_: int = 16;
    public var graph_height_ : Int = 128;

	public var ui_factor_ : Float = 1;
	//:scaled by hi-res:
	public var def_text_size_			: Float = 14;
	public var input_text_size_			: Float = 18;
	public var small_tool_width_		: Float = 36;
	public var small_tool_height_		: Float = 32;
	public var tool_width_				: Float = 48;
	public var tool_height_				: Float = 42;
	public var tool_spacing_			: Float = 8;
	public var btn_width_				: Float = 80;
	public var spacing_					: Float = 2;
	public var hover_inflation_			: Float = 2;
	public var round_frame_				: Float = 5;
	public var content_down_offset_x_	: Float = 1;
	public var content_down_offset_y_	: Float = 1;

	private function new(owner: NativeUIContainer)
	{
		super(owner);
	}
//.............................................................................
	override private function init() : Void
	{
		super.init();

		instance_ = this;
	}
//.............................................................................
	private function init_Ex(res_x: Float, res_y: Float) : Void
	{
		var m : Float = Math.min(res_x, res_y);
		if (m >= 1080)
		{
			ui_factor_ = 2;//TODO fix me: 4K?
			def_text_size_			*= ui_factor_;
			input_text_size_		*= ui_factor_;
			small_tool_width_		*= ui_factor_;
			small_tool_height_		*= ui_factor_;
			tool_width_				*= ui_factor_;
			tool_height_			*= ui_factor_;
			tool_spacing_			*= ui_factor_;
			btn_width_				*= ui_factor_;
			spacing_				*= ui_factor_;
			hover_inflation_		*= ui_factor_;
			round_frame_			*= ui_factor_;
			content_down_offset_x_	*= ui_factor_;
			content_down_offset_y_	*= ui_factor_;
		}
	}
//.............................................................................
	private static inline function get_instance() : Root
	{
		return instance_;
	}
//.............................................................................
	public static function create(owner : NativeUIContainer) : Root
	{
		if (null == instance_)
		{
			instance_ = new Root(owner);
		}
		return instance_;
	}
//.............................................................................
}