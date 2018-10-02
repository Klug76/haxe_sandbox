package gs.femto_ui;

using gs.femto_ui.RootBase.NativeUIContainer;
//.............................................................................
@:allow(gs.femto_ui.ViselBase)
class Visel extends ViselBase
{
	public var enabled(get, set) : Bool;
	public var disposed(get, never) : Bool;
	public var dummy_color(get, set) : Int;
	public var dummy_alpha(get, set) : Float;

	private var explicit_x_: Float = 0;
	private var explicit_y_: Float = 0;
	private var explicit_width_: Float = 0;
	private var explicit_height_: Float = 0;

	private var state_ : Int = 0;
	private var invalid_flags_ : Int = 0;

	public var dummy_color_ : Int = 0;
	public var dummy_alpha_ : Float = -1;
	public var tag_ : Int = 0;

#if debug
	public static var debug_counter_: Int = 0;
#end

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

	public function new(owner : NativeUIContainer)
	{
#if debug
		++debug_counter_;
		//trace("Visel::new(), debug_counter=" + debug_counter_);
#end
		super(owner);
		init_Base();
	}
//.............................................................................
	public function destroy_Visel() : Void
	{
		if (disposed)
			return;
		state_ |= STATE_DISPOSED;
#if debug
		--debug_counter_;
		//trace("~Visel::destroy(), debug_counter=" + debug_counter_);
#end
		destroy_Base();
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
			Root.instance.frame_signal_.add(on_Invalidate);
		invalid_flags_ |= flags;
	}
//.............................................................................
	private function on_Invalidate() : Void
	{
		//trace("Visel::on_Invalidate");
		Root.instance.frame_signal_.remove(on_Invalidate);
		if (disposed)
			return;
		draw_Visel();
		validate_Visel();
	}
//.............................................................................
	public function validate_Visel() : Void
	{
		invalid_flags_ = 0;
	}
//.............................................................................
//.............................................................................
	public function move_Visel(nx : Float, ny : Float) : Void
	{
		x = nx;
		y = ny;
	}
//.............................................................................
	public function resize_Visel(w : Float, h : Float) : Void
	{
		if (w < 0)
			w = 0;
		if (h < 0)
			h = 0;
		if ((width_ != w) || (height_ != h))
		{
			width_ = w;
			explicit_width_ = w;
			height_ = h;
			explicit_height_ = h;
			invalidate_Visel(INVALIDATION_FLAG_SIZE);
		}
	}
//.............................................................................
	public function resize_(w : Float, h : Float) : Void
	{
		if (w < 0)
			w = 0;
		if (h < 0)
			h = 0;
		if ((width_ != w) || (height_ != h))
		{
			width_ = w;
			explicit_width_ = w;
			height_ = h;
			explicit_height_ = h;
			invalid_flags_ |= INVALIDATION_FLAG_SIZE;
		}
	}
//.............................................................................
	public function movesize(nx : Float, ny : Float, w : Float, h : Float) : Void
	{
		x = nx;
		y = ny;
		resize_Visel(w, h);
	}
//.............................................................................
	public function movesize_(nx : Float, ny : Float, w : Float, h : Float) : Void
	{
		x = nx;
		y = ny;
		resize_(w, h);
	}
//.............................................................................
//.............................................................................
//.............................................................................
	public dynamic function on_Show() : Void
	{}
//.............................................................................
	public dynamic function on_Hide() : Void
	{}
//.............................................................................
//.............................................................................
//.............................................................................
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
			enable_Base(value);
			invalidate_Visel(INVALIDATION_FLAG_STATE);
		}
		return value;
	}
//.............................................................................
//.............................................................................
	public function draw_Visel() : Void
	{
		draw_Base();
		handle_Resize();
	}
//.............................................................................
	private function handle_Resize() : Void
	{
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE)) != 0)
		{
			on_Resize();
		}
	}
//.............................................................................
	public dynamic function on_Resize()
	{}
//.............................................................................
//.............................................................................
	inline private function get_dummy_color() : Int
	{
		return dummy_color_;
	}
	private function set_dummy_color(value : Int) : Int
	{
		if (dummy_color_ != value)
		{
			dummy_color_ = value;
			var a: Int = value >>> 24;
			if (0 == a)
				dummy_alpha_ = 1;
			else
				dummy_alpha_ = a / 255.;
			invalidate_Visel(INVALIDATION_FLAG_SKIN);
		}
		return value;
	}
//.............................................................................
	inline private function get_dummy_alpha() : Float
	{
		return dummy_alpha_;
	}
	private function set_dummy_alpha(value : Float) : Float
	{
		if (dummy_alpha_ != value)
		{
			dummy_alpha_ = value;
			invalidate_Visel(INVALIDATION_FLAG_SKIN);
		}
		return value;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
}
