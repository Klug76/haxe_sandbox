package gs.konsole;

import gs.femto_ui.Graph;
import gs.femto_ui.Root;
import gs.femto_ui.Visel;
import gs.femto_ui.util.Util;
import flash.Lib;
import flash.display.DisplayObjectContainer;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFormat;

class MemMonitor extends Graph
{
	private var timer_ : Int = 0;
	private var mem_ : Float = 0;
	private var prev_mem_ : Float = 0;
	private var mem_min_ : Float = 0;
	private var mem_max_ : Float = 0;
	private var prev_mem_min_ : Float = 0;
	private var prev_mem_max_ : Float = 0;
	private var dm_ : Float = 1024 * 512;
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

		tf_		= add_Text_Field("0000.00 Kb", "0", fmt);
		tf_min_	= add_Text_Field("0000.00 Kb", "0", fmt);
		tf_max_	= add_Text_Field("0000.00 Kb", "0", fmt);
	}
//.............................................................................
	static inline private function get_Used_Memory(): Float
	{
		#if (flash >= 10.1)
		return System.totalMemoryNumber;
		#else
		//TODO review
		//Chrome::--enable-precise-memory-info
		return System.totalMemory;
		#end
	}
//.............................................................................
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
			graph_.scroll(-1, 0);
			draw_Column(graph_width_ - 1, normalize(mem_));
		}
	}
//.............................................................................
	private function update_Text() : Void
	{
		if (prev_mem_ != mem_)
		{
			prev_mem_ = mem_;
			tf_.text = format_Mem(mem_);
		}
		if (prev_mem_min_ != mem_min_)
		{
			prev_mem_min_ = mem_min_;
			tf_min_.text = format_Mem(mem_min_);
		}
		if (prev_mem_max_ != mem_max_)
		{
			prev_mem_max_ = mem_max_;
			tf_max_.text = format_Mem(mem_max_);
		}
	}
//.............................................................................
	override private function start() : Void
	{
		super.start();
		timer_ = Lib.getTimer();

		mem_ = get_Used_Memory();
		mem_min_ = Util.fmax(0, mem_ - dm_);
		mem_max_ = mem_ + dm_;

		update_Text();
	}
//.............................................................................
	override public function collect_Data(timer: Int): Void
	{
		if ((timer - timer_ >= 1000))
		{
			mem_ = get_Used_Memory();
			history_.push(mem_);

			timer_ = timer;

			if (mem_max_ < mem_)
			{
				//trace("*** mem max changed: " + format_Mem(mem_max_) + "->" + format_Mem(mem_ + dm_));
				mem_max_ = mem_ + dm_;
				invalid_flags_ |= Visel.INVALIDATION_FLAG_HISTORY;
			}
			else if (mem_min_ > mem_)
			{
				//trace("*** mem min changed: " + format_Mem(mem_min_) + "->" + format_Mem(Util.fmax(0, mem_ - dm_)));
				mem_min_ = Util.fmax(0, mem_ - dm_);
				invalid_flags_ |= Visel.INVALIDATION_FLAG_HISTORY;
			}
			invalid_flags_ |= Visel.INVALIDATION_FLAG_DATA #if (!flash) | Visel.INVALIDATION_FLAG_SCROLL #end;
		}
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

