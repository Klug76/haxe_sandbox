package gs.konsole;

import gs.femto_ui.Graph;
import gs.femto_ui.Root;
import gs.femto_ui.Visel;
import flash.Lib;
import flash.display.DisplayObjectContainer;
import flash.text.TextField;
import flash.text.TextFormat;

class FpsMonitor extends Graph
{
	private var timer_ : Int = 0;
	private var frames_: Int = 0;
	private var fps_: Int = 0;
	private var prev_fps_ : Int = 0;
	private var max_fps_: Int = 0;
	private var prev_max_fps_ : Int = 0;
	private var tf_ : TextField;
	private var tf_min_ : TextField;
	private var tf_max_ : TextField;

	public function new(owner : DisplayObjectContainer)
	{
		super(owner);
		super.visible = false;
		create_Children();
	}
//.............................................................................
	private function create_Children() : Void
	{
		var r : Root = Root.instance;

		var fmt: TextFormat = new TextFormat(null, Std.int(r.def_font_size_), r.color_ui_text_);

		tf_min_	= add_Text_Field("0", "0", fmt);
		tf_max_	= add_Text_Field("120x120", "0", fmt);
		tf_		= add_Text_Field("120", "0", fmt);
	}
//.............................................................................
	override public function draw_Visel() : Void
	{
		update_Text();
		super.draw_Visel();
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
		{
			tf_.x = width_ - tf_.width;
			tf_min_.y = height_ - tf_min_.height;
		}
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_HISTORY) != 0)
		{
			redraw_History();
			invalid_flags_ &= ~Visel.INVALIDATION_FLAG_DATA;
		}
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_DATA) != 0)
		{
			graph_.scroll( -1, 0);
			draw_Column(graph_width_ - 1, normalize(fps_));
		}
	}
//.............................................................................
	private function update_Text(): Void
	{
		if (prev_max_fps_ != max_fps_)
		{
			prev_max_fps_ = max_fps_;
			tf_max_.text = Std.string(max_fps_);
		}
		if (prev_fps_ != fps_)
		{
			prev_fps_ = fps_;
			tf_.text = Std.string(fps_);//TODO review: Std.string is slow?
		}
	}
//.............................................................................
	override private function start() : Void
	{
		super.start();
		timer_ = Lib.getTimer();
		max_fps_ = Std.int(stage.frameRate);
		fps_ = 0;
		frames_ = 0;
		update_Text();
	}
//.............................................................................
	override public function collect_Data(timer: Int): Void
	{
		++frames_;
		if ((timer - timer_ >= 1000))
		{//:assume fps > 0 for last second

			fps_ = Math.round(frames_ * 1000 / (timer - timer_));

			history_.push(fps_);

			timer_ = timer;
			frames_ = 0;

			var max_fps: Int = Std.int(stage.frameRate);
			if (max_fps_ != max_fps)
			{
				//trace("****** max fps changed: " + max_fps_ + "->" + max_fps);
				max_fps_ = max_fps;
				invalid_flags_ |= Visel.INVALIDATION_FLAG_HISTORY;
			}
			invalid_flags_ |= Visel.INVALIDATION_FLAG_DATA #if (!flash) | Visel.INVALIDATION_FLAG_SCROLL #end;
		}
	}
//.............................................................................
	override public function normalize(n : Float) : Float
	{
		return n / max_fps_;
	}
}
