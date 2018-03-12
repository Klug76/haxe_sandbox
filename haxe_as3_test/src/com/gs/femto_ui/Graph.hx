package com.gs.femto_ui;

import com.gs.console.RingBuf;
import com.gs.console.Util;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.utils.ByteArray;

//see
//https://github.com/MindScriptAct/Advanced-hi-res-stats.git
//https://github.com/mrdoob/Hi-ReS-Stats
class Graph extends Visel
{
    public static var aux_mat_ : Matrix = new Matrix();
    public static var aux_rect_ : Rectangle = new Rectangle();

    public var graph_ : BitmapData = null;
    public var graph_width_ : Int = 256;
    //public var graph_width_: int = 16;
    public var graph_height_ : Int = 128;
    public var graph_color_ : Int = 0x408080;
    public var bg_color_ : Int = 0;
    public var history_ : RingBuf<Float> = null;

    public function new(owner : DisplayObjectContainer)
    {
        super(owner);
    }
//.............................................................................
    override public function destroy() : Void
    {
        stop();
        super.destroy();
    }
//.............................................................................
    public function dispose_Graph() : Void
    {
        if (graph_ != null)
        {
            graphics.clear();
            graph_.dispose();
            graph_ = null;
        }
    }
//.............................................................................
    public function init_Graph() : Void
    {
        if (graph_ != null)
        {
            return;
        }
        graph_ = new BitmapData(graph_width_, graph_height_, false, bg_color_);
    }
//.............................................................................
    public function start() : Void
    {
        if ((state_ & Visel.STATE_ACTIVE) != 0)
        {
            return;
        }
        state_ |= Visel.STATE_ACTIVE;
        if (width_ <= 0)
        {
            resize(graph_width_, graph_height_);
        }
        if (null == history_)
        {
            history_ = new RingBuf<Float>(graph_width_);
        }
        init_Graph();
        Root.instance.frame_signal_.add(on_Enter_Frame);
    }
//.............................................................................
    public function stop() : Void
    {
        if ((state_ & Visel.STATE_ACTIVE) == 0)
        {
            return;
        }
        state_ &= ~Visel.STATE_ACTIVE;
        history_.clear();
        dispose_Graph();
        Root.instance.frame_signal_.remove(on_Enter_Frame);
    }
//.............................................................................
    override public function invalidate(flags : Int) : Void
    {
        invalid_flags_ |= flags;
		//:no super.invalidate
    }
//.............................................................................
    override public function draw() : Void
    {
        if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_DATA)) != 0)
        {
			paint();
        }
    }
//.............................................................................
	public function paint()
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
    public function on_Enter_Frame() : Void
    {
		if (invalid_flags_ != 0)
		{
			draw();
			invalid_flags_ = 0;
		}
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
			graph_.fillRect(aux_rect, bg_color_);
		}
		if (ny < graph_height_)
		{
			aux_rect.top = ny;
			aux_rect.bottom = graph_height_;
			graph_.fillRect(aux_rect, graph_color_);
		}
    }
//.............................................................................
    public function redraw_History() : Void
    {
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
		var tf: TextField = new TextField();
        tf.type = TextFieldType.DYNAMIC;
        tf.defaultTextFormat = fmt;
        tf.selectable = false;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.text = calc;
        var tw: Int = Math.round(tf.width + 1);
        var th: Int = Math.round(tf.height + 1);
        tf.autoSize = TextFieldAutoSize.NONE;
        tf.width = tw;
        tf.height = th;
        tf.text = def;
        addChild(tf);
		return tf;
	}
}
