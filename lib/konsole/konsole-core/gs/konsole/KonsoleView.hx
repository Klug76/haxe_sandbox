package gs.konsole;

import gs.femto_ui.Button;
import gs.femto_ui.InfoClick;
import gs.femto_ui.Root;
import gs.femto_ui.ScrollText;
import gs.femto_ui.Scrollbar;
import gs.femto_ui.Toolbar;
import gs.femto_ui.Viewport;
import gs.femto_ui.Visel;

class KonsoleView extends Viewport
{
	private var scroll_text_: ScrollText;
	private var scrollbar_ : Scrollbar;
	private var btn_scroll_up_ : Button;
	private var btn_scroll_down_ : Button;
	private var toolbar_ : Toolbar;
	private var btn_copy_ : Button;
	private var btn_clear_ : Button;
	private var cmdline_ : CmdLine = null;

	private var k_: Konsole;
	private var start_head_: Int = 0;
	private var last_seen_head_ : Int = 0;
	private var last_seen_tail_ : Int = 0;
	private var is_html_: Bool = false;//TODO kill

	public function new(k : Konsole, is_html: Bool)
	{
		k_ = k;
		is_html_ = is_html;
		super();
#if debug
		name = "console::view";
#end
		//:super.visible = false;
		create_Children_Ex();
	}
//.............................................................................
	private function create_Children_Ex() : Void
	{
		var r : Root = Root.instance;

		resize_Visel(k_.cfg_.con_w_factor_ * r.stage_width, k_.cfg_.con_h_factor_ * r.stage_height);
		dummy_color = k_.cfg_.con_bg_color_;
		alpha = k_.cfg_.con_bg_alpha_;

		scroll_text_ = new ScrollText(this);
		scroll_text_.set_Text_Format(k_.cfg_.con_font_, Std.int(k_.cfg_.con_font_size_), k_.cfg_.con_text_color_);
		scroll_text_.word_wrap = true;
		scroll_text_.dummy_color = 0x40604060;

		//scroll_text_.html = true;

		scroll_text_.y = r.tool_height_;  //:toolbar_.height
		scroll_text_.on_text_scroll = on_Text_Scroll;
		scroll_text_.on_text_change = on_Text_Scroll;

		btn_scroll_up_ = new Button(this, "\u02c4", on_Scroll_Up);
		btn_scroll_up_.auto_repeat = true;
		btn_scroll_up_.dummy_color = r.color_updown_;
		btn_scroll_up_.y = r.small_tool_height_ + r.spacing_;
		btn_scroll_up_.width = r.small_tool_width_;
		btn_scroll_up_.height = r.small_tool_height_;
		btn_scroll_up_.enabled = false;

		scrollbar_ = new Scrollbar(this, on_Scrollbar_Scroll);
		scrollbar_.y = r.small_tool_height_ * 2 + r.spacing_ * 2;
		scrollbar_.width = r.small_tool_width_;
		scrollbar_.reset(1, 1, 1);

		btn_scroll_down_ = new Button(this, "\u02c5", on_Scroll_Down);
		btn_scroll_down_.auto_repeat = true;
		btn_scroll_down_.dummy_color = r.color_updown_;
		btn_scroll_down_.width = r.small_tool_width_;
		btn_scroll_down_.height = r.small_tool_height_;
		btn_scroll_down_.enabled = false;

		toolbar_ = new Toolbar(this);
		toolbar_.spacing_ = r.tool_spacing_;
		toolbar_.width = width_ - r.small_tool_width_ * 2 - r.spacing_;
		toolbar_.height = r.tool_height_;
		toolbar_.x = r.tool_width_ + r.tool_spacing_;

		inline function spawn_Button(text: String, callback: InfoClick->Void, color: UInt = 0)
		{
			var b : Button = new Button(toolbar_, text, callback);
			b.resize_Visel(r.btn_width_, r.tool_height_);
			b.dummy_color = (color != 0) ? color : k_.cfg_.btn_tool_color_;
			return b;
		}
		//TODO refactor:
		btn_copy_ = spawn_Button("copy", on_Copy_Click, k_.cfg_.btn_copy_color_);

		if (k_.have_Command("send"))
			spawn_Button("send", on_Send_Click, k_.cfg_.btn_copy_color_);

		if (k_.have_Command("fps"))
			spawn_Button("fps", on_Fps_Click);
		if (k_.have_Command("mem"))
			spawn_Button("mem", on_Mem_Click);

		if (k_.have_Command("tree"))
			spawn_Button("tree", on_Tree_Click);
		if (k_.have_Command("ruler"))
			spawn_Button("ruler", on_Ruler_Click);

		btn_clear_ = spawn_Button("clear", on_Clear_Click, k_.cfg_.btn_clear_color_);

		var scroll_text_h: Float = height_ - r.tool_height_;
		if (k_.cfg_.allow_command_line_)
		{
			cmdline_ = new CmdLine(this, k_);
			cmdline_.height = k_.cfg_.cmd_height_;
			scroll_text_h -= k_.cfg_.cmd_height_;
		}
		scroll_text_.resize_Visel(width_ - r.small_tool_width_, scroll_text_h);

		mover_.resize_Visel(r.tool_width_, r.tool_height_);
		mover_.dummy_color = r.color_movesize_;

		min_content_width_ =
			resizer_.min_width_ = k_.cfg_.min_width_;
		min_content_height_ =
			resizer_.min_height_ = k_.cfg_.min_height_;

		if (visible)
		{
			add_Signals();
			invalidate_Visel(Visel.INVALIDATION_FLAG_SCROLL);
		}
	}
//.............................................................................
	private function add_Signals() : Void
	{
		Root.instance.frame_signal_.add(on_Enter_Frame);
	}
//.............................................................................
	private function remove_Signals() : Void
	{
		Root.instance.frame_signal_.remove(on_Enter_Frame);
	}
//.............................................................................
//.............................................................................
//.............................................................................
	private function on_Text_Scroll() : Void
	{
		invalidate_Visel(Visel.INVALIDATION_FLAG_SCROLL);
	}
//.............................................................................
	private function on_Clear_Click(_) : Void
	{
		k_.clear();
	}
//.............................................................................
	private function on_Copy_Click(_) : Void
	{
		k_.copy();
	}
//.............................................................................
	private function on_Fps_Click(_) : Void
	{
		k_.eval_Command("fps");
	}
//.............................................................................
	private function on_Mem_Click(_) : Void
	{
		k_.eval_Command("mem");
	}
//.............................................................................
	private function on_Send_Click(_) : Void
	{
		k_.eval_Command("send");
	}
//.............................................................................
	private function on_Tree_Click(_) : Void
	{
		k_.eval_Command("tree");
	}
//.............................................................................
	private function on_Ruler_Click(_) : Void
	{
		k_.eval_Command("ruler");
	}
//.............................................................................
//.............................................................................
	override private function resume() : Void
	{
		super.resume();
		add_Signals();
		on_Enter_Frame();
	}
//.............................................................................
	override private function suspend() : Void
	{
		remove_Signals();
		super.suspend();
	}
//.............................................................................
//.............................................................................
	override public function draw_Visel() : Void
	{
		super.draw_Visel();//:may resize
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
		{
			var r : Root = Root.instance;

			btn_scroll_up_.x = width_ - r.small_tool_width_;
			btn_scroll_down_.x = width_ - r.small_tool_width_;
			btn_scroll_down_.y = height_ - r.small_tool_height_ * 2 - r.spacing_;

			scrollbar_.x = width_ - r.small_tool_width_;
			scrollbar_.height = height_ - r.small_tool_height_ * 4 - r.spacing_ * 4;

			toolbar_.width = width_ - r.small_tool_width_ * 2 - r.spacing_;

			var scroll_text_h: Float = height_ - r.tool_height_;

			if (cmdline_ != null)
			{
				cmdline_.y = height_ - k_.cfg_.cmd_height_;
				cmdline_.width = width_ - r.small_tool_width_ - r.spacing_;
				scroll_text_h -= k_.cfg_.cmd_height_;
			}

			scroll_text_.resize_Visel(width_ - r.small_tool_width_, scroll_text_h);
			//trace("******** text size=" + scroll_text_.width + "x" + scroll_text_.height);
		}
		else if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SCROLL) != 0)//:see on_Enter_Frame
		{//:INVALIDATION_FLAG_SCROLL frame should be after INVALIDATION_FLAG_SIZE
			update_Controls();
		}
	}
//.............................................................................
//.............................................................................
	override public function invalidate_Visel(flags : Int) : Void
	{
		invalid_flags_ |= flags;
	}
//.............................................................................
	private function on_Enter_Frame() : Void
	{
		refresh();
		if (invalid_flags_ != 0)
		{
			draw_Visel();
			if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
			{
				invalid_flags_ = Visel.INVALIDATION_FLAG_SCROLL;
			}
			else
			{
				invalid_flags_ = 0;
			}
		}
	}
	//.............................................................................
	private function refresh() : Void
	{
		var cmd : Int = k_.query_Update(last_seen_head_, last_seen_tail_);
		if (0 == cmd)
		{//:nop
			return;
		}
		var s : String;
		if (Konsole.APPEND == cmd)
		{
			if (!can_Append())
			{
				return;
			}
			if (k_.head >= start_head_ + k_.cfg_.max_lines_)
				cmd = Konsole.REPLACE;//:clean up
		}
		if (Konsole.APPEND == cmd)
		{
			if (is_html_)
				s = k_.get_Html_From(last_seen_tail_);
			else
				s = k_.get_Text_From(last_seen_tail_);
			append_Text(s);
		}
		else
		{
			if (is_html_)
				s = k_.get_Html();
			else
				s = k_.get_Text();
			replace_Text(s);
			start_head_ = k_.head;
		}
		last_seen_head_ = k_.head;
		last_seen_tail_ = k_.tail;
	}
//.............................................................................
	private function can_Append() : Bool
	{
		//TODO review
		//if under selection!?
		if (scrollbar_.thumb_.is_drag_mode)
		{
			if (scroll_text_.get_ScrollV() < scroll_text_.get_Max_ScrollV())
			{
				return false;
			}
		}
		return true;
	}
//.............................................................................
	inline private function append_Text(s : String) : Void
	{
		scroll_text_.append_Text(s);
	}
//.............................................................................
	inline private function replace_Text(s : String) : Void
	{
		scroll_text_.replace_Text(s);
	}
//.............................................................................
//.............................................................................
	private function update_Controls() : Void
	{
		var cur : Int = scroll_text_.get_ScrollV();
		var max : Int = scroll_text_.get_Max_ScrollV();
		//trace("log::update_Controls " + max);
		var flag : Bool = max > 1;
		scrollbar_.value = cur;
		scrollbar_.max = max;
		btn_scroll_up_.enabled = flag && (cur > 1);
		btn_scroll_down_.enabled = flag && (cur < max);

		flag = !k_.is_Empty();
		btn_copy_.enabled = flag;
		btn_clear_.enabled = flag;
	}
//.............................................................................
	private function on_Scroll_Up(e : InfoClick) : Void
	{
		on_Scrollbar_Scroll(scroll_text_.get_ScrollV() - 1);
	}
//.............................................................................
	private function on_Scroll_Down(e : InfoClick) : Void
	{
		on_Scrollbar_Scroll(scroll_text_.get_ScrollV() + 1);
	}
//.............................................................................
	private function on_Scrollbar_Scroll(v : Int) : Void
	{
		if (0 == v)
		{//:drag finish
			//flash.Lib.trace("drag finish");
			invalidate_Visel(Visel.INVALIDATION_FLAG_SCROLL);
			return;
		}
		var max : Int = scroll_text_.get_Max_ScrollV();
		if (max <= 1)
			return;
		if (v < 1)
			v = 1;
		if (v > max)
			v = max;
		scroll_text_.set_ScrollV(v);
	}
//.............................................................................
	override public function bring_To_Top() : Void
	{
		//:nop - do not cover fps meter etc
	}
//.............................................................................
}

