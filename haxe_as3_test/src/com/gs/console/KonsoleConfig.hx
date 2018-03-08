package com.gs.console;

import flash.errors.Error;
import com.gs.femto_ui.Root;

#if flash
import flash.text.StyleSheet;
#end

class KonsoleConfig
{
    public var make_links_ : Bool = false;
    public var max_lines_: Int = 8;//:must be 2^N
    //public var max_lines_: Int = 128;//:must be 2^N
    //public var max_lines_ : Int = 2048;  //:must be 2^N

    public var bg_color_ : Int = 0x008040;

    public var cmd_height_ : Int = 32;
    public var min_width_ : Int = 128;
    public var min_height_ : Int = 128;
    public var width_ : Int = 600;
    public var height_ : Int = 450;

    public var password_ : String;

#if flash
    private var css_ : StyleSheet;
#end

    public function new()
    {
		#if debug
        {
            if (!((max_lines_ > 0) && ((max_lines_ & (max_lines_ - 1)) == 0)))
            {
                throw new Error("max_lines must be 2^N");
            }
        }
		#end
        var factor : Float = Root.instance.ui_factor_;
        if (factor != 1)
        {
			//TODO fix me
            //cmd_height_ *= factor;
            //min_width_ *= factor;
            //min_height_ *= factor;
            //width_ *= factor;
            //height_ *= factor;
        }
    }
//.............................................................................
#if flash
    public function get_Css() : StyleSheet
    {
        if (null == css_)
        {
            css_ = new StyleSheet();
            var def_text_size : Int = Root.instance.def_text_size_;
            css_.setStyle("p", {
						fontFamily : Root.FONT_FAMILY,
                        fontSize : def_text_size,
                        color : "#000000"
                    });
        }
        return css_;
    }
#end
}
