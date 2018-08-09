package com.gs.femto_ui;

import com.gs.femto_ui.util.Util;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;

class Scrollbar extends Button
{
	public var min(get, set) : Int;
	public var max(get, set) : Int;
	public var value(get, set) : Int;

	private var min_ : Int = 0;
	private var max_ : Int = 10;
	private var value_ : Int = 0;
	private var on_scroll_ : Int->Void;

	public var thumb_ : Thumb;

	public function new(owner : DisplayObjectContainer, callback : Int->Void)
	{
		super(owner, null, on_Area_Click);
		on_scroll_ = callback;
		init_Ex_Ex();
	}
	//.............................................................................
	private function init_Ex_Ex() : Void
	{
		var r : Root = Root.instance;

		auto_repeat_ = true;
		hover_inflation_ = 0;

		thumb_ = new Thumb(this);
		thumb_.width = r.small_tool_width_;
		thumb_.height = r.tool_height_;
		thumb_.dummy_color = r.color_thumb_;

		dummy_color = r.color_scroller_;
	}
	//.............................................................................
	public function reset(mn : Int, mx : Int, cur : Int) : Void
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
		var v : Int = value_;
		if (ny < 0)
			--v;
		else if (ny > thumb_.height)
			++v;
		else
			return;
		set_Value(v);
		invalidate_Visel(Visel.INVALIDATION_FLAG_DATA);
	}
	//.............................................................................
	private function set_Value(v : Int) : Void
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
	private function calc_Value(ny : Float) : Int
	{
		var df : Int = max_ - min_;
		var dh : Float = Math.floor(height_ - thumb_.height);
		if ((df <= 0) || (dh <= 0))
		{
			return value_;
		}
		return Math.round(ny * df / dh + min_);
	}
	//.............................................................................
	private inline function clamp_Value(v : Int) : Int
	{
		return Util.iclamp(v, min_, max_);
	}
	//.............................................................................
	//.............................................................................
	//.............................................................................
	//.............................................................................
	private function get_min() : Int
	{
		return min_;
	}
	//.............................................................................
	private function set_min(value : Int) : Int
	{
		if (min_ != value)
		{
			min_ = value;
			invalidate_Visel(Visel.INVALIDATION_FLAG_DATA);
		}
		return value;
	}
	//.............................................................................
	private function get_max() : Int
	{
		return max_;
	}
	//.............................................................................
	private function set_max(value : Int) : Int
	{
		if (max_ != value)
		{
			max_ = value;
			invalidate_Visel(Visel.INVALIDATION_FLAG_DATA);
		}
		return value;
	}
	//.............................................................................
	private function get_value() : Int
	{
		return value_;
	}
	//.............................................................................
	private function set_value(value : Int) : Int
	{
		if (value_ != value)
		{
			value_ = value;
			invalidate_Visel(Visel.INVALIDATION_FLAG_DATA);
		}
		return value;
	}
	//.............................................................................
	//.............................................................................
	override public function draw() : Void
	{
		super.draw();
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_DATA | Visel.INVALIDATION_FLAG_SIZE)) != 0)
		{
			update_Thumb_Position();
		}
	}
	//.............................................................................
	private function update_Thumb_Position() : Void
	{
		if (thumb_.is_drag_mode)
		{
			return;
		}
		//trace("thumb::update pos, val = " + value_);
		var df : Int = max_ - min_;
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
		var v : Int = clamp_Value(calc_Value(thumb_.y));
		var nv : Int = clamp_Value(calc_Value(ny));
		if (v == nv)
		{
			return;
		}
		thumb_.y = ny;
	}
}



