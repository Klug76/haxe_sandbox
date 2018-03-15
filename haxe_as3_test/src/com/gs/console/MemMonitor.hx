package com.gs.console;

import com.gs.femto_ui.Graph;
import com.gs.femto_ui.Root;
import com.gs.femto_ui.Visel;
import flash.Lib;
import flash.display.DisplayObjectContainer;
import flash.geom.Rectangle;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.utils.ByteArray;

class MemMonitor extends Graph
{
    private var timer_ : Int = 0;
    private var prev_mem_ : Float = 0;
    private var mem_ : Float = 0;
    private var mem_min_ : Float = 0;
    private var mem_max_ : Float = 0;
    private var dm_ : Float = 0xA000;
    private var tf_ : TextField;

    public function new(owner : DisplayObjectContainer)
    {
        super(owner);
        create_Children();
    }
//.............................................................................
    private function create_Children() : Void
    {
        var r : Root = Root.instance;

        mem_min_ = Util.fmax(0, get_Used_Memory() - dm_ * .5);
        mem_max_ = mem_min_ + dm_;

        var s: String = "0 bytes";
        tf_ = add_Text_Field(s, s, new TextFormat(r.con_font_, r.def_text_size_, 0xffFFff));
    }
//.............................................................................
	static inline private function get_Used_Memory(): Float
	{
		#if flash
		return System.totalMemoryNumber;
		#else
		//TODO review
		//Chrome::--enable-precise-memory-info
		return System.totalMemory;
		#end
	}
//.............................................................................
//.............................................................................
    override public function draw() : Void
    {
        if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
        {
            tf_.width = width_;
        }
        super.draw();
    }
    //.............................................................................
    override public function on_Enter_Frame() : Void
    {
        var t : Int = Lib.getTimer();
        if ((t - timer_ >= 1000))
        {
            mem_ = get_Used_Memory();
            if (mem_max_ < mem_)
            {
                mem_max_ = mem_ + dm_;
                redraw_History();
            }
            else if (mem_min_ > mem_)
            {
                mem_min_ = mem_;
                redraw_History();
            }

            graph_.scroll(-1, 0);

            draw_Column(graph_width_ - 1, normalize(mem_));

            if (prev_mem_ != mem_)
            {
                prev_mem_ = mem_;
                tf_.text = Std.string(mem_) + "==" + format_Mem(mem_);
            }
            history_.push(mem_);

            timer_ = t;
#if (!flash)
			invalidate(Visel.INVALIDATION_FLAG_DATA);
#end
        }
		super.on_Enter_Frame();
    }
    //.............................................................................
    override public function normalize(n : Float) : Float
    {
        return (n - mem_min_) / (mem_max_ - mem_min_);
    }
    //.............................................................................
    //.............................................................................
    private function format_Mem(bytes : Float) : String
    {
        bytes /= 1024;
        if (bytes < 1024)
        {
            return Util.ftoFixed(bytes, 2) + " Kb";
        }

        bytes /= 1024;
        if (bytes < 1024)
        {
            return Util.ftoFixed(bytes, 2) + " Mb";
        }

        bytes /= 1024;
        if (bytes < 1024)
        {
            return Util.ftoFixed(bytes, 2) + " Gb";
        }
        //:paranoia
        return Std.string(bytes) + " bytes";
    }
}

