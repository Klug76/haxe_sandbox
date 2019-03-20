package gs.femto_ui;

import gs.femto_ui.kha.Event;
import gs.femto_ui.util.Util;
import kha.graphics2.Graphics;
import kha.Font;

using gs.femto_ui.RootBase.NativeUIContainer;

//:see h:\Borland\1\Borland\Bred3r\Literal\obsolete\wrap\Unit4.pas for word wrap?

class ScrollTextBase extends Visel
{
	private var text__: String = "";
	private var hard_line_: Array<Int> = [0, 0];
	private var hard_line_count_: Int = 1;
	private var vis_hard_line_: Int = 0;
	private var vis_soft_line_: Int = 0;
	private var vis_hard_line_temp_: Int = 0;
	private var vis_soft_line_temp_: Int = 0;
	private var lines_in_window_: Int = 1;
	private var chars_in_window_: Int = 8;
	private var wrap_zone_begin_: Int = 0;
	private var wrap_zone_soft_lines_: Int = 0;
	private var fname_: String = null;//TODO fix me
	private var fsize_: Int = 0;
	private var fcolor_: Int = 0;
	private var word_wrap_: Bool = false;

	public function new(owner : NativeUIContainer, is_html: Bool)
	{
		super(owner);
		//NOTE: no html support yet.
	}
//.............................................................................
	public inline function set_Text_Format_Base(fname: String, fsize: Int, fcolor: Int) : Void
	{
		fname_ = fname;
		fsize_ = fsize;
		fcolor_ = fcolor;
	}
//.............................................................................
	override private function init_Base(): Void
	{
		super.init_Base();
		add_Listener(on_Event);
	}
//.............................................................................
	override private function destroy_Base(): Void
	{
		super.destroy_Base();
		remove_Listener(on_Event);
	}
//.............................................................................
	private function on_Event(ev: Event): Void
	{
		switch(ev.type)
		{
		case Event.MOUSE_WHEEL:
			on_Mouse_Wheel(ev);
		}
	}
//.............................................................................
	private function on_Mouse_Wheel(ev: Event): Void
	{
		var delta: Int = ev.code;
		ev.stop_propagation = scroll_By(delta);
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	override function render_Base(gr: Graphics, nx: Float, ny: Float) : Void
	{
		render_Base_Background(gr, nx, ny);
		render_Text(gr, nx, ny);
		render_Children(gr, nx, ny);
	}
//.............................................................................
//.............................................................................
	private function render_Text(gr: Graphics, nx: Float, ny: Float) : Void
	{
		if ((text__.length <= 0) || (width_ < 2) || (height_ < 2))
			return;
		var r: Root = Root.instance;
		var font: Font = r.font_;//TODO fix me
		var font_size: Int = fsize_;
		if (0 == font_size)
		{
			font_size = Std.int(r.def_font_size_);
			fcolor_ = r.color_ui_text_;
		}
		var text_h: Float = font.height(font_size);
		if (text_h < 1)
			return;
		var text_x: Float = r.spacing_;
		var text_y: Float = 0;
		gr.font = font;
		gr.fontSize = font_size;
		gr.color = fcolor_ | 0xFF000000;
		gr.scissor(Math.round(nx), Math.round(ny), Math.round(width_), Math.round(height_));
		get_First_Line();
		for (i in 0...lines_in_window_ + 2)
		{
			var s: String = get_Temp_Line();
			if (s.length > 0)
				gr.drawString(s, Math.round(nx + text_x), Math.round(ny + text_y));
			if (!get_Next_Line())
				break;
			text_y += text_h;//TODO fix me: use baseline: but need for totalAscent, totalDescent?
		}
		gr.disableScissor();
	}
//.............................................................................
	override public function draw_Visel(): Void
	{
		super.draw_Visel();
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_TEXT | Visel.INVALIDATION_FLAG_SIZE)) != 0)
		{
			var old_lines: Int = lines_in_window_;
			var old_vis_soft_line: Int = vis_soft_line_;
			var old_max_scroll: Int = wrap_zone_begin_ + wrap_zone_soft_lines_;
			recalc_Line_Wrap();
			//TODO fix me: review
			if ((old_lines != lines_in_window_) || (old_vis_soft_line != vis_soft_line_) ||
				(old_max_scroll != wrap_zone_begin_ + wrap_zone_soft_lines_))
			{
				var st: ScrollText = cast this;
				st.on_text_change();
			}
		}
	}
//.............................................................................
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
		if (text__.length > 0)
			invalidate_Visel(Visel.INVALIDATION_FLAG_TEXT);
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public inline function append_Text_Base(value: String) : Void
	{
		if ((null == value) || (value.length <= 0))
			return;
		//trace("********* append '" + value + "'");
		var st: ScrollText = cast this;
		var in_tail : Bool = st.get_ScrollV() == st.get_Max_ScrollV();
		text__ += value;
		recalc_Hard_Lines();
		recalc_Line_Wrap();
		if (in_tail)
			st.set_ScrollV(st.get_Max_ScrollV());
		st.on_text_change();
	}
//.............................................................................
	public inline function replace_Text_Base(value: String) : Void
	{
		if (null == value)
			value = "";
		if (text__ == value)
			return;
		text__ = value;
		vis_hard_line_ = 0;
		vis_soft_line_ = 0;
 		recalc_Hard_Lines();
		recalc_Line_Wrap();
		var st: ScrollText = cast this;
		st.on_text_change();
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public inline function get_Max_ScrollV_Base() : Int
	{
		if (0 == hard_line_count_)
		{
			recalc_Hard_Lines();
			recalc_Line_Wrap();
		}
		var result: Int = 2 - lines_in_window_;//:= 1 - lines_in_window_ + 1
		if (word_wrap_)
			result += wrap_zone_begin_ + wrap_zone_soft_lines_;
		else
			result += hard_line_count_;
		return Util.imax(1, result);//:1-based like flash::TextField
	}
//.............................................................................
//.............................................................................
	public inline function get_ScrollV_Base() : Int
	{
		var result: Int = vis_hard_line_;
		if (word_wrap_)
		{
			if (result >= wrap_zone_begin_)
			{//: [wrap_zone_begin_..vis_hard_line_ - 1)
				result = wrap_zone_begin_;
				for (i in wrap_zone_begin_...vis_hard_line_)
				{
					result += calc_Wrap_Count(i);
				}
				result += vis_soft_line_;
			}
		}
		return ++result;//:1-based like flash::TextField
	}
//.............................................................................
	public inline function get_ScrollV_Temp() : Int
	{
		var result: Int = vis_hard_line_temp_;
		if (word_wrap_)
		{
			if (result >= wrap_zone_begin_)
			{//: [wrap_zone_begin_..vis_hard_line_temp_ - 1)
				result = wrap_zone_begin_;
				for (i in wrap_zone_begin_...vis_hard_line_temp_)
				{
					result += calc_Wrap_Count(i);
				}
				result += vis_soft_line_temp_;
			}
		}
		return ++result;//:1-based like flash::TextField
	}
//.............................................................................
	public inline function set_ScrollV_Base(value: Int) : Void
	{
		value = Util.imax(0, value - 1);
		var last_line: Int = hard_line_count_ - 1;
		if (word_wrap_)
		{
			if (value <= wrap_zone_begin_)
			{
				vis_soft_line_ = 0;
				vis_hard_line_ = value;
			}
			else
			{
				value -= wrap_zone_begin_;
				var j: Int = 0;
				var found: Bool = false;
				for (i in wrap_zone_begin_...last_line + 1)
				{
					var k: Int = calc_Wrap_Count(i);
					if (j + k > value)
					{
						vis_hard_line_ = i;
						vis_soft_line_ = value - j;
						found = true;
						break;
					}
					j += k;
				}
				if (!found)
				{//:paranoia
					vis_hard_line_ = last_line;
					vis_soft_line_ = calc_Wrap_Count(last_line) - 1;
				}
			}
		}
		else
		{
			vis_soft_line_ = 0;
			vis_hard_line_ = value;
			if (vis_hard_line_ > last_line)
				vis_hard_line_ = last_line;
		}
		//TODO invalidate substring cache
	}
//.............................................................................
	private function scroll_By(delta: Int): Bool
	{
		if (0 == delta)
			return false;
		get_First_Line();
		var old_hard: Int = vis_hard_line_temp_;
		var old_soft: Int = vis_soft_line_temp_;
		if (delta > 0)
		{
			var max_v: Int = get_Max_ScrollV_Base();
			for (i in 0...delta)
			{
				if (get_ScrollV_Temp() >= max_v)
					break;//:prevent overscroll
				if (!get_Next_Line())
					break;
			}
		}
		else
		{
			for (i in 0...-delta)
			{
				if (!get_Prev_Line())
					break;
			}
		}
		if ((old_hard != vis_hard_line_temp_) || (old_soft != vis_soft_line_temp_))
		{
			save_Temp_Line();
			//TODO invalidate substring cache
			var st: ScrollText = cast this;
			st.on_text_scroll();
			return true;
		}
		return false;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	private function recalc_Line_Wrap() : Void
	{
		if ((width_ < 32) || (height_ < 32))
		{
			return;
		}
		var r: Root = Root.instance;
		var font: Font = r.font_;
		var font_size: Int = fsize_;
		var line_h: Float = font.height(font_size);
		if (line_h < 1)
			return;
		lines_in_window_ = Util.imax(1, Math.floor(height_ / line_h));

		wrap_zone_begin_ = hard_line_count_;
		wrap_zone_soft_lines_ = 0;

		if (!word_wrap_)
		{
			vis_soft_line_ = 0;
			return;
		}

		//TODO kill chars_in_window_
		//var arr: Array<Int> = ['W'.code];
		var arr: Array<Int> = ['0'.code];//TODO fix me
		var char_w: Float = font.widthOfCharacters(font_size, arr, 0, arr.length);
		if (char_w < 1)
			return;
		chars_in_window_ = Util.imax(8, Math.floor(width_ / char_w));

		if (text__.length > 0)
		{
			var wrap_limit: Int = Util.imax(lines_in_window_, 64);
			while (true)
			{
				wrap_zone_soft_lines_ += calc_Wrap_Count(--wrap_zone_begin_);
				if (0 == wrap_zone_begin_)
					break;
				if (wrap_zone_soft_lines_ > wrap_limit)
					break;
			}
		}
		//trace("SCROLLTEXT::wrap_zone_begin_=" + wrap_zone_begin_);
		//trace(" wrap_zone_soft_lines_=" + wrap_zone_soft_lines_);
		//trace(" lines_in_window_=" + lines_in_window_);

		if (vis_soft_line_ > 0)
		{
			var vis_wrap_count = calc_Wrap_Count(vis_hard_line_);
			if (vis_soft_line_ >= vis_wrap_count)
			{
				vis_soft_line_ = vis_wrap_count - 1;
				//trace("FIX vis_soft_line_=" + vis_soft_line_);
			}
		}

		//:got [0, wrap_zone_begin_) U [wrap_zone_begin_, hard_line_count_)
	}
//.............................................................................
	private function recalc_Hard_Lines() : Void
	{
		hard_line_count_ = 0;
		var len: Int = text__.length;
		if (len <= 0)
		{
			push_Hard_Line(0, 0);
			return;
		}
		var line_start: Int = 0;
		var line_end: Int = 0;
		var i: Int = 0;
		while (true)
		{
			var code: Int = text__.charCodeAt(i++);
			if (code == '\n'.code)
			{
				push_Hard_Line(line_start, line_end);
				line_start = i;
				line_end = line_start;
			}
			else
			{
				if ((code >= ' '.code) || (code == '\t'.code))
					++line_end;
			}
			if (i == len)
			{
				if (line_start < i)
					push_Hard_Line(line_start, line_end);
				break;
			}
		}
		//trace("hard_line_count_=" + hard_line_count_);
	}
//.............................................................................
	function push_Hard_Line(start: Int, end: Int)
	{
		hard_line_[hard_line_count_ * 2] = start;
		hard_line_[hard_line_count_ * 2 + 1] = end;
		++hard_line_count_;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	private function save_Temp_Line(): Void
	{
		vis_hard_line_ = vis_hard_line_temp_;
		vis_soft_line_ = vis_soft_line_temp_;
	}
//.............................................................................
	private function get_First_Line(): Void
	{
		if (word_wrap_)
		{
			if (wrap_zone_begin_ + wrap_zone_soft_lines_ >= lines_in_window_)
			{
				vis_hard_line_temp_ = vis_hard_line_;
				vis_soft_line_temp_ = vis_soft_line_;
			}
			else
			{//:fit
				vis_hard_line_temp_ =
				vis_soft_line_temp_ = 0;
			}
		}
		else
		{
			vis_soft_line_temp_ = 0;
			if (hard_line_count_ >= lines_in_window_)
				vis_hard_line_temp_ = vis_hard_line_;
			else
				vis_hard_line_temp_ = 0;//:fit
		}
	}
//.............................................................................
	private function get_Next_Line(): Bool
	{
		if (word_wrap_)
		{
			var t: Int = vis_soft_line_temp_;
			if (++t < calc_Wrap_Count(vis_hard_line_temp_))
			{
				vis_soft_line_temp_ = t;
				return true;
			}
		}
		if (vis_hard_line_temp_ == hard_line_count_ - 1)
			return false;
		++vis_hard_line_temp_;
		vis_soft_line_temp_ = 0;
		return true;
	}
//.............................................................................
	private function get_Prev_Line(): Bool
	{
		if (word_wrap_)
		{
			var t: Int = vis_soft_line_temp_;
			if (--t >= 0)
			{
				vis_soft_line_temp_ = t;
				return true;
			}
		}
		if (vis_hard_line_temp_ == 0)
			return false;
		--vis_hard_line_temp_;
		vis_soft_line_temp_ = if (word_wrap_) calc_Wrap_Count(vis_hard_line_temp_) - 1 else 0;
		return true;
	}
//.............................................................................
	private function get_Temp_Line(): String
	{
		var s_pos1: Int = hard_line_[vis_hard_line_temp_ * 2];
		var s_pos2: Int = hard_line_[vis_hard_line_temp_ * 2 + 1];
		if (s_pos2 <= s_pos1)
			return "";
		if (word_wrap_)
		{
			s_pos1 += vis_soft_line_temp_ * chars_in_window_;
			s_pos2 = Util.imin(s_pos1 + chars_in_window_, s_pos2);
		}
		return text__.substring(s_pos1, s_pos2);//TODO fix me: cache substrings?
	}
//.............................................................................
	private function calc_Wrap_Count(hard_idx: Int): Int
	{
		hard_idx *= 2;
		var hard_line_len = -hard_line_[hard_idx++];
		hard_line_len += hard_line_[hard_idx];
		var result: Int = Math.floor(hard_line_len / chars_in_window_);
		if (hard_line_len % chars_in_window_ != 0)
			++result;
		return Util.imax(1, result);
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
}