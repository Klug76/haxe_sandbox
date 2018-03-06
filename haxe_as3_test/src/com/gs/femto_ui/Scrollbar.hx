package com.gs.femto_ui;

import com.gs.console.Util;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;

class Scrollbar extends Button
{
	public var min(get, set) : Float;
	public var max(get, set) : Float;
	public var value(get, set) : Float;

	private var min_ : Float = 0;
	private var max_ : Float = 10;
	private var value_ : Float = 0;
	private var on_scroll_ : Float->Void;

	public var thumb_ : Thumb;

	public function new(owner : DisplayObjectContainer, callback : Float->Void)
	{
		super(owner, null, on_Area_Click);
		on_scroll_ = callback;
		create_Thumb();
	}
	//.............................................................................
	private function create_Thumb() : Void
	{
		var r : Root = Root.instance;

		hover_inflation_ = 0;
		auto_repeat_ = true;

		thumb_ = new Thumb(this);
		thumb_.width = r.small_tool_width_;
		thumb_.height = r.tool_height_;
		thumb_.dummy_color = 0x008000;
	}
	//.............................................................................
	public function reset(mn : Float, mx : Float, cur : Float) : Void
	{
		min_ = mn;
		max_ = mx;
		value_ = cur;
	}
	//.............................................................................
	//.............................................................................
	private function on_Area_Click(e : MouseEvent) : Void
	{
		if (thumb_.is_drag_mode)
		{
			return;
		}
		var ny : Float = thumb_.mouseY;
		var v : Float = value_;
		if (ny < 0)
		{
			--v;
		}
		else if (ny > thumb_.height)
		{
			++v;
		}
		else
		{
			return;
		}
		set_Value(v);
		invalidate(Visel.INVALIDATION_FLAG_DATA);
	}
	//.............................................................................
	private function set_Value(v : Float) : Void
	{
		v = clamp_Value(v);
		if (value_ != v)
		{
			value_ = v;
			on_scroll_(v);
		}
	}
	//.............................................................................
	//.............................................................................
	//.............................................................................
	//.............................................................................
	public function on_Thumb_Do_Drag() : Void
	{
		set_Value(calc_Value(thumb_.y));
	}
	//.............................................................................
	public function on_Thumb_Finish_Drag() : Void
	//trace("thumb::finish drag");
	{

		on_scroll_(-1);
	}
	//.............................................................................
	private function calc_Value(ny : Float) : Float
	{
		var df : Float = max_ - min_;
		var dh : Float = Math.floor(height_ - thumb_.height);
		if ((df <= 0) || (dh <= 0))
		{
			return value_;
		}
		return Math.round(ny * df / dh + min_);
	}
	//.............................................................................
	private function clamp_Value(v : Float) : Float
	{
		return Util.fclamp(v, min_, max_);
	}
	//.............................................................................
	//.............................................................................
	//.............................................................................
	//.............................................................................
	private function get_min() : Float
	{
		return min_;
	}
	//.............................................................................
	private function set_min(value : Float) : Float
	{
		if (min_ != value)
		{
			min_ = value;
			invalidate(Visel.INVALIDATION_FLAG_DATA);
		}
		return value;
	}
	//.............................................................................
	private function get_max() : Float
	{
		return max_;
	}
	//.............................................................................
	private function set_max(value : Float) : Float
	{
		if (max_ != value)
		{
			max_ = value;
			invalidate(Visel.INVALIDATION_FLAG_DATA);
		}
		return value;
	}
	//.............................................................................
	private function get_value() : Float
	{
		return value_;
	}
	//.............................................................................
	private function set_value(value : Float) : Float
	{
		if (value_ != value)
		{
			value_ = value;
			invalidate(Visel.INVALIDATION_FLAG_DATA);
		}
		return value;
	}
	//.............................................................................
	//.............................................................................
	override public function draw() : Void
	{
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_DATA | Visel.INVALIDATION_FLAG_SIZE)) != 0)
		{
			update_Thumb_Position();
		}
		super.draw();
	}
	//.............................................................................
	private function update_Thumb_Position() : Void
	{
		if (thumb_.is_drag_mode)
		{
			return;
		}
		//trace("thumb::update pos, val = " + value_);
		var df : Float = max_ - min_;
		var dh : Float = Math.floor(height_ - thumb_.height);
		if ((df <= 0) || (dh <= 0) || (value_ == min_))
		{
			thumb_.y = 0;
			return;
		}
		if (value_ == max_)
		{
			thumb_.y = dh;
			return;
		}
		//:calc pos
		var ny : Float = Util.fclamp(Math.round((value_ - min_) * dh / df), 0, dh);
		//:move if new y will change value
		var v : Float = clamp_Value(calc_Value(thumb_.y));
		var nv : Float = clamp_Value(calc_Value(ny));
		if (v == nv)
		{
			return;
		}
		thumb_.y = ny;
	}
}



