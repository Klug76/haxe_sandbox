package com.gs.femto_ui;

import flash.display.DisplayObjectContainer;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

class Label extends Visel
{
    public var text(get, set) : String;
    public var h_align(get, set) : Int;
    public var v_align(get, set) : Int;

    private var text_ : String = null;
    private var text_field_ : TextField;
    private var align_ : Int = Align.NEAR;
    private var flags_ : Int = 0;
    private var text_size_valid_for_ : Float = 0;
    private var text_width_ : Float = 0;
    private var text_height_ : Float = 0;
    
    public function new(owner : DisplayObjectContainer, txt : String)
    {
        super(owner);
        init(txt);
    }
    //.............................................................................
    private function init(txt : String) : Void
    {
        text_ = txt;
        text_field_ = new TextField();
        text_field_.type = TextFieldType.DYNAMIC;
        text_field_.defaultTextFormat = new TextFormat(null, Root.instance.def_text_size_);
        text_field_.selectable = false;
        //text_field_.background = true;
        //text_field_.backgroundColor = 0xc080f0;
        text_field_.text = ((txt != null)) ? txt : "";
        addChild(text_field_);
        mouseEnabled = mouseChildren = false;
        tabEnabled = false;
    }
    //.............................................................................
    private function get_text() : String
    {
        return text_;
    }
    private function set_text(value : String) : String
    {
        if (text_ != value)
        {
            text_ = value;
            invalidate(INVALIDATION_FLAG_DATA);
        }
        return value;
    }
    //.............................................................................
    private function get_h_align() : Int
    {
        return as3hx.Compat.parseInt(align_ & 0xFF);
    }
    private function set_h_align(value : Int) : Int
    {
        if (h_align != value)
        {
            align_ = value | as3hx.Compat.parseInt(align_ & 0xFF00);
            invalidate(INVALIDATION_FLAG_ALIGN);
        }
        return value;
    }
    //.............................................................................
    //.............................................................................
    private function get_v_align() : Int
    {
        return as3hx.Compat.parseInt((align_ & 0xFF00) >>> 8);
    }
    private function set_v_align(value : Int) : Int
    {
        if (v_align != value)
        {
            align_ = as3hx.Compat.parseInt(align_ & 0xFF) | as3hx.Compat.parseInt(value << 8);
            invalidate(INVALIDATION_FLAG_ALIGN);
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
    override public function draw() : Void
    {
        if ((invalid_flags_ & INVALIDATION_FLAG_DATA) != 0)
        {
            text_field_.text = ((text_ != null)) ? text_ : "";
            text_size_valid_for_ = 0;
        }
        if ((text_size_valid_for_ != width_) && (align_ != 0))
        {
            text_size_valid_for_ = width_;
            text_field_.width = width_;
            text_field_.autoSize = TextFieldAutoSize.LEFT;
            text_width_ = text_field_.width;
            text_height_ = text_field_.height;
            text_field_.autoSize = TextFieldAutoSize.NONE;
        }
        if ((invalid_flags_ & as3hx.Compat.parseInt(INVALIDATION_FLAG_SIZE | INVALIDATION_FLAG_ALIGN)) != 0)
        {
            var text_x : Float = 0;
            var text_y : Float = 0;
            var text_w : Float = text_width_;
            var text_h : Float = text_height_;
            if (text_w > width_)
            {
                text_w = width_;
            }
            if (text_h > height_)
            {
                text_h = height_;
            }
            switch (h_align)
            {
                case Align.CENTER:
                    text_x = (width_ - text_w) * 0.5;
                case Align.FAR:
                    text_x = width_ - text_w;
            }
            switch (v_align)
            {
                case Align.CENTER:
                    text_y = (height_ - text_h) * 0.5;
                case Align.FAR:
                    text_y = height_ - text_h;
            }
            text_field_.x = Math.round(text_x);
            text_field_.y = Math.round(text_y);
        }
        super.draw();
    }
}
