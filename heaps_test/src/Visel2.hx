package;

import h2d.Graphics;
import h2d.Interactive;
import h2d.Sprite;

class Visel2 extends Graphics
{
	public var enabled(get, set) : Bool;
	public var disposed(get, never) : Bool;
	//public var dummy_color(get, set) : Int;
	//public var dummy_alpha(get, set) : Float;

	private var width_ : Float = 0;
	private var height_ : Float = 0;
	private var state_ : Int = 0;
	private var invalid_flags_ : Int = 0;

	public static inline var STATE_DISPOSED : Int	= 1;
	public static inline var STATE_DISABLED : Int	= 2;
	public static inline var STATE_HOVER : Int		= 4;
	public static inline var STATE_DOWN : Int		= 8;
	public static inline var STATE_ACTIVE : Int		= 0x10;
	public static inline var STATE_DRAG : Int		= 0x20;

	public static inline var INVALIDATION_FLAG_SIZE : Int		= 1;
	public static inline var INVALIDATION_FLAG_STATE : Int		= 2;
	public static inline var INVALIDATION_FLAG_SKIN : Int		= 4;
	public static inline var INVALIDATION_FLAG_ALIGN : Int		= 8;
	public static inline var INVALIDATION_FLAG_SCROLL : Int		= 0x10;
	public static inline var INVALIDATION_FLAG_HISTORY : Int	= 0x20;
	public static inline var INVALIDATION_FLAG_DATA : Int		= 0x40;
	public static inline var INVALIDATION_FLAG_DATA2 : Int		= 0x80;
	public static inline var INVALIDATION_FLAG_STAGE_SIZE : Int	= 0x100;
	public static inline var INVALIDATION_FLAG_ALL : Int		= ~0;

	public var dummy_color_ : Int = 0;
	public var dummy_alpha_ : Float = -1;
	public var tag_ : Int = 0;

	public function new(?parent:Sprite)
	{
		super(parent);
	}
//.............................................................................
	public function destroy() : Void
	{
		if (disposed)
			return;
		state_ |= STATE_DISPOSED;
		//?destroy_Children();
		remove();
	}
//.............................................................................
//openfl::DisplayObject have public function invalidate ():Void
	public function invalidate_Visel(flags : Int) : Void
	{
		if (disposed)
			return;
		if (0 == flags)
			return;
		if (0 == invalid_flags_)
			Root2.instance.frame_signal_.add(on_Invalidate);
		invalid_flags_ |= flags;
	}
//.............................................................................
	private function on_Invalidate() : Void
	{
		Root2.instance.frame_signal_.remove(on_Invalidate);
		if (disposed)
			return;
		draw_Visel();
		validate_Visel();
	}
//.............................................................................
	private inline function get_disposed() : Bool
	{
		return (state_ & STATE_DISPOSED) != 0;
	}
//.............................................................................
	private inline function get_enabled() : Bool
	{
		return (state_ & STATE_DISABLED) == 0;
	}
	private function set_enabled(value : Bool) : Bool
	{
		if (enabled != value)
		{
			if (value)
				state_ &= ~STATE_DISABLED;
			else
				state_ |= STATE_DISABLED;
			//TODO fix me: Interactive
			invalidate_Visel(INVALIDATION_FLAG_STATE);
		}
		return value;
	}
//.............................................................................
//.............................................................................
	public function validate_Visel() : Void
	{
		invalid_flags_ = 0;
	}
//.............................................................................
	public function draw_Visel() : Void
	{
		//trace("draw_Visel");
		if ((invalid_flags_ & (INVALIDATION_FLAG_SKIN | INVALIDATION_FLAG_SIZE | INVALIDATION_FLAG_STATE)) != 0)
		{
			clear();
			if ((dummy_alpha_ >= 0) && (width_ > 0) && (height_ > 0))
			{
				beginFill(dummy_color_ & 0xffffff, dummy_alpha_);
				drawRect(0, 0, width_, height_);
			}
		}
	}
//.............................................................................
	public function resize(w : Float, h : Float) : Void
	{
		if (w < 0)
			w = 0;
		if (h < 0)
			h = 0;
		if ((width_ != w) || (height_ != h))
		{
			width_ = w;
			height_ = h;
			invalidate_Visel(INVALIDATION_FLAG_SIZE);
		}
	}
//.............................................................................
}