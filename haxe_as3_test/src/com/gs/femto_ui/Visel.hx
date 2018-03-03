package com.gs.femto_ui;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IEventDispatcher;

/*
	 * 	Sprite -> DisplayObjectContainer -> InteractiveObject -> DisplayObject -> EventDispatcher -> Object
	*/
//.............................................................................
class Visel extends Sprite
{
    public var enabled(get, set) : Bool;
    public var dummy_color(get, set) : Int;

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

    public static inline var INVALIDATION_FLAG_SIZE : Int	= 1;
    public static inline var INVALIDATION_FLAG_STATE : Int	= 2;
    public static inline var INVALIDATION_FLAG_SKIN : Int	= 4;
    public static inline var INVALIDATION_FLAG_DATA : Int	= 8;
    public static inline var INVALIDATION_FLAG_ALIGN : Int	= 0x10;
    public static inline var INVALIDATION_FLAG_SCROLL : Int	= 0x20;
    public static inline var INVALIDATION_FLAG_ALL : Int	= ~0;

    public var dummy_color_ : Int = 0;
    public var dummy_alpha_ : Float = -1;
    public var tag_ : Int = 0;

    public function new(owner : DisplayObjectContainer)
    {
        super();
        create(owner);
    }
//.............................................................................
    private function create(owner : DisplayObjectContainer) : Void
    {
        if (owner != null)
        {
            owner.addChild(this);
        }
    }
//.............................................................................
    public function destroy_Children() : Void
    {
        var i : Int = numChildren - 1;
        while (i >= 0)
        {
            var od : DisplayObject = getChildAt(i);
            if (null == od)
            {
				--i;
                continue;
            }
            var child : Visel = cast od;
            if (child != null)
            {
                child.destroy();
            }
            else
            {
                removeChildAt(i);
            }
            --i;
        }
    }
//.............................................................................
//.............................................................................
    public function destroy() : Void
    {
        if ((state_ & STATE_DISPOSED) != 0)
        {
            return;
        }
        state_ = state_ | STATE_DISPOSED;
        destroy_Children();
        if (parent != null)
        {
            parent.removeChild(this);
        }
    }
//.............................................................................
	public function invalidate(flags : Int) : Void
    {
        if ((state_ & STATE_DISPOSED) != 0)
        {
            return;
        }
        if (0 == invalid_flags_)
        {
			//TODO fix me
            //Root.instance.frame_signal_.add(on_Invalidate);
        }
        invalid_flags_ |= flags;
    }
//.............................................................................
    private function on_Invalidate() : Void
    {
		//TODO fix me:
        //Root.instance.frame_signal_.remove(on_Invalidate);
        if ((state_ & STATE_DISPOSED) != 0)
        {
            return;
        }
        draw();
        validate();
    }
//.............................................................................
    public function validate() : Void
    {
        invalid_flags_ = 0;
    }
//.............................................................................
//.............................................................................
    public function move(nx : Float, ny : Float) : Void
    {
        x = nx;
        y = ny;
    }
//.............................................................................
    public function resize(w : Float, h : Float) : Void
    {
        if (w < 0)
        {
            w = 0;
        }
        if (h < 0)
        {
            w = 0;
        }
        if ((width_ != w) || (height_ != h))
        {
            width_ = w;
            height_ = h;
            invalidate(INVALIDATION_FLAG_SIZE);
        }
    }
//.............................................................................
    public function resize_(w : Float, h : Float) : Void
    {
        if (w < 0)
        {
            w = 0;
        }
        if (h < 0)
        {
            w = 0;
        }
        if ((width_ != w) || (height_ != h))
        {
            width_ = w;
            height_ = h;
            invalid_flags_ |= INVALIDATION_FLAG_SIZE;
        }
    }
//.............................................................................
    public function movesize(nx : Float, ny : Float, w : Float, h : Float) : Void
    {
        x = nx;
        y = ny;
        resize(w, h);
    }
    //.............................................................................
    public function movesize_(nx : Float, ny : Float, w : Float, h : Float) : Void
    {
        x = nx;
        y = ny;
        resize_(w, h);
    }
    //.............................................................................
	#if flash @:keep @:setter(x) #else override #end
    public function set_x(value : Float) : #if flash Void #else Float #end
    {
        super.x = Math.round(value);
		#if (!flash)
		return value;
		#end
    }
    //.............................................................................
	#if flash @:keep @:setter(y) #else override #end
    private function set_y(value : Float) : #if flash Void #else Float #end
    {
        super.y = Math.round(value);
		#if (!flash)
		return value;
		#end
    }
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
        {
            w = 0;
        }
        if (width_ != w)
        {
            width_ = w;
            invalidate(INVALIDATION_FLAG_SIZE);
        }
		#if (!flash)
		return value;
		#end
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
        {
            h = 0;
        }
        if (height_ != h)
        {
            height_ = h;
            invalidate(INVALIDATION_FLAG_SIZE);
        }
		#if (!flash)
		return value;
		#end
    }
    //.............................................................................
    //.............................................................................
    private inline function get_enabled() : Bool
    {
        return (state_ & STATE_DISABLED) == 0;
    }
    private function set_enabled(value : Bool) : Bool
    {
        if (get_enabled() != value)
        {
            if (value)
            {
                state_ &= ~STATE_DISABLED;
            }
            else
            {
                state_ |= STATE_DISABLED;
            }
            mouseEnabled = mouseChildren = value;
            invalidate(INVALIDATION_FLAG_STATE);
        }
        return value;
    }
    //.............................................................................
    //.............................................................................
    //.............................................................................
    //.............................................................................
    //.............................................................................
    private function get_dummy_color() : Int
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
            {
                dummy_alpha_ = 1;
            }
            else
            {
                dummy_alpha_ = a / 255.;
            }
            invalidate(INVALIDATION_FLAG_SKIN);
        }
        return value;
    }
    //.............................................................................
    //.............................................................................
    //.............................................................................
    public function draw() : Void
    {
		//if (1100101 === tag_)
			//trace("ENTER label::super::draw(), ", width_, "x", height_, "flags=0x", invalid_flags_.toString(16));
        if ((invalid_flags_ & (INVALIDATION_FLAG_SKIN | INVALIDATION_FLAG_SIZE | INVALIDATION_FLAG_STATE)) != 0)
        {
            graphics.clear();
            if ((dummy_alpha_ >= 0) && (width_ > 0) && (height_ > 0))
			{
				//if (1100101 === tag_)
					//trace("label::fill(), ", width_, "x", height_, ", color=0x", dummy_color_.toString(16), "a=", dummy_alpha_);
                graphics.beginFill(dummy_color_ & 0xffffff, dummy_alpha_);
                graphics.drawRect(0, 0, width_, height_);
                graphics.endFill();
            }
        }
    }
    //.............................................................................
    //.............................................................................
    //.............................................................................
    public function bring_To_Top() : Void
    {
        if (parent != null)
        {
            parent.addChild(this);
        }
    }
    //.............................................................................
    //.............................................................................
}
