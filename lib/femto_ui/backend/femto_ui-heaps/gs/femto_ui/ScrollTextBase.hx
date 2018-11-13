package gs.femto_ui;

import h2d.Font;
import h2d.Interactive;
import h2d.Mask;
import h2d.HtmlText;
import gs.femto_ui.util.Util;
import hxd.Cursor;
import hxd.Event;

#if flash
import flash.text.StyleSheet;
#end

using gs.femto_ui.RootBase.NativeUIContainer;

class ScrollTextBase extends Visel
{
	private var font_: Font;
	private var mask_: Mask;
	private var text_field_: HtmlText;
	private var word_wrap_: Bool = false;

	private var lines_in_window_: Int = 0;

	public function new(owner : NativeUIContainer)
	{
		super(owner);
	}
//.............................................................................
	override private function init_Base() : Void
	{
		super.init_Base();

		var ni: Interactive = alloc_Interactive(Cursor.Button);
		ni.onWheel = on_Wheel;

		var r : Root = Root.instance;
		mask_ = new Mask(Math.round(r.small_tool_width_), Math.round(r.small_tool_height_), this);
		font_ = hxd.res.DefaultFont.get();//TODO fix me
		text_field_ = new HtmlText(font_, mask_);
	}
//.............................................................................
	public function set_Text_Format_Base(fname: String, fsize: Int, fcolor: Int): Void
	{
		//TODO fix me
	}
//.............................................................................
//.............................................................................
	public inline function get_Word_Wrap_Base(): Bool
	{
		return word_wrap_;
	}
//.............................................................................
	public inline function set_Word_Wrap_Base(value: Bool): Void
	{
		if (word_wrap_ == value)
			return;
		word_wrap_ = value;
		invalidate_Visel(Visel.INVALIDATION_FLAG_DATA);
	}
//.............................................................................
//.............................................................................
//.............................................................................
	private function on_Wheel(ev: Event): Void
	{
		//trace("scroll:on_Wheel " + ev.wheelDelta);
		var delta: Int = Math.round(ev.wheelDelta * 3);
		var st: ScrollText = cast this;
		var max_v: Int = st.get_Max_ScrollV();
		var old_scroll: Int = st.get_ScrollV();
		var new_scroll: Int = old_scroll + delta;
		new_scroll = Util.imin(Util.imax(1, new_scroll), max_v);
		if (new_scroll != old_scroll)
		{
			st.set_ScrollV(new_scroll);
			st.on_text_scroll();
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	override public function draw_Visel(): Void
	{
		super.draw_Visel();
		var flag: Bool = false;
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_DATA) != 0)
		{
			flag = true;
			if (word_wrap_)
				text_field_.maxWidth = width_;
			else
				text_field_.maxWidth = null;
		}
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
		{
			//trace("******** text size=" + width_ + "x" + height_);
			var r : Root = Root.instance;
			mask_.width = Math.round(Util.fmax(width_, r.small_tool_width_));
			mask_.height = Math.round(Util.fmax(height_, r.small_tool_height_));
			var old_lines: Int = lines_in_window_;
			if (word_wrap_)
			{
				if (text_field_.maxWidth != width_)
				{
					text_field_.maxWidth = width_;
					flag = true;
				}
			}
			recalc_Line_Wrap();
			flag = flag || (old_lines != lines_in_window_);
		}
		if (flag)
		{
			var st: ScrollText = cast this;
			var max_v: Int = st.get_Max_ScrollV();
			if (st.get_ScrollV() > max_v)
			{//:fix y - TODO review - how to keep scroll pos?
				st.set_ScrollV(max_v);
			}
			st.on_text_change();
		}
	}
//.............................................................................
	function recalc_Line_Wrap()
	{
		var line_h: Int = font_.lineHeight;
		lines_in_window_ = Util.imax(1, Math.floor(height_ / line_h));
	}
//.............................................................................
//.............................................................................
	public inline function append_Text_Base(value: String) : Void
	{
		if ((null == value) || (value.length <= 0))
			return;
		var st: ScrollText = cast this;
		var in_tail : Bool = st.get_ScrollV() == st.get_Max_ScrollV();
		text_field_.text += value;
		if (0 == lines_in_window_)
			recalc_Line_Wrap();
		if (in_tail)
			st.set_ScrollV(st.get_Max_ScrollV());
		st.on_text_change();
	}
//.............................................................................
	public inline function replace_Text_Base(value: String) : Void
	{
		var st: ScrollText = cast this;
		if (0 == lines_in_window_)
			recalc_Line_Wrap();
		if (value.length > 0)
		{
			text_field_.text = value;
			st.set_ScrollV(st.get_Max_ScrollV());
		}
		else
		{
			text_field_.text = "";
			st.set_ScrollV(1);
		}
		st.on_text_change();
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public inline function get_Max_ScrollV_Base() : Int
	{
		if (0 == lines_in_window_)
			recalc_Line_Wrap();
		var text_h: Int = text_field_.textHeight;
		var line_h: Int = font_.lineHeight;
		var result: Int = 2 - lines_in_window_;//:= 1 - lines_in_window_ + 1
		result += Math.floor(text_h / line_h);
		if ((text_h % line_h) != 0)
			++result;
		return Util.imax(1, result);
	}
//.............................................................................
	public inline function get_ScrollV_Base() : Int
	{
		var line_h: Int = font_.lineHeight;
		var text_y: Float = text_field_.y;
		var result: Int = Math.floor(-text_field_.y / line_h);
		++result;
		return Util.imax(1, result);
	}
//.............................................................................
	public inline function set_ScrollV_Base(value: Int) : Void
	{
		value = Util.imax(0, value - 1);
		var line_h: Int = font_.lineHeight;
		text_field_.y = -value * line_h;
	}
}