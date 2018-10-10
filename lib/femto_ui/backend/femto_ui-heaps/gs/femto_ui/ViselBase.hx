package gs.femto_ui;

import h2d.Graphics;
import h2d.Object;
import h2d.Interactive;
import hxd.Cursor;

using gs.femto_ui.RootBase.NativeUIObject;
using gs.femto_ui.RootBase.NativeUIContainer;

class ViselBase extends Object
{
	private var width_ : Float = 0;
	private var height_ : Float = 0;

	private var background_: Graphics = null;
	private var interactive_: Interactive = null;

	private var enable_interactive_: Bool = false;

	public function new(?owner: NativeUIContainer)
	{
		super(owner);
	}
//.............................................................................
	private function init_Base() : Void
	{}
//.............................................................................
	private function destroy_Base() : Void
	{
		background_ = null;
		interactive_ = null;
		remove_Children();//:will destroy background_, interactive_
		remove();
	}
//.............................................................................
//.............................................................................
	public function remove_Children() : Void
	{
		var idx: Int = 0;
		if (background_ != null)
			++idx;
		if (interactive_ != null)
			++idx;
		while ( numChildren > idx )
			remove_Child( getChildAt(idx) );
	}
//.............................................................................
	inline public function remove_Child(od: NativeUIObject) : Void
	{
		removeChild(od);
		if (Std.is(od, Visel))
		{
			var v: Visel = cast od;
			v.destroy_Visel();
		}
	}
//.............................................................................
	inline public function remove_Child_At(idx: Int) : Void
	{
		var od: NativeUIObject = get_Child_At(idx);
		od.remove();
		if (Std.is(od, Visel))
		{
			var v: Visel = cast od;
			v.destroy_Visel();
		}
	}
//.............................................................................
	inline public function add_Child(v: NativeUIObject): NativeUIObject
	{
		addChild(v);
		return v;
	}
//.............................................................................
//.............................................................................
	inline public function add_Child_At(v: NativeUIObject, idx: Int): NativeUIObject
	{
		if (background_ != null)
			++idx;
		if (interactive_ != null)
			++idx;
		addChildAt(v, idx);
		return v;
	}
//.............................................................................
//.............................................................................
	inline public function get_Child_Index(v: NativeUIObject): Int
	{
		var idx = getChildIndex(v);
		if ((background_ != null) && (idx > 0))
			--idx;
		if ((interactive_ != null) && (idx > 0))
			--idx;
		return idx;
	}
//.............................................................................
	public var num_Children(get, never): Int;
	inline private function get_num_Children(): Int
	{
		var result: Int = numChildren;
		if (background_ != null)
			--result;
		if (interactive_ != null)
			--result;
		return result;
	}
//.............................................................................
	inline public function get_Child_At(idx: Int): NativeUIObject
	{
		if (background_ != null)
			++idx;
		if (interactive_ != null)
			++idx;
		return getChildAt(idx);
	}
//.............................................................................
	inline public function get_Child_As<T>(idx: Int, c : Class<T>): Null<T>
	{
		var v = get_Child_At(idx);
		if (Std.is(v, c))
			return cast v;
		return null;
	}
//.............................................................................
//.............................................................................
//.............................................................................
	override function set_x(value)
	{
		super.x = value;
		var v: Visel = cast this;
		v.explicit_x_ = value;
		return value;
	}
	override function set_y(value)
	{
		super.y = value;
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
			v.explicit_width_ = w;
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
			v.explicit_height_ = h;
			v.invalidate_Visel(Visel.INVALIDATION_FLAG_SIZE);
		}
		return value;
	}
//.............................................................................
	public function movesize_Base(nx : Float, ny : Float, w : Float, h : Float): Void
	{//:keep explicit values
		super.x = nx;
		super.y = ny;
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
//.............................................................................
//.............................................................................
	override function set_visible(value)
	{
		if (visible != value)
		{
			super.set_visible(value);
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
	private function draw_Base() : Void
	{
		draw_Base_Background();
		draw_Interactive();
	}
//.............................................................................
	private function draw_Base_Background() : Void
	{
		var v: Visel = cast this;
		if ((v.invalid_flags_ & (Visel.INVALIDATION_FLAG_SKIN | Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			var al = v.dummy_alpha_;
			if ((al > 0) && (v.width_ > 0) && (v.height_ > 0))
			{
				var cl = v.dummy_color_ & 0xFFffFF;
				var bg = alloc_Background();
				bg.clear();
				bg.beginFill(cl, al);
				bg.drawRect(0, 0, v.width_, v.height_);
				bg.endFill();
			}
			else
			{
				clear_Background();
			}
		}
	}
//.............................................................................
	private function draw_Interactive() : Void
	{
		var v: Visel = cast this;
		if ((v.invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
		{
			if (interactive_ != null)
			{
				interactive_.width = Math.round(v.width_);
				interactive_.height = Math.round(v.height_);
			}
		}
	}
//.............................................................................
	private function alloc_Interactive(cursor: Cursor/* = Cursor.Button*/, propagateEvents = false): Interactive
	{
		if (interactive_ != null)
			return interactive_;
		var ni: Interactive = new Interactive(width_, height_);
		ni.cursor = cursor;
		ni.propagateEvents = propagateEvents;
		add_Child_At(ni, 0);
		interactive_ = ni;
		enable_interactive_ = true;
		return ni;
	}
//.............................................................................
	//public function create_Interactive() : Interactive
	//{
		//return alloc_Interactive(Cursor.Button);
	//}
//.............................................................................
//.............................................................................
	private function alloc_Background(): Graphics
	{
		if (background_ != null)
			return background_;
		//trace("Visel::alloc_Background()");
		var bg = new Graphics();
		add_Child_At(bg, 0);
		background_ = bg;
		return bg;
	}
//.............................................................................
	private function clear_Background(): Void
	{
		var bg = background_;
		if (bg != null)
			bg.clear();
	}
//.............................................................................
	private function enable_Base(value : Bool): Void
	{
		enable_interactive_ = value;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public function bring_To_Top() : Void
	{
		if (parent != null)
			parent.addChild(this);
	}
//.............................................................................
}