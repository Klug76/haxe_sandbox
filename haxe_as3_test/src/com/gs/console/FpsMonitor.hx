package com.gs.console;

import com.gs.femto_ui.Graph;
import com.gs.femto_ui.Root;
import com.gs.femto_ui.Visel;
import flash.Lib;
import flash.display.DisplayObjectContainer;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

class FpsMonitor extends Graph
{
    private var timer_ : Int = 0;
    private var prev_fps_ : Int = 0;
    private var prev_max_fps_ : Int = 0;
    private var fps_ : Int = 0;
    private var limit_ : Int = 0;
    private var tf_ : TextField;
    private var tf_min_ : TextField;
    private var tf_max_ : TextField;

    public function new(owner : DisplayObjectContainer)
    {
        super(owner);
        create_Children();
    }
    //.............................................................................
    private function create_Children() : Void
    {
        var r : Root = Root.instance;

        var cl : Int = 0xffFFff;
        var tw : Int;
        var th : Int;

        tf_min_ = new TextField();
        tf_min_.type = TextFieldType.DYNAMIC;
        tf_min_.defaultTextFormat = new TextFormat(null, r.def_text_size_, cl);
        tf_min_.selectable = false;
        tf_min_.autoSize = TextFieldAutoSize.LEFT;
        tf_min_.text = "0";
        tw = Math.round(tf_min_.width + 1);
        th = Math.round(tf_min_.height + 1);
        tf_min_.autoSize = TextFieldAutoSize.NONE;
        tf_min_.width = tw;
        tf_min_.height = th;
        addChild(tf_min_);

        tf_max_ = new TextField();
        tf_max_.type = TextFieldType.DYNAMIC;
        tf_max_.defaultTextFormat = new TextFormat(null, r.def_text_size_, cl);
        tf_max_.selectable = false;
        tf_max_.autoSize = TextFieldAutoSize.LEFT;
        tf_max_.text = "120x120";
        tw = Math.round(tf_max_.width + 1);
        tf_max_.autoSize = TextFieldAutoSize.NONE;
        tf_max_.text = "0";
        tf_max_.width = tw;
        tf_max_.height = th;
        addChild(tf_max_);

        tf_ = new TextField();
        tf_.type = TextFieldType.DYNAMIC;
        tf_.defaultTextFormat = new TextFormat(null, r.def_text_size_, cl);
        tf_.selectable = false;
        tf_.autoSize = TextFieldAutoSize.LEFT;
        tf_.text = "120";
        tw = Math.round(tf_.width + 1);
        tf_.autoSize = TextFieldAutoSize.NONE;
        tf_.text = "0";
        tf_.width = tw;
        tf_.height = th;
        addChild(tf_);
    }
    //.............................................................................
    override public function draw() : Void
    {
        if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
        {
            tf_.x = width_ - tf_.width;
            tf_min_.y = height_ - tf_min_.height;
        }
        super.draw();
    }
    //.............................................................................
    override public function on_Enter_Frame() : Void
    {
        ++fps_;
        var t : Int = Lib.getTimer();
        if (t > timer_)
		{//:assume fps > 0 for last second

            Graph.aux_rect_.width = 1;
            var max_fps : Int = (stage != null) ? Math.round(stage.frameRate) : 1;
            if (limit_ < max_fps)
            {
                limit_ = max_fps;
                redraw_History();
            }

            graph_.scroll(-1, 0);

            draw_Column(graph_width_ - 1, normalize(fps_));

            if (prev_max_fps_ != max_fps)
            {
                prev_max_fps_ = max_fps;
                tf_max_.text = Std.string(max_fps) + "/" + Std.string(limit_);
            }
            if (prev_fps_ != fps_)
            {
                prev_fps_ = fps_;
                tf_.text = Std.string(fps_);
            }
            history_.push(fps_);

            fps_ = 0;
            timer_ = t + 1000;
        }
    }
    //.............................................................................
    override public function normalize(n : Float) : Float
    {
        return n / limit_;
    }
}
