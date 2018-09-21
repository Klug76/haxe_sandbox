package gs.konsole;

//import com.gs.femto_ui.util.StaticAssertion;
import gs.femto_ui.util.Util;

#if flash
import flash.text.StyleSheet;
#end
#if (flash || openfl)
import flash.display.DisplayObject;
#end

class KonsoleConfig
{
	//public var max_lines_: Int = 8;//:must be 2^N
	//public var max_lines_: Int = 128;//:must be 2^N
	public var max_lines_ : Int = 2048;  //:must be 2^N
	//public var max_lines_ : Int = 1000;

	public var redirect_trace_		: Bool = true;

	public var con_bg_alpha_		: Float = 0.9;
	public var crosshair_alpha_		: Float = 0.75;
	public var ruler_overlay_alpha_	: Float = 0.15;

	public var con_bg_color_		: Int = 0x000080;
	public var con_text_color_		: Int = 0xFFff80;//TODO fix me: how to set selection color!?
	public var con_hint_color_		: Int = 0xFFffCA;
	public var cmd_text_color_		: Int = 0xFFff80;
	public var btn_copy_color_		: Int = 0x009688;
	public var btn_tool_color_		: Int = 0x3F51B5;
	public var btn_clear_color_		: Int = 0xc00020;
	public var crosshair_color_		: Int = 0xAAcc00;
	public var pt1_color_			: Int = 0xFF0000;
	public var pt2_color_			: Int = 0xFFff00;
	public var zoom_bg_color_		: Int = 0xFFffFF;
	public var ruler_text_color_	: Int = 0x000000;
	public var ruler_bg_color_		: Int = 0xFFffFF;
	public var ruler_line_color_	: Int = 0xFFffFF;
	public var ruler_overlay_color_	: Int = 0x000040;

	public var con_w_factor_		: Float = .8;//* stage.stageWidth
	public var con_h_factor_		: Float = .75;//* stage.stageHeight

	//:scaled by hi-res:
	public var min_width_			: Float = 128;
	public var min_height_			: Float = 128;
	public var con_text_size_		: Float = 14;
	public var cmd_height_			: Float = 32;
	public var zoom_size_			: Float = 48;

	public var zoom_factor_			: Int = 4;

#if (flash || openfl)
	public var zoom_root_: DisplayObject = null;
#end

	public var font_family_: String = "Helvetica,Arial,_sans";
	public var con_font_: String = null;
	public var cmd_font_: String = null;

	public var toggle_key_: UInt = 0xC0;//'`' key
	public var password_: String;

	private var init_: Bool = false;

#if flash
	private var css_ : StyleSheet;
#end

	public function new()
	{}
//.............................................................................
	public function init_View(platform: String, ui_factor: Float): Void
	{
		if (init_)
			return;
		init_ = true;
		if ((platform == "WIN") || (platform == "WEB"))//TODO fix me: !Mac::HTML5
		{
			if (null == con_font_)
			{
				con_font_ = "Consolas";
				font_family_ = con_font_;
			}
			if (null == cmd_font_)
			{
				cmd_font_ = con_font_;
			}
		}

		var factor : Float = ui_factor;
		if (factor != 1)
		{
			min_width_		*= factor;
			min_height_		*= factor;
			con_text_size_	*= factor;
			cmd_height_		*= factor;
			zoom_size_		*= factor;//TODO review
		}
	}
//.............................................................................
#if flash
	public function get_Css() : StyleSheet
	{
		if (null == css_)
		{
			css_ = new StyleSheet();
			css_.setStyle("p", {
						fontFamily : font_family_,
						fontSize : con_text_size_,
						color : "#" + Util.toHex(con_text_color_, 6)
					});
		}
		return css_;
	}
#end
}
