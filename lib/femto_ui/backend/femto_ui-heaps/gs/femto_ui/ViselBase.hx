package gs.femto_ui;

import h2d.Graphics;
import h2d.Interactive;
import h2d.Sprite;

using gs.femto_ui.RootBase.NativeUIContainer;

class ViselBase extends Sprite
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
//.............................................................................
	inline private function destroy_Base() : Void
	{
		remove();//:will destroy children
		background_ = null;
	}
//.............................................................................
	override function onRemove()
	{
		//trace("Visel::on_Remove()");
		var v: Visel = cast this;
		v.destroy_Visel();
		super.onRemove();
	}
//.............................................................................
	public function add_Child(v: Visel): Void
	{
		addChild(v);
	}
//.............................................................................
	override function addChildAt(s, pos)
	{
		if (background_ != null)
			++pos;
		super.addChildAt(s, pos);
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
	inline private function draw_Base() : Void
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
			var cl = v.dummy_color_ & 0xFFffFF;
			var al = v.dummy_alpha_;
			if ((al >= 0) && (v.width_ > 0) && (v.height_ > 0))
			{
				alloc_Background();
				var bg = background_;
				bg.clear();
				bg.beginFill(v.dummy_color_ & 0xffffff, v.dummy_alpha_);
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
//.............................................................................
//.............................................................................
	private function alloc_Background(): Void
	{
		if (background_ != null)
			return;
		var bg = new Graphics(this);
		addChildAt(bg, 0);
		background_ = bg;
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
	private function alloc_Interactive(): Void
	{
		if (interactive_ != null)
			return;
		interactive_ = new Interactive(width_, height_, this);
		interactive_.propagateEvents = true;
		enable_interactive_ = true;
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