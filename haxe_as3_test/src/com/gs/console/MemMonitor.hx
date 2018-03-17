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
	private var mem_ : Float = 0;
	private var prev_mem_ : Float = 0;
	private var mem_min_ : Float = 0;
	private var mem_max_ : Float = 0;
	private var dm_ : Float = 0xA000;
	private var tf_ : TextField;

	public function new(owner : DisplayObjectContainer)
	{
		create_Children();
		super(owner);
	}
//.............................................................................
	private function create_Children() : Void
	{
		var r : Root = Root.instance;

		tf_ = add_Text_Field("0000.00 Kb", "0", new TextFormat(null, Std.int(r.def_text_size_), r.color_ui_text_));
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
			tf_.x = width_ - tf_.width;
		}
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_HISTORY) != 0)
		{
			redraw_History();
		}
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_DATA) != 0)
		{
			if (prev_mem_ != mem_)
			{
				prev_mem_ = mem_;
				tf_.text = format_Mem(mem_);
			}

			graph_.scroll(-1, 0);
			draw_Column(graph_width_ - 1, normalize(mem_));
		}
		super.draw();
	}
//.............................................................................
	override public function start() : Void
	{
		super.start();
		timer_ = Lib.getTimer();

		mem_ = get_Used_Memory();
		mem_min_ = Util.fmax(0, mem_ - dm_ * .5);
		mem_max_ = mem_min_ + dm_;
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
				mem_max_ = mem_ + dm_;
				invalid_flags_ |= Visel.INVALIDATION_FLAG_HISTORY;
			}
			else if (mem_min_ > mem_)
			{
				mem_min_ = mem_;
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

