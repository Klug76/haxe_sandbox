package gs.femto_ui;

import gs.femto_ui.util.Util;

using gs.femto_ui.RootBase.NativeUIContainer;

//TODO direction: horz, vert

class Scrollbar extends Button
{
	public var min(get, set) : Int;
	public var max(get, set) : Int;
	public var value(get, set) : Int;

	private var min_ : Int = 0;
	private var max_ : Int = 10;
	private var value_ : Int = 0;

	public var thumb_ : Thumb;

	public function new(owner : NativeUIContainer, callback : Int->Void)
	{
		super(owner, null, on_Area_Click);
#if debug
		name = "scrollbar";
#end
		init_Scrollbar(callback);
	}
//.............................................................................
	private function init_Scrollbar(callback : Int->Void) : Void
	{
		var r : Root = Root.instance;

		auto_repeat_ = true;
		hover_inflation_ = 0;

		thumb_ = new Thumb(this);
		thumb_.width = r.small_tool_width_;
		thumb_.height = r.tool_height_;
		thumb_.dummy_color = r.color_thumb_;

		dummy_color = r.color_scrollbar_;

		if (callback != null)
			on_Scroll = callback;
	}
//.............................................................................
	public function reset(mn : Int, mx : Int, cur : Int) : Void
	{
		min_ = mn;
		max_ = mx;
		value_ = cur;
		update_State();
	}
//.............................................................................
	public dynamic function on_Scroll(pos: Int): Void
	{}
//.............................................................................
//.............................................................................
	private function update_State(): Void
	{
		if (thumb_.is_drag_mode)
			return;
		enabled =
		thumb_.enabled = max_ > min_;
	}
//.............................................................................
	private function on_Area_Click(ev: InfoClick) : Void
	{
		//trace("scrollbar::on_Area_Click " + ev.global_x_ + ":" + ev.global_y_);
		if (thumb_.is_drag_mode)
			return;
		var ny : Float = ev.local_y_;
		var v : Int = value_;
		if (ny < thumb_.y)
			--v;
		else if (ny >= thumb_.y + thumb_.height)
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
			//trace("scrollbar::set_Value(" + v + ")");
			on_Scroll(v);
		}
	}
//.............................................................................
//.............................................................................
	public function on_Thumb_Do_Drag() : Void
	{
		//trace("thumb::do drag, y=" + thumb_.y);
		set_Value(calc_Value(thumb_.y));
	}
//.............................................................................
	public function on_Thumb_Finish_Drag() : Void
	{
		//trace("thumb::finish drag");
		update_State();
		on_Scroll(min_ - 1);
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
	inline private function get_min() : Int
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
	inline private function get_max() : Int
	{
		return max_;
	}
//.............................................................................
	private function set_max(value : Int) : Int
	{
		if (max_ != value)
		{
			max_ = value;
			update_State();
			invalidate_Visel(Visel.INVALIDATION_FLAG_DATA);
		}
		return value;
	}
//.............................................................................
	inline private function get_value() : Int
	{
		return value_;
	}
//.............................................................................
	private function set_value(value : Int) : Int
	{
		if (value_ != value)
		{
			value_ = value;
			//trace("scrollbar::set value = " + value + ", INVALIDATION_FLAG_DATA");
			invalidate_Visel(Visel.INVALIDATION_FLAG_DATA);
		}
		return value;
	}
//.............................................................................
//.............................................................................
	override public function draw_Visel() : Void
	{
		super.draw_Visel();
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_DATA | Visel.INVALIDATION_FLAG_SIZE)) != 0)
		{
			update_Thumb_Position();
		}
	}
//.............................................................................
	private function update_Thumb_Position() : Void
	{
		if (thumb_.is_drag_mode)
			return;
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
		//trace("thumb::update y " + thumb_.y + " => " + ny);
		thumb_.y = ny;
	}
}



