package gs.femto_ui;

import gs.femto_ui.kha.Event;
import gs.femto_ui.Visel;
import gs.femto_ui.util.Util;
import kha.graphics2.Graphics;

class ViselBase
{
	private var parent_: Visel = null;
	private var child_: Array<Visel> = new Array<Visel>();
	private var x_: Float = 0;
	private var y_: Float = 0;
	private var width_: Float = 0;
	private var height_: Float = 0;
	private var listeners_: Array<Event->Void> = null;

	public var name(default, default): String = null;
	public var alpha(default, default): Float = 1.;
	public var hit_test_bits(default, default): Int = HIT_TEST_AUTO;//:RECT & CHILDREN

	public static inline var HIT_TEST_AUTO: Int		= 0;
	public static inline var HIT_TEST_NONE: Int		= 1;
	public static inline var HIT_TEST_FUNC: Int		= 2;
	public static inline var HIT_TEST_CHILDREN: Int	= 4;

	public function new(?owner: Visel)
	{
		if (owner != null)
			owner.add_Child(cast this);
	}
//.............................................................................
	private function init_Base() : Void
	{}
//.............................................................................
	private function destroy_Base() : Void
	{
		var v: Visel = cast this;
		remove_Children();
		if (parent_ != null)
		{
			parent_.remove_Child(v);
			parent_ = null;
		}
		if (listeners_ != null)
		{
			listeners_.resize(0);
			listeners_ = null;
		}
	}
//.............................................................................
	inline public function add_Child(v: Visel): Visel
	{
		return add_Child_At(v, child_.length);
	}
//.............................................................................
	inline public function add_Child_At(v: Visel, idx: Int) : Visel
	{
		if (v.parent_ == cast this)
		{
			set_Child_Index(v, idx);
			return v;
		}
		child_.insert(idx, v);
		v.parent_ = cast this;
		return v;
	}
//.............................................................................
	public var parent(get, never): Visel;
	inline private function get_parent(): Visel
	{
		return parent_;
	}
//.............................................................................
	public var num_Children(get, never): Int;
	inline private function get_num_Children(): Int
	{
		return child_.length;
	}
//.............................................................................
	inline public function get_Child_At(idx: Int): Visel
	{
		return child_[idx];
	}
//.............................................................................
	inline public function get_Child_As<T>(idx: Int, c : Class<T>): Null<T>
	{
		var v = child_[idx];
		if (Std.is(v, c))
			return cast v;
		return null;
	}
//.............................................................................
	inline public function get_Child_Index(v: Visel) : Int
	{
		return child_.indexOf(v);
	}
//.............................................................................
	inline public function set_Child_Index(v: Visel, idx: Int) : Void
	{
		var old: Int = get_Child_Index(v);
		if (old == idx)
			return;
		child_.remove(v);//TODO: need 4 removeAt
		child_.insert(idx, v);
	}
//.............................................................................
	inline public function remove_Child(v: Visel): Void
	{
		if (v.parent_ == this)//TODO assert
		{
			v.parent_ = null;
			child_.remove(v);
			v.destroy_Visel();
		}
	}
//.............................................................................
	inline public function remove_Child_At(idx: Int) : Void
	{
		var ch: Visel = child_[idx];
		remove_Child(ch);//TODO: need 4 removeAt
	}
//.............................................................................
	public function remove_Children() : Void
	{
		while( num_Children > 0 )
			remove_Child(get_Child_At(0));
	}
//.............................................................................
//.............................................................................
//.............................................................................
	public var x(get, set): Float;
	inline private function get_x() : Float
	{
		return x_;
	}
	private function set_x(value : Float) : Float
	{
		x_ = value;
		var v: Visel = cast this;
		v.explicit_x_ = value;
		return value;
	}
//.............................................................................
	public var y(get, set): Float;
	inline private function get_y() : Float
	{
		return y_;
	}
	private function set_y(value : Float) : Float
	{
		y_ = value;
		var v: Visel = cast this;
		v.explicit_y_ = value;
		return value;
	}
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
	public function movesize_Base(nx : Float, ny : Float, w : Float, h : Float): Void
	{//:keep explicit values
		x_ = nx;
		y_ = ny;
		if (w < 0)
			w = 0;
		if (h < 0)
			h = 0;
		if ((width_ != w) || (height_ != h))
		{
			width_ = w;
			height_ = h;
			var v: Visel = cast this;
			v.invalidate_Visel(Visel.INVALIDATION_FLAG_SIZE);
		}
	}
//.............................................................................
//.............................................................................
	inline private function draw_Base(): Void
	{
		//:nop
	}
//.............................................................................
	public function render_To(gr: Graphics, nx: Float, ny: Float) : Void
	{
		if (!visible)
			return;
		var old = gr.opacity;
		gr.opacity = old * alpha;
		render_Base(gr, nx + x, ny + y);
		gr.opacity = old;
	}
//.............................................................................
	private function render_Base(gr: Graphics, nx: Float, ny: Float) : Void
	{
		render_Base_Background(gr, nx, ny);
		render_Children(gr, nx, ny);
	}
//.............................................................................
	private function render_Base_Background(gr: Graphics, nx: Float, ny: Float) : Void
	{
		var v: Visel = cast this;
		var nw : Float = width_;
		var nh : Float = height_;
		var al = v.dummy_alpha_;
		if ((al > 0) && (nw > 0) && (nh > 0))
		{
			gr.color = Util.RGB_A(v.dummy_color_, al);
			gr.fillRect(nx, ny, nw, nh);
		}
	}
//.............................................................................
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
//.............................................................................
	private function hit_Test(globalX: Float, globalY: Float, nx: Float, ny: Float): Bool
	{
		return  (globalX >= nx) && (globalX < (nx + width_)) &&
				(globalY >= ny) && (globalY < (ny + height_));
	}
//.............................................................................
	private function find_Event_Target(ev: Event, nx: Float, ny: Float): Visel
	{
		var v: Visel = cast this;
		if (!v.visible || !v.enabled)
			return null;
		var h: Int = hit_test_bits;
		switch (h)
		{
		case HIT_TEST_AUTO:
			h = HIT_TEST_FUNC | HIT_TEST_CHILDREN;
		case HIT_TEST_NONE:
			return null;
		}
		nx += x;
		ny += y;
		if ((h & HIT_TEST_FUNC) != 0)
		{
			if (!hit_Test(ev.globalX, ev.globalY, nx, ny))
				return null;
		}
		if ((h & HIT_TEST_CHILDREN) != 0)
		{
			var len: Int = child_.length;
			for (i in 0...len)
			{
				var idx: Int = len - i - 1;
				var c: Visel = child_[idx];
				var cv: Visel = c.find_Event_Target(ev, nx, ny);
				if (cv != null)
					return cv;
			}
			//?return null;
		}
		if ((h & HIT_TEST_FUNC) != 0)
		{
			ev.targetX = ev.globalX - nx;
			ev.targetY = ev.globalY - ny;
			return v;//:test passed above
		}
		return null;
	}
//.............................................................................
//.............................................................................
	inline private function enable_Base(value : Bool): Void
	{
		//:nop
	}
//.............................................................................
	public function bring_To_Top() : Void
	{
		if (parent_ != null)
			parent_.add_Child(cast this);
	}
//.............................................................................
//.............................................................................
	public function add_Listener(f: Event->Void): Void
	{
		if (null == listeners_)
			listeners_ = [];
		//TODO check for dups?
		listeners_.push(f);
	}
//.............................................................................
	public function remove_Listener(f: Event->Void): Void
	{
		if (null == listeners_)
			return;
		for (il in listeners_)
		{
			if (Reflect.compareMethods(il, f))
			{
				listeners_.remove(il);
				return;
			}
		}
	}
//.............................................................................
	private function has_Listeners(): Bool
	{
		return (listeners_ != null) && (listeners_.length > 0);
	}
//.............................................................................
	private function dispatch_Event(ev: Event): Void
	{
		//if (ev.type != Event.MOUSE_MOVE)
			//trace("dispatch_Event " + ev.dump() + " at " + this.dump() + ", phase=" + ev.dump_Phase());
		if (!has_Listeners())
			return;
		//TODO fix me: re-enter, add/remove inside for
		for (il in listeners_)
		{
			il(ev);
			if (ev.stop_propagation)
				break;
		}
	}
//.............................................................................
#if debug
	public function dump(): String
	{
		var s: String = Std.string(this);
		s += ": " + name;
		s += ": " + x + ": " + y;
		s += ": visible=" + visible;
		return s;
	}
#end
}