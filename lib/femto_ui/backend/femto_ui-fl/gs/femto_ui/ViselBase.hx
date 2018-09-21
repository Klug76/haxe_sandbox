package gs.femto_ui;

import flash.Lib;
import flash.display.Graphics;
import flash.display.Sprite;

/*
Sprite -> DisplayObjectContainer -> InteractiveObject -> DisplayObject -> EventDispatcher -> Object
*/
using gs.femto_ui.RootBase.NativeUIContainer;
//.............................................................................
class ViselBase extends Sprite
{
	private var width_ : Float = 0;
	private var height_ : Float = 0;

	public function new(?owner : NativeUIContainer)
	{
		super();
		if (owner != null)
			owner.addChild(this);
	}
//.............................................................................
//.............................................................................
	inline private function destroy_Base() : Void
	{
		destroy_Children();
		if (parent != null)
			parent.removeChild(this);
	}
//.............................................................................
	public function destroy_Children() : Void
	{
		var i : Int = numChildren - 1;
		while (i >= 0)
		{
			var od = getChildAt(i);
			if (od != null)
			{
				var child : Visel = Lib.as(od, Visel);
				if (child != null)
				{
					child.destroy_Visel();
				}
				else
				{
					removeChildAt(i);
				}
			}
			--i;
		}
	}
//.............................................................................
	public function add_Child(v: Visel): Void
	{
		addChild(v);
	}
//.............................................................................
//.............................................................................
	#if flash @:keep @:getter(width) #else override #end
	private function get_width() : Float
	{
		return width_;
	}
	#if flash @:keep @:setter(width) #else override #end
	private function set_width(value : Float) : #if flash Void #else Float #end
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
		#if (!flash) return value; #end
	}
//.............................................................................
	#if flash @:keep @:getter(height) #else override #end
	private function get_height() : Float
	{
		return height_;
	}
	#if flash @:keep @:setter(height) #else override #end
	private function set_height(value : Float) : #if flash Void #else Float #end
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
		#if (!flash) return value; #end
	}
//.............................................................................
//.............................................................................
	#if flash @:keep @:setter(visible) #else override #end
	private function set_visible(value : Bool) : #if flash Void #else Bool #end
	{
		if (super.visible != value)
		{
			super.visible = value;
			var v: Visel = cast this;
			if (value)
				v.on_Show();
			else
				v.on_Hide();
		}
		#if (!flash) return value; #end
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	inline private function draw_Base() : Void
	{
		var v: Visel = cast this;
		if ((v.invalid_flags_ & (Visel.INVALIDATION_FLAG_SKIN | Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			var gr: Graphics = v.graphics;
			gr.clear();
			if ((v.dummy_alpha_ >= 0) && (v.width_ > 0) && (v.height_ > 0))
			{
				gr.beginFill(v.dummy_color_ & 0xffffff, v.dummy_alpha_);
				gr.drawRect(0, 0, v.width_, v.height_);
				gr.endFill();
			}
		}
	}
//.............................................................................
//.............................................................................
	inline private function enable_Base(value : Bool): Void
	{
		mouseEnabled = value;
		mouseChildren = value;
	}
//.............................................................................
//.............................................................................
	public function bring_To_Top() : Void
	{
		if (parent != null)
			parent.addChild(this);
	}
//.............................................................................
//.............................................................................
}
