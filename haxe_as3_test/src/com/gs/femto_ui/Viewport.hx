package com.gs.femto_ui;

import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;

class Viewport extends Visel
{
    public var content(get, set) : Visel;

    private var button_close_ : Button;
    private var mover_ : Mover;
    private var resizer_ : Resizer;
    private var content_ : Visel;
    private var min_content_width_ : Float;
    private var min_content_height_ : Float;

    public function new(owner : DisplayObjectContainer)
    {
        super(owner);
        create_Children();
    }
//.............................................................................
    private function create_Children() : Void
    {
        var r : Root = Root.instance;

        mover_ = new Mover(this);
        //mover_.dummy_alpha_ = 0;

        mover_.resize(r.tool_width_, r.tool_height_);
        mover_.dummy_color = 0xFF0040c0;

        resizer_ = new Resizer(this);
		//resizer_.tag_ = 1100101;
        resizer_.dummy_color = 0xFF0040c0;
        resizer_.resize(r.small_tool_width_, r.small_tool_height_);

        min_content_width_ = r.small_tool_width_;
        min_content_height_ = r.small_tool_height_;

        button_close_ = new Button(this, "x", on_Close_Click);
        button_close_.dummy_color = 0xE6E600;
        button_close_.resize(r.small_tool_width_, r.small_tool_height_);
    }
//.............................................................................
    private function on_Close_Click(e : Event) : Void
    {
        visible = false;
    }
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
    override public function draw() : Void
    {
        if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_DATA)) != 0)
        {
            resizer_.x = width_ - resizer_.width;
            resizer_.y = height_ - resizer_.height;
			//trace("vp::resizer::pos=" + resizer_.x + ":" + resizer_.y + ";size=" + resizer_.width + "x" + resizer_.height);

            button_close_.x = width_ - button_close_.width;
            if (content_ != null)
            {
                var nw : Float = width_ - button_close_.width;
                if (nw < min_content_width_)
                {
                    nw = min_content_width_;
                }
                var nh : Float = height_;
                if (nh < min_content_height_)
                {
                    nh = min_content_height_;
                }
                content_.resize(nw, nh);
                mover_.resize(nw, nh);
            }
        }
        super.draw();
    }
//.............................................................................
    private function get_content() : Visel
    {
        return content_;
    }
//.............................................................................
    private function set_content(value : Visel) : Visel
    {
        if (content_ != null)
        {//:one-shoot
            return value;
        }
        content_ = value;
        min_content_width_ = value.width;
        min_content_height_ = value.height;
        addChildAt(value, 0);
        resizer_.min_width_ = min_content_width_ + Root.instance.small_tool_width_;
        resizer_.min_height_ = min_content_height_;
        invalidate(Visel.INVALIDATION_FLAG_DATA);
        return value;
    }
}
