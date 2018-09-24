package gs.femto_ui;

import gs.femto_ui.Visel;
import kha.Color;
import kha.graphics2.Graphics;

class ViselBase
{
	private var parent_: Visel = null;
	private var child_: Array<Visel> = new Array<Visel>();
	private var last_x_: Float = 0;
	private var last_y_: Float = 0;
	private var width_: Float = 0;
	private var height_: Float = 0;

	public var name(default, default): String = null;

	public function new(?owner: Visel)
	{
		if (owner != null)
			owner.add_Child(cast this);
	}
//.............................................................................
	public function add_Child(v: Visel): Void
	{
		add_Child_At(v, child_.length);
	}
//.............................................................................
	public function add_Child_At(v: Visel, idx: Int) : Void
	{
		if (v.parent_ == cast this)
		{
			set_Child_Index(v, idx);
			return;
		}
		child_.insert(idx, v);
		v.parent_ = cast this;
	}
//.............................................................................
	public var num_Children(get, never): Int;
	private function get_num_Children(): Int
	{
		return child_.length;
	}
//.............................................................................
	public function get_Child_As<T>(idx: Int, c : Class<T>): Null<T>
	{
		var v = child_[idx];
		if (Std.is(v, c))
			return cast v;
		return null;
	}
//.............................................................................
	public function get_Child_Index(v: Visel) : Int
	{
		return child_.indexOf(v);
	}
//.............................................................................
	public function set_Child_Index(v: Visel, idx: Int) : Void
	{
		var old: Int = get_Child_Index(v);
		if (old == idx)
			return;
		child_.remove(v);//TODO: need 4 removeAt
		child_.insert(idx, v);
	}
//.............................................................................
	public function remove_Child(v: Visel): Void
	{
		if (v.parent_ == this)
		{
			v.parent_ = null;
			child_.remove(v);
		}
	}
//.............................................................................
	inline private function destroy_Base() : Void
	{
		if (parent_ != null)
			parent_.remove_Child(cast this);
	}
//.............................................................................
	public var x(default, default): Float;
	public var y(default, default): Float;
//.............................................................................
//.............................................................................
//.............................................................................
	public var width(get, set): Float;
	inline private function get_width() : Float
	{
		return width_;
	}
//.............................................................................
	private function set_width(value : Float) : Float
	{
		var w: Float = value;
		if (w < 0)
			w = 0;
		if (width_ != w)
		{
			width_ = w;
			var v: Visel = cast this;
			v.invalidate_Visel(Visel.INVALIDATION_FLAG_SIZE);
		}
		return value;
	}
//.............................................................................
	public var height(get, set): Float;
	inline private function get_height() : Float
	{
		return height_;
	}
//.............................................................................
	private function set_height(value : Float) : Float
	{
		var h: Float = value;
		if (h < 0)
			h = 0;
		if (height_ != h)
		{
			height_ = h;
			var v: Visel = cast this;
			v.invalidate_Visel(Visel.INVALIDATION_FLAG_SIZE);
		}
		return value;
	}
//.............................................................................
	public var visible(default, set): Bool = true;
	public function set_visible(value: Bool): Bool
	{
		if (visible != value)
		{
			visible = value;
			var v: Visel = cast this;
			if (value)
				v.on_Show();
			else
				v.on_Hide();
		}
		return value;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	inline private function draw_Base(): Void
	{}
//.............................................................................
	public function render_To(gr: Graphics, nx: Float, ny: Float) : Void
	{
		if (!visible)
			return;
		nx += x;
		ny += y;
		update_Last_Coords(nx, ny);
		render_Base(gr, nx, ny);
		render_Children(gr, nx, ny);
		return;
	}
//.............................................................................
	private function render_Base(gr: Graphics, nx: Float, ny: Float) : Void
	{
		var v: Visel = cast this;
		var al = v.dummy_alpha_;
		if ((al > 0) && (width_ > 0) && (height_ > 0))
		{
			var cl: Color = v.dummy_color_;
			cl.A = al;
			gr.color = cl;
			gr.fillRect(nx, ny, width_, height_);
		}
	}
//.............................................................................
	private function render_Children(gr: Graphics, nx: Float, ny: Float) : Void
	{
		for (c in child_)
		{
			c.render_To(gr, nx, ny);
		}
	}
//.............................................................................
//.............................................................................
	private function update_Last_Coords(nx: Float, ny: Float) : Void
	{
		last_x_ = nx;
		last_y_ = ny;
	}
//.............................................................................
	private function hit_Test(nx: Float, ny: Float): Bool
	{
		return visible &&
			(nx >= last_x_) && (nx < (last_x_ + width_)) &&
			(ny >= last_y_) && (ny < (last_y_ + height_));
	}
//.............................................................................
//.............................................................................
	inline private function enable_Base(value : Bool): Void
	{

	}
//.............................................................................
	public function bring_To_Top() : Void
	{
		if (parent_ != null)
			parent_.add_Child_At(cast this, 0);
	}
//.............................................................................
}