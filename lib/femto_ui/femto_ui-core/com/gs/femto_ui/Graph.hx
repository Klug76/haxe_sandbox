package com.gs.femto_ui;

import com.gs.femto_ui.util.RingBuf;
import com.gs.femto_ui.util.Util;
import flash.Lib;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;

using com.gs.femto_ui.TextFieldExt;

//see
//https://github.com/MindScriptAct/Advanced-hi-res-stats.git
//https://github.com/mrdoob/Hi-ReS-Stats
class Graph extends Visel
{
	public static var aux_mat_ : Matrix = new Matrix();
	public static var aux_rect_ : Rectangle = new Rectangle();

	public var graph_ : BitmapData = null;
	public var graph_width_ : Int;
	public var graph_height_ : Int;
	public var suspend_timeout_: Int = 60 * 1000;//:ms
	public var suspend_timer_: Int = 0;
	public var history_ : RingBuf<Float> = null;
	public var color_graph_ : Int;
	public var color_bg_ : Int;

	public function new(owner : DisplayObjectContainer)
	{
		super(owner);
	}
//.............................................................................
	override private function init(owner : DisplayObjectContainer) : Void
	{
		var r: Root = Root.instance;
		color_graph_ = r.color_graph_;
		color_bg_ = r.color_bg_graph_;
		graph_width_ = r.graph_width_;
		graph_height_ = r.graph_height_;
		resize_(graph_width_ * r.ui_factor_, graph_height_ * r.ui_factor_);//:set size
		if (owner != null)
		{
			owner.addChildAt(this, 0);
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
	override public function destroy() : Void
	{
		stop();
		if (graph_ != null)
		{
			graph_.dispose();
			graph_ = null;
		}
		super.destroy();
	}
//.............................................................................
//.............................................................................
	override public function on_Show() : Void
	{
		//trace("******** Graph::show");
		resume();
	}
//.............................................................................
	override public function on_Hide() : Void
	{
		//trace("******** Graph::hide");
		suspend_timer_ = Lib.getTimer();
	}
//.............................................................................
//.............................................................................
	public function resume() : Void
	{
		if ((state_ & Visel.STATE_ACTIVE) != 0)
		{
			//trace("******** Graph::redraw");
			invalidate_Visel(Visel.INVALIDATION_FLAG_HISTORY);
			return;
		}
		start();
	}
//.............................................................................
	private function start(): Void
	{
		//trace("******** Graph::start");
		state_ |= Visel.STATE_ACTIVE;
		var r: Root = Root.instance;
		if (null == history_)
			history_ = new RingBuf<Float>(graph_width_);
		if (null == graph_)
			graph_ = new BitmapData(graph_width_, graph_height_, false, color_bg_);
		r.frame_signal_.add(on_Enter_Frame);
	}
//.............................................................................
	private function stop() : Void
	{
		if ((state_ & Visel.STATE_ACTIVE) == 0)
			return;
		//trace("******** Graph::stop");
		state_ &= ~Visel.STATE_ACTIVE;
		var r: Root = Root.instance;
		if (history_ != null)
			history_.clear();
		if (graph_ != null)
			graph_.fillRect(graph_.rect, color_bg_);
		r.frame_signal_.remove(on_Enter_Frame);
	}
//.............................................................................
	override public function invalidate_Visel(flags : Int) : Void
	{
		invalid_flags_ |= flags;
		//:no super.invalidate
	}
//.............................................................................
	override public function draw() : Void
	{
		//:INVALIDATION_FLAG_SCROLL used to fix openfl bug
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_SCROLL)) != 0)
		{
			paint();
		}
	}
//.............................................................................
	private function paint()
	{
		var g: Graphics = graphics;
		g.clear();
		var aux_mat: Matrix = Graph.aux_mat_;
		aux_mat.identity();
		aux_mat.scale(width_ / graph_width_, height_ / graph_height_);
		g.beginBitmapFill(graph_, aux_mat, false);
		g.drawRect(0, 0, width_, height_);
		g.endFill();
	}
//.............................................................................
	private function on_Enter_Frame() : Void
	{
		if ((state_ & Visel.STATE_ACTIVE) == 0)
			return;
		var t : Int = Lib.getTimer();
		collect_Data(t);
		if (visible)
		{
			if (invalid_flags_ != 0)
			{
				draw();
				invalid_flags_ = 0;
			}
		}
		else
		{
			if (t - suspend_timer_ >= suspend_timeout_)
				stop();
		}
	}
//.............................................................................
	public function collect_Data(timer: Int): Void
	{

	}
//.............................................................................
	public function draw_Column(nx : Int, norm_value : Float) : Void
	{
		var ny : Int = graph_height_ - Math.round(Util.fclamp(norm_value, 0, 1.1) * graph_height_ * 0.75);
		//trace("ny=" + ny + ", graph_height=" + graph_height_);
		var aux_rect: Rectangle = Graph.aux_rect_;
		aux_rect.left = nx;
		aux_rect.right = nx + 1;
		if (ny > 0)
		{
			aux_rect.top = 0;
			aux_rect.bottom = ny;
			graph_.fillRect(aux_rect, color_bg_);
		}
		if (ny < graph_height_)
		{
			aux_rect.top = ny;
			aux_rect.bottom = graph_height_;
			graph_.fillRect(aux_rect, color_graph_);
		}
	}
//.............................................................................
	public function redraw_History() : Void
	{
		//trace("Graph::redraw_History");
		var h : Int = history_.head;
		var t : Int = history_.tail;
		for (i in h...t)
		{
			var j : Int = graph_width_ + i - t;
			if (j < 0)
			{
				continue;
			}
			draw_Column(j, normalize(history_.item(i)));
		}
	}
//.............................................................................
	public function normalize(n : Float) : Float
	{
		return 0;
	}
//.............................................................................
	public function add_Text_Field(calc: String, def: String, fmt: TextFormat): TextField
	{
		var tf: TextField = TextField.create_Fixed_Text_Field(calc, def, fmt);
		addChild(tf);
		return tf;
	}
}
