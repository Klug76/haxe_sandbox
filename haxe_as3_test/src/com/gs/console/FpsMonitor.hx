package com.gs.console;

import com.gs.femto_ui.Graph;
import com.gs.femto_ui.Root;
import com.gs.femto_ui.Visel;
import flash.Lib;
import flash.display.DisplayObjectContainer;
import flash.text.TextField;
import flash.text.TextFormat;

class FpsMonitor extends Graph
{
    private var timer_ : Int = 0;
	private var frames_: Int = 0;
    private var prev_fps_ : Int = 0;
    private var prev_max_fps_ : Int = 0;
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

		var fmt: TextFormat = new TextFormat(r.con_font_, r.def_text_size_, 0xffFFff);

        tf_min_	= add_Text_Field("0", "0", fmt);
        tf_max_	= add_Text_Field("120x120", "0", fmt);
        tf_		= add_Text_Field("120", "0", fmt);
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
		++frames_;
        var t : Int = Lib.getTimer();
        if ((t - timer_ >= 1000))
		{//:assume fps > 0 for last second
            var max_fps : Int = (stage != null) ? Math.round(stage.frameRate) : 1;
            if (limit_ < max_fps)
            {
                limit_ = max_fps;
                redraw_History();
            }

            graph_.scroll( -1, 0);

            if (prev_max_fps_ != max_fps)
            {
                prev_max_fps_ = max_fps;
				if (max_fps != limit_)
					tf_max_.text = Std.string(max_fps) + "/" + Std.string(limit_);
				else
					tf_max_.text = Std.string(max_fps);
            }
			var fps: Int = Math.round(frames_ * 1000 / (t - timer_));
            if (prev_fps_ != fps)
            {
				//fps = (prev_fps_ + fps) >> 1;
                prev_fps_ = fps;
                tf_.text = Std.string(fps);
            }

            draw_Column(graph_width_ - 1, normalize(fps));

			history_.push(fps);

            timer_ = t;
			frames_ = 0;
#if (!flash)
			invalidate(Visel.INVALIDATION_FLAG_DATA);
#end
        }
		super.on_Enter_Frame();
    }
//.............................................................................
    override public function normalize(n : Float) : Float
    {
        return n / limit_;
    }
}
