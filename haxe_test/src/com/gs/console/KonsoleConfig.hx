package com.gs.console;

import com.gs.femto_ui.util.Util;
import flash.errors.Error;
import com.gs.femto_ui.Root;

#if flash
import flash.text.StyleSheet;
#end

class KonsoleConfig
{
	//public var max_lines_: Int = 8;//:must be 2^N
	//public var max_lines_: Int = 128;//:must be 2^N
	public var max_lines_ : Int = 2048;  //:must be 2^N

	//public var make_links_ : Bool = false;

	public var con_bg_alpha_	: Float = 0.9;

	public var con_bg_color_	: Int = 0x000080;
	public var con_text_color_	: Int = 0xFFFF80;//TODO fix me: how to set selection color!?
	public var con_hint_color_	: Int = 0xFFFFCA;
	public var cmd_text_color_	: Int = 0xFFFF80;
	public var btn_copy_color_	: Int = 0x009688;
	public var btn_tool_color_	: Int = 0x3F51B5;
	public var btn_clear_color_	: Int = 0xc00020;
	public var crosshair_color_	: Int = 0xAAcc00;
	public var pt1_color_		: Int = 0xff0000;
	public var pt2_color_		: Int = 0xffff00;

	public var width_			: Float = 600;
	public var height_			: Float = 450;

	//:scaled by hi-res:
	public var min_width_		: Float = 128;
	public var min_height_		: Float = 128;
	public var con_text_size_	: Float = 14;
	public var cmd_height_		: Float = 32;
	public var zoom_size_		: Float = 48;

	public var zoom_factor_		: Int = 4;
	public var custom_zoom_draw_: Bool = false;

	public var font_family_ : String = "Helvetica,Arial,_sans";
	public var con_font_ : String = null;
	public var cmd_font_ : String = null;

	public var password_ : String;

#if flash
	private var css_ : StyleSheet;
#end

	public function new()
	{

	}

	public function init(): Void
	{
		#if debug
		{
			if (!((max_lines_ > 0) && ((max_lines_ & (max_lines_ - 1)) == 0)))
			{
				throw new Error("max_lines must be 2^N");
			}
		}
		#end
		var r: Root = Root.instance;

		if ((r.platform_ == "WIN") || (r.platform_ == "WEB"))//TODO fix me: !Mac::HTML5
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

		var factor : Float = r.ui_factor_;
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
			var r: Root = Root.instance;
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