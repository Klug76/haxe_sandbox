package com.gs.femto_ui;

import flash.Lib;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;

//:________________________________________________________________________________________________
class Button extends Visel
{
	public var label(get, never) : Label;
	public var auto_repeat(get, set) : Bool;

	private var label_ : Label;
	private var on_click_ : Dynamic->Void;
	private var auto_repeat_ : Bool = false;
	private var repeat_time_ : Int = 0;
	private var repeat_event_ : Event = null;
	private var repeat_count_ : Int = 0;

	private static var repeat_button_ : Button = null;

	public var repeat_delay_ : Int = 400;
	public var hover_inflation_ : Int = 2;
	public var content_down_offset_x_ : Int = 1;
	public var content_down_offset_y_ : Int = 1;

	public function new(owner : DisplayObjectContainer, txt : String, on_Click : Dynamic->Void)
	{
		super(owner);
		init(txt, on_Click);
	}
//.............................................................................
	private function init(txt : String, on_Click : Dynamic->Void) : Void
	{
		buttonMode = true;
		label_ = new Label(this, txt);
		label_.h_align =
		label_.v_align = Align.CENTER;
		//label_.dummy_color = 0xff00ff;
		addChild(label_);

		on_click_ = on_Click;

		add_Mouse_Listeners();
		invalidate(Visel.INVALIDATION_FLAG_STATE);
	}
//.............................................................................
//.............................................................................
//.............................................................................
	private inline function get_label() : Label
	{
		return label_;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	override private function set_enabled(value : Bool) : Bool
	{
		if (enabled != value)
		{
			super.enabled = value;
			tabEnabled = value;
		}
		return value;
	}
//.............................................................................
	private function get_auto_repeat() : Bool
	{
		return auto_repeat_;
	}
//.............................................................................
	private function set_auto_repeat(value : Bool) : Bool
	{
		auto_repeat_ = value;
		return value;
	}
//.............................................................................
	override public function draw() : Void
	{
		//if (1100101 == tag_)
			//trace("***");
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SKIN | Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			graphics.clear();
			if (dummy_alpha_ >= 0)
			{
				var r : Root = Root.instance;
				var cl : Int = dummy_color_;
				var frame : Int = 0;
				if ((state_ & Visel.STATE_DISABLED) != 0)
					cl = r.color_disabled_;
				else
				{
					if ((state_ & Visel.STATE_DOWN) != 0)
						cl = r.color_pressed_;
					if ((state_ & Visel.STATE_HOVER) != 0)
						frame = r.hover_inflation_;
				}
				graphics.beginFill(cl, dummy_alpha_);
				graphics.drawRect(-frame, -frame, width_ + 2 * frame, height_ + 2 * frame);
				graphics.endFill();
			}
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			if ((state_ & Visel.STATE_DOWN) != 0)
			{
				label_.movesize_(content_down_offset_x_, content_down_offset_y_,
						width_ + content_down_offset_x_, height_ + content_down_offset_y_);
			}
			else
			{
				label_.movesize_(0, 0, width_, height_);
			}
			label_.draw();
			label_.validate();
		}
	}
//.............................................................................
	private function add_Mouse_Listeners() : Void
	{
		addEventListener(MouseEvent.CLICK, on_Mouse_Click, false, 0, true);
		addEventListener(MouseEvent.ROLL_OVER, on_Mouse_Over, false, 0, true);
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down, false, 0, true);
	}
//.............................................................................
	private function on_Mouse_Down(e : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;
		e.stopPropagation();
		invalidate(Visel.INVALIDATION_FLAG_STATE);
		stage.addEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage, false, 1);  //:set capture
		if (auto_repeat_)
		{
			repeat_count_ = 0;
			repeat_time_ = Lib.getTimer() + repeat_delay_;
			repeat_event_ = e.clone();
			repeat_button_ = this;
			Root.instance.frame_signal_.add(on_Enter_Frame);
		}
		//:touch another button
		else
		{
			repeat_button_ = null;
		}
	}
//.............................................................................
	private function on_Mouse_Up_Stage(e : MouseEvent) : Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage);
		if ((state_ & Visel.STATE_DISPOSED) != 0)
			return;
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			state_ &= ~Visel.STATE_DOWN;
			invalidate(Visel.INVALIDATION_FLAG_STATE);
		}
	}
//.............................................................................
	private function on_Mouse_Over(e : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_HOVER) != 0)
			return;
		state_ |= Visel.STATE_HOVER;
		invalidate(Visel.INVALIDATION_FLAG_STATE);
		addEventListener(MouseEvent.ROLL_OUT, on_Mouse_Out, false, 0, true);
	}
//.............................................................................
	private function on_Mouse_Out(e : MouseEvent) : Void
	{
		state_ &= ~Visel.STATE_HOVER;
		invalidate(Visel.INVALIDATION_FLAG_STATE);
		removeEventListener(MouseEvent.ROLL_OUT, on_Mouse_Out);
	}
//.............................................................................
	private function on_Mouse_Click(e : MouseEvent) : Void
	{
		//trace("button::click '" + label_.text + "', target=" + e.target);
		//trace("_______");
		e.stopPropagation();
		if (on_click_ != null)
			on_click_(e);
	}
//.............................................................................
	private function on_Enter_Frame() : Void
	{
		if (auto_repeat_ && ((state_ & (Visel.STATE_DOWN | Visel.STATE_DISPOSED | Visel.STATE_DISABLED)) == Visel.STATE_DOWN) &&
			(this == repeat_button_))
		{
			var time : Int = Lib.getTimer();
			if (time - repeat_time_ >= 0)
			{
				++repeat_count_;
				var delay : Int = repeat_delay_;
				delay = Std.int(delay / repeat_count_);
				if (delay < 50)
				{
					delay = 50;
				}
				repeat_time_ = time + delay;
				if (on_click_ != null)
					on_click_(repeat_event_);
			}
			return;
		}
		if (this == repeat_button_)
			repeat_button_ = null;
		repeat_event_ = null;
		Root.instance.frame_signal_.remove(on_Enter_Frame);
	}
}

