package com.gs.console;

import com.gs.femto_ui.Button;
import com.gs.femto_ui.Root;
import com.gs.femto_ui.Scrollbar;
import com.gs.femto_ui.Toolbar;
import com.gs.femto_ui.Viewport;
import com.gs.femto_ui.Visel;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

class KonsoleView extends Viewport
{
#if flash
    private var aux_ : TextField;
#else
	private var text__: String = "";
#end
    private var text_field_ : TextField;
    private var scrollbar_ : Scrollbar;
    private var btn_scroll_up_ : Button;
    private var btn_scroll_down_ : Button;
    private var toolbar_ : Toolbar;
    private var btn_copy_ : Button;
    private var btn_clear_ : Button;
    private var cmdline_ : CmdLine;
    private var fps_view_ : Viewport;
    private var mem_view_ : Viewport;

    private var k_ : Konsole;
	private var start_head_: Int = 0;
    private var last_seen_head_ : Int = 0;
    private var last_seen_tail_ : Int = 0;

    public function new(k : Konsole)
    {
        k_ = k;
        super(k_.stage_);
        //:super.visible = false;
        create_Children_Ex();
    }
//.............................................................................
    private function create_Children_Ex() : Void
    {
        var r : Root = Root.instance;

        resize(k_.cfg_.width_, k_.cfg_.height_);
        dummy_color = k_.cfg_.bg_color_;

#if flash
        aux_ = new TextField();
        aux_.type = TextFieldType.DYNAMIC;
        aux_.selectable = false;
        aux_.styleSheet = k_.cfg_.get_Css();
        aux_.condenseWhite = false;
        aux_.multiline = true;
#end

        text_field_ = new TextField();
        text_field_.type = TextFieldType.DYNAMIC;
        text_field_.defaultTextFormat = new TextFormat(r.con_font_, r.def_text_size_);
        //:text_field_.styleSheet = k.cfg_.get_Css();
        text_field_.wordWrap = true;
        text_field_.multiline = true;
#if flash
        text_field_.condenseWhite = false;
#end

        text_field_.y = r.tool_height_;  //:toolbar_.height
        text_field_.width = k_.cfg_.min_width_ - r.small_tool_width_;
        text_field_.height = k_.cfg_.min_height_ - r.tool_height_ - k_.cfg_.cmd_height_;
        addChild(text_field_);
        //text_field_.addEventListener(Event.CHANGE, on_Text_Change);
        text_field_.addEventListener(Event.SCROLL, on_Text_Scroll);

        btn_scroll_up_ = new Button(this, "\u02c4", on_Scroll_Up);
        btn_scroll_up_.auto_repeat = true;
        btn_scroll_up_.dummy_color = 0x008000;
        btn_scroll_up_.y = r.small_tool_height_ + r.spacing_;
        btn_scroll_up_.width = r.small_tool_width_;
        btn_scroll_up_.height = r.small_tool_height_;

        scrollbar_ = new Scrollbar(this, on_Scrollbar_Scroll);
        scrollbar_.dummy_color = 0x0c4c40;
        scrollbar_.y = r.small_tool_height_ * 2 + r.spacing_ * 2;
        scrollbar_.width = r.small_tool_width_;
        scrollbar_.reset(1, 1, 1);

        btn_scroll_down_ = new Button(this, "\u02c5", on_Scroll_Down);
        btn_scroll_down_.auto_repeat = true;
        btn_scroll_down_.dummy_color = 0x008000;
        btn_scroll_down_.width = r.small_tool_width_;
        btn_scroll_down_.height = r.small_tool_height_;

        toolbar_ = new Toolbar(this);
        toolbar_.spacing_ = r.tool_spacing_;
        toolbar_.height = r.tool_height_;
        toolbar_.x = r.tool_width_ + r.tool_spacing_;

        var b : Button;

        b = new Button(toolbar_, "copy", on_Copy_Click);
        b.dummy_color = 0x008000;
        b.resize(80, r.tool_height_);
        btn_copy_ = b;

        b = new Button(toolbar_, "fps", on_Fps_Click);
        b.dummy_color = 0x0000FF;
        b.resize(80, r.tool_height_);

        b = new Button(toolbar_, "mem", on_Mem_Click);
        b.dummy_color = 0x00FF00;
        b.resize(80, r.tool_height_);

        b = new Button(toolbar_, "clear", on_Clear_Click);
        b.dummy_color = 0xff0000;
        b.resize(80, r.tool_height_);
        btn_clear_ = b;

        cmdline_ = new CmdLine(this, k_);
        cmdline_.height = k_.cfg_.cmd_height_;
        cmdline_.dummy_color = 0xc0ffc0;

        mover_.resize(r.tool_width_, r.tool_height_);
        mover_.dummy_color = 0xFF0040c0;

        resizer_.min_width_ = k_.cfg_.min_width_;
        resizer_.min_height_ = k_.cfg_.min_height_;

        if (visible)
        {
            Root.instance.frame_signal_.add(on_Enter_Frame);
            invalidate(Visel.INVALIDATION_FLAG_SCROLL);
        }
    }
//.............................................................................
    //private function on_Text_Change(e: Event): void
    //{
    //	trace("text::change");
    //}
//.............................................................................
    private function on_Text_Scroll(e : Event) : Void
    {
		//trace("text::scroll " + text_field_.scrollV + " of " + text_field_.maxScrollV);
        invalidate(Visel.INVALIDATION_FLAG_SCROLL);
    }
//.............................................................................
    private function on_Clear_Click(e : Event) : Void
    {
        k_.clear();
    }
//.............................................................................
    private function on_Copy_Click(e : Event) : Void
    {
        k_.copy();
    }
//.............................................................................
    private function on_Fps_Click(e : Event) : Void
    {
        if (null == fps_view_)
        {
            fps_view_ = new Viewport(stage);
            var m : FpsMonitor = new FpsMonitor(null);
            m.bg_color_ = 0x202080;
            m.start();  //:set size
            fps_view_.content = m;  //:use size
            //fps_view_.dummy_color = 0x202080;
            fps_view_.movesize(100, 100, m.graph_width_ + Root.instance.small_tool_width_, m.graph_height_);
            return;
        }
        fps_view_.visible = !fps_view_.visible;
        if (fps_view_.visible)
        {
            fps_view_.bring_To_Top();
        }
    }
//.............................................................................
    private function on_Mem_Click(e : Event) : Void
    {
        if (null == mem_view_)
        {
            mem_view_ = new Viewport(stage);
            var m : MemMonitor = new MemMonitor(null);
            m.bg_color_ = 0x202080;
            m.start();  //:set size
            mem_view_.content = m;  //:use size
            //mem_view_.dummy_color = 0x202080;
            mem_view_.movesize(100, 300, m.graph_width_ + Root.instance.small_tool_width_, m.graph_height_);
            return;
        }
        mem_view_.visible = !mem_view_.visible;
        if (mem_view_.visible)
        {
            mem_view_.bring_To_Top();
        }
    }
//.............................................................................
	#if flash @:keep @:setter(visible) #else override #end
    private function set_visible(value : Bool) : #if flash Void #else Bool #end
    {
        super.visible = value;
        if (value)
        {
            Root.instance.frame_signal_.add(on_Enter_Frame);
            on_Enter_Frame();
            bring_To_Top();
        }
        else
        {
            Root.instance.frame_signal_.remove(on_Enter_Frame);
            //TODO fix me: do clean up!?
        }
        #if (!flash) return value; #end
    }
//.............................................................................
    override public function draw() : Void
    {
        if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
        {
            var r : Root = Root.instance;

            text_field_.width = width_ - r.small_tool_width_;
            text_field_.height = height_ - r.tool_height_ - k_.cfg_.cmd_height_;
            //trace("******** text size=" + width_ + "x" + height_);

            btn_scroll_up_.x = width_ - r.small_tool_width_;
            btn_scroll_down_.x = width_ - r.small_tool_width_;
            btn_scroll_down_.y = height_ - r.small_tool_height_ * 2 - r.spacing_;

            scrollbar_.x = width_ - r.small_tool_width_;
            scrollbar_.height = height_ - r.small_tool_height_ * 4 - r.spacing_ * 4;

            toolbar_.width = width_ - r.small_tool_width_ * 2 - r.spacing_;

            cmdline_.y = height_ - k_.cfg_.cmd_height_;
            cmdline_.width = width_ - r.small_tool_width_ - r.spacing_;
        }
        else if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SCROLL) != 0)
		{//:INVALIDATION_FLAG_SCROLL frame after INVALIDATION_FLAG_SIZE
            update_Controls();
        }
        super.draw();
    }
//.............................................................................
//.............................................................................
    override public function invalidate(flags : Int) : Void
    {
        invalid_flags_ |= flags;
    }
//.............................................................................
    private function on_Enter_Frame() : Void
    {
        refresh();
        if (invalid_flags_ != 0)
        {
            draw();
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
            s = k_.get_Html_From(last_seen_tail_);
            append_Text(s);
        }
        else
        {
            s = k_.get_Html();
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
            if (text_field_.scrollV < text_field_.maxScrollV)
            {
                return false;
            }
        }
        return true;
    }
//.............................................................................
    private function append_Text(s : String) : Void
    {
		//trace("** console::append '" + s + "'");
        if (s.length <= 0)
        {
            return;
        }
        var in_tail : Bool = text_field_.scrollV == text_field_.maxScrollV;

#if flash
        var ins_idx : Int = text_field_.length;
        aux_.htmlText = s;
        var temp : String = aux_.getXMLText();
        text_field_.insertXMLText(ins_idx, ins_idx, temp, false);
		aux_.htmlText = "";
#else
		text__ += s;
        text_field_.htmlText = text__;
		//:BUGBUG: get_htmlText doesn't work in openfl (yet, v.7,1,2)
        //:text_field_.htmlText += s;
#end

        if (in_tail)
        {
            text_field_.scrollV = text_field_.maxScrollV;
        }
        invalidate(Visel.INVALIDATION_FLAG_SCROLL);
    }
    //.............................................................................
    private function replace_Text(s : String) : Void
    {
        if (s.length > 0)
        {
			//trace("** console::replace '" + s + "'");
#if flash
			var len : Int = text_field_.length;
            aux_.htmlText = s;
            var temp : String = aux_.getXMLText();
            text_field_.insertXMLText(0, len, temp, false);
			aux_.htmlText = "";
#else
			text__ = s;
            text_field_.htmlText = s;
#end

            text_field_.scrollV = text_field_.maxScrollV;
        }
        else
        {
			//trace("** console::clear");
#if flash
			var len : Int = text_field_.length;
			if (len > 0)
			{
				text_field_.text = "";
				text_field_.scrollV = 0;//:?
			}
#else
			if (text__.length > 0)
			{
				text__ = s;
				text_field_.text = s;
				text_field_.scrollV = 0;//:BUG - scrollV doesn't reset to 0 in openfl (yet, v.7,1,2)
			}
#end
        }
        invalidate(Visel.INVALIDATION_FLAG_SCROLL);
    }
//.............................................................................
//.............................................................................
    private function update_Controls() : Void
    {
        var cur : Int = text_field_.scrollV;
        var max : Int = text_field_.maxScrollV;
        //trace("log::update_Controls " + max);
        var flag : Bool = max > 1;
        if (!scrollbar_.thumb_.is_drag_mode)
        {
            scrollbar_.enabled = flag;
            scrollbar_.thumb_.enabled = flag;
        }
        scrollbar_.value = cur;
        scrollbar_.max = max;
        btn_scroll_up_.enabled = flag && (cur > 1);
        btn_scroll_down_.enabled = flag && (cur < max);

        flag = !k_.is_Empty();
        btn_copy_.enabled = flag;
        btn_clear_.enabled = flag;
    }
//.............................................................................
    private function on_Scroll_Up(e : Event) : Void
    {
        on_Scrollbar_Scroll(text_field_.scrollV - 1);
    }
//.............................................................................
    private function on_Scroll_Down(e : Event) : Void
    {
        on_Scrollbar_Scroll(text_field_.scrollV + 1);
    }
//.............................................................................
    private function on_Scrollbar_Scroll(v : Int) : Void
    {
        if (-1 == v)
        {//:drag finish
            invalidate(Visel.INVALIDATION_FLAG_SCROLL);
            return;
        }
        var max : Int = text_field_.maxScrollV;
        if (max <= 1)
            return;
        if (v < 1)
            v = 1;
        if (v > max)
            v = max;
        text_field_.scrollV = v;
    }
}

