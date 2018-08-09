package com.gs.console;

import com.gs.console.Konsole;
import com.gs.femto_ui.Root;
import com.gs.femto_ui.Visel;
import com.gs.femto_ui.util.Util;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.CapsStyle;
import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.LineScaleMode;
import flash.display.PixelSnapping;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;

using com.gs.femto_ui.TextFieldExt;

class Ruler extends Visel
{
	private var k_: Konsole;
	private var bg_: Visel;
	private var crosshair_: Shape;
	private var zoom_: Bitmap;
	private var size_: Float;
	private var mat_: Matrix = new Matrix();
	private var zoom_offset_: Float = 8;
	private var zoom_offset2_: Float;
	private var tap_state_: Int = 0;
	private var tap1_: Point = new Point();
	private var tap2_: Point = new Point();
	private var tap_shape_: Shape;
	private var label_cur_pt_: TextField;
	private var label_dist_info_: TextField;
	private var cur_x_: Float = 0;
	private var cur_y_: Float = 0;

	public var aux_pt_: Point = new Point();
	public var aux_rc_: Rectangle = new Rectangle();
	public var zoom_bd_: BitmapData;

	static private inline var STATE_DEFAULT : Int	= 0;
	static private inline var STATE_TAP1 	: Int	= 1;
	static private inline var STATE_TAP2 	: Int	= 2;

	public function new(k: Konsole)
	{
		k_ = k;
		super(Root.instance.stage_);
		init_Ex();
		on_Show();
	}
//.............................................................................
	private function init_Ex() : Void
	{
		var r : Root = Root.instance;

		bg_ = new Visel(this);
		bg_.dummy_color = 0x40000040;
		addChild(bg_);

		crosshair_ = new Shape();
		addChild(crosshair_);
//#if flash
		//crosshair_.blendMode = BlendMode.INVERT;//TODO review
//#end

		tap_shape_ = new Shape();
		bg_.addChild(tap_shape_);

		var fmt: TextFormat = new TextFormat(null, Std.int(r.def_text_size_), 0x000000, true);

		label_dist_info_ = TextField.create_AutoSize_Text_Field("0", fmt);
		label_dist_info_.backgroundColor = 0xffFFff;
		label_dist_info_.background = true;
		bg_.addChild(label_dist_info_);

		fmt = new TextFormat(null, Std.int(r.def_text_size_), 0x000000, true);
		//:fmt.align = TextFormatAlign.CENTER;
		label_cur_pt_ = TextField.create_AutoSize_Text_Field("0:0", fmt);
		label_cur_pt_.backgroundColor = 0xffFFff;
		label_cur_pt_.background = true;
		bg_.addChild(label_cur_pt_);

		var size: Int = Math.round(k_.cfg_.zoom_size_);
		var zoom_factor: Int = k_.cfg_.zoom_factor_;
		zoom_offset2_ = size * zoom_factor + zoom_offset_;
		zoom_bd_ = new BitmapData(size, size, false, stage.color);
		size_ = size;
		zoom_ = new Bitmap(zoom_bd_, PixelSnapping.ALWAYS, false);
		zoom_.scaleX = zoom_.scaleY = zoom_factor;
		zoom_.x = zoom_offset_;
		zoom_.y = zoom_offset_;
		bg_.addChild(zoom_);

		k_.signal_show_.add(on_Show_Console);
	}
//.............................................................................
	function on_Show_Console() : Void
	{
		bring_To_Top();
	}
//.............................................................................
	override public function on_Show() : Void
	{
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
		addEventListener(MouseEvent.MOUSE_MOVE, on_Mouse_Move);
		stage.addEventListener(Event.RESIZE, on_Stage_Resize);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, on_Stage_Key_Down);
		stage.addEventListener(KeyboardEvent.KEY_UP, on_Stage_Key_Up);
		on_Stage_Resize(null);
		reset();
		bring_To_Top();
	}
//.............................................................................
	override public function on_Hide() : Void
	{
		removeEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
		removeEventListener(MouseEvent.MOUSE_MOVE, on_Mouse_Move);
		stage.removeEventListener(Event.RESIZE, on_Stage_Resize);
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, on_Stage_Key_Down);
		stage.removeEventListener(KeyboardEvent.KEY_UP, on_Stage_Key_Up);
	}
//.............................................................................
	private function on_Stage_Resize(ev : Event) : Void
	{
		invalidate_Visel(Visel.INVALIDATION_FLAG_DATA | Visel.INVALIDATION_FLAG_STAGE_SIZE);
		//:resize(stage.stageWidth, stage.stageHeight);
		//k_.add("scale: " + stage.scaleX + ",  " + stage.scaleY);
	}
//.............................................................................
	private function on_Stage_Key_Down(ev : KeyboardEvent) : Void
	{
		var code: UInt = ev.keyCode;
		if (is_Cancel_Key(code))
		{
			ev.preventDefault();
			ev.stopPropagation();
		}
	}
//.............................................................................
	private function on_Stage_Key_Up(ev : KeyboardEvent) : Void
	{
		//trace("stage::key up: 0x" + Std.string(ev.keyCode));
		var code: UInt = ev.keyCode;
		if (is_Cancel_Key(code))
		{
			ev.preventDefault();
			ev.stopPropagation();
			visible = false;
		}
	}
//.............................................................................
	function is_Cancel_Key(code: UInt): Bool
	{
		if (Keyboard.ESCAPE == code)
			return true;
#if flash
		if (Keyboard.BACK == code)
			return true;
#end
		return false;
	}
//.............................................................................
	private function on_Mouse_Down(ev : MouseEvent) : Void
	{
		ev.stopPropagation();
		if ((STATE_DEFAULT == tap_state_) || (STATE_TAP2 == tap_state_))
		{
			tap_state_ = STATE_TAP1;
			tap1_.x = ev.stageX;
			tap1_.y = ev.stageY;
		}
		else if (STATE_TAP1 == tap_state_)
		{
			if (ev.shiftKey || ev.ctrlKey)
			{//:replace
				tap1_.x = ev.stageX;
				tap1_.y = ev.stageY;
			}
			else
			{
				tap_state_ = STATE_TAP2;
				tap2_.x = ev.stageX;
				tap2_.y = ev.stageY;
			}
		}
		invalid_flags_ |= Visel.INVALIDATION_FLAG_DATA2;
		draw();
		validate();
		if (STATE_TAP2 == tap_state_)
		{
			dump_Info();
		}
		else
		{
			label_dist_info_.visible = false;
		}
	}
//.............................................................................
//.............................................................................
	private function on_Mouse_Move(ev : MouseEvent) : Void
	{
		if ((cur_x_ != ev.stageX) || (cur_y_ != ev.stageY))
		{
			cur_x_ = ev.stageX;
			cur_y_ = ev.stageY;
			//?invalidate(Visel.INVALIDATION_FLAG_DATA);
			//?ev.updateAfterEvent();
			invalid_flags_ |= Visel.INVALIDATION_FLAG_DATA;
			draw();
			validate();
			//TODO if tap1 show realtime distance
		}
	}
//.............................................................................
	private function reset(): Void
	{
		cur_x_ = stage.mouseX;
		cur_y_ = stage.mouseY;
		tap_shape_.graphics.clear();
		tap_state_ = STATE_DEFAULT;
		invalid_flags_ |= Visel.INVALIDATION_FLAG_DATA;
		label_dist_info_.visible = false;
	}
//.............................................................................
	private function dump_Info(): Void
	{
		var d: Float = Point.distance(tap1_, tap2_);
		var w: Float = Util.fabs(tap1_.x - tap2_.x);
		var h: Float = Util.fabs(tap1_.y - tap2_.y);
		var s: String = "<p>points: <font color='#" + Util.toHex(k_.cfg_.pt1_color_, 6) + "'>[" + tap1_.x + ", " + tap1_.y +
			"]</font> - <font color='#" + Util.toHex(k_.cfg_.pt2_color_, 6) + "'>[" + tap2_.x + ", " + tap2_.y + "]</font><br>";
		s += "distance: " + Util.ftoFixed(d, 2) + "<br>";
		s += "width: " + w + ", height: " + h + "</p>";

		k_.add_Html(s);

		if ((tap1_.x == tap2_.x) || (tap1_.y == tap2_.y))
			label_dist_info_.text = Util.ftoFixed(d, 0);
		else
			label_dist_info_.text = Util.ftoFixed(d, 2);
		aux_pt_.x = (tap1_.x + tap2_.x) * .5;
		aux_pt_.y = (tap1_.y + tap2_.y) * .5;
		aux_rc_.setTo(aux_pt_.x, aux_pt_.y, label_dist_info_.width, label_dist_info_.height);
		aux_rc_.inflate(2, 2);
		find_Popup_Pos(aux_rc_, tap1_, tap2_);
		aux_rc_.inflate( -2, -2);

		aux_pt_.x = aux_rc_.left;
		aux_pt_.y = aux_rc_.top;

		label_dist_info_.x = aux_pt_.x;
		label_dist_info_.y = aux_pt_.y;
		label_dist_info_.visible = true;
	}
//.............................................................................
	private function find_Popup_Pos(rc: Rectangle, pt1: Point, pt2: Point): Void
	{
		//:do not be offscreen
		if (rc.left + rc.width + 1 > width_)
		{
			rc.offset(width_ - rc.left - rc.width - 1, 0);
		}
		if (rc.top + rc.height + 1 > height_)
		{
			rc.offset(0, height_ - rc.top - rc.height + 1);
		}
		if (rc.left < 0)
		{
			rc.offset(-rc.left, 0);
		}
		if (rc.top < 0)
		{
			rc.offset(0, -rc.top);
		}
		//TODO do not overlap pt1, pt2?
		//if (rc.containsPoint(pt1))
		//{
		//}
		//if (rc.containsPoint(pt2))
		//{
		//}
	}
//.............................................................................
	override public function draw() : Void
	{
		//:no super.draw();
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_STAGE_SIZE) != 0)
		{
			resize(stage.stageWidth, stage.stageHeight);
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_DATA)) != 0)
		{
			paint_Crosshair(cur_x_, cur_y_);
			print_Cur_Info();
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_DATA2)) != 0)
		{
			paint_Taps();
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_DATA | Visel.INVALIDATION_FLAG_DATA2)) != 0)
		{
			paint_Zoom();
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE)) != 0)
		{
			bg_.resize(width_, height_);
		}
	}
//.............................................................................
	private function print_Cur_Info(): Void
	{
		var sx: String;
		var sy: String;
		if (StageScaleMode.NO_SCALE == stage.scaleMode)
		{
			sx = Std.string(Math.round(cur_x_));
			sy = Std.string(Math.round(cur_y_));
		}
		else
		{
			sx = Util.ftoFixed(cur_x_, 1);
			sy = Util.ftoFixed(cur_y_, 1);
		}
		label_cur_pt_.text = sx + ":" + sy;
		var nx: Float = cur_x_ + 4;
		var ny: Float = cur_y_ - size_ * .5 - label_cur_pt_.height - 4;
		if (ny < 0)
			ny = cur_y_ + size_ * .5 + 4;
		if (nx + label_cur_pt_.width > width_)
			nx = cur_x_ - label_cur_pt_.width - 4;
		label_cur_pt_.x = nx;
		label_cur_pt_.y = ny;
	}
//.............................................................................
	private function paint_Taps(): Void
	{
		var gr: Graphics = tap_shape_.graphics;
		gr.clear();
		if ((STATE_TAP1 == tap_state_) || (STATE_TAP2 == tap_state_))
		{
			gr.lineStyle(1, k_.cfg_.pt1_color_, 0.75, true, LineScaleMode.NONE, CapsStyle.NONE);
			paint_Tap(gr, tap1_.x, tap1_.y);
		}
		if (STATE_TAP2 == tap_state_)
		{
			gr.lineStyle(1, k_.cfg_.pt2_color_, 0.75, true, LineScaleMode.NONE, CapsStyle.NONE);
			paint_Tap(gr, tap2_.x, tap2_.y);

			paint_Line_Between(gr, tap1_.x, tap1_.y, tap2_.x, tap2_.y);
		}
	}
//.............................................................................
	inline private function paint_Line_Between(gr: Graphics, nx1: Float, ny1: Float, nx2: Float, ny2: Float) : Void
	{
		gr.lineStyle(1, 0xFFffFF, 1, true, LineScaleMode.NONE, CapsStyle.NONE);
		gr.moveTo(nx1, ny1);
		gr.lineTo(nx2, ny2);
		//gr.lineStyle(1);
		//gr.lineGradientStyle(GradientType.LINEAR, [0x000000, 0xFFffFF, 0], [1, 1, 1], [0, 127, 255]);
		//gr.moveTo(tap1_.x, tap1_.y);
		//gr.lineTo(tap2_.x, tap2_.y);
	}
//.............................................................................
	private function paint_Zoom(): Void
	{
		//?if (( -1 == cur_x_) && ( -1 == cur_y_))
			//return;
		var zx: Float = width_ - zoom_offset2_;
		var zy: Float = height_ - zoom_offset2_;
		if ((cur_x_ >= zx - size_) && (cur_y_ >= zy - size_))
		{
			zx = zoom_offset_;
			zy = zoom_offset_;
		}
		zoom_.x = zx;
		zoom_.y = zy;

		if (k_.cfg_.custom_zoom_draw_)
			return;

		var ui: DisplayObject = Root.instance.owner_;
		var bw: Float = zoom_bd_.width;
		var bh: Float = zoom_bd_.height;
		aux_rc_.setTo(0, 0, bw, bh);
		zoom_bd_.fillRect(aux_rc_, stage.color);
		var cnt: Float = size_ * .5;
		mat_.tx = -cur_x_ + cnt;
		mat_.ty = -cur_y_ + cnt;
		try
		{
			render_Zoom2D(zoom_bd_, ui, mat_);
		}
		catch (err: Dynamic)
		{}
		if (ui == stage)
			return;//:crosshair will be auto-rendered below
		paint_Zoom_Crosshair();
	}
//.............................................................................
	private static function render_Zoom2D(bd: BitmapData, ui: DisplayObject, mat: Matrix) : Void
	{
		bd.draw(ui, mat);
	}
//.............................................................................
	public function paint_Zoom_Crosshair() : Void
	{
		var bw: Float = zoom_bd_.width;
		var bh: Float = zoom_bd_.height;
		var bw_half: Float = bw / 2;
		var bh_half: Float = bh / 2;
		var cl: UInt = k_.cfg_.crosshair_color_;
		aux_rc_.setTo(bw_half, 0, 1, bh_half - 2);
		zoom_bd_.fillRect(aux_rc_, cl);
		aux_rc_.setTo(bw_half, bh_half + 3, 1, bh_half - 3);
		zoom_bd_.fillRect(aux_rc_, cl);

		aux_rc_.setTo(0, bh_half, bw_half - 2, 1);
		zoom_bd_.fillRect(aux_rc_, cl);
		aux_rc_.setTo(bw_half + 3, bh_half, bw_half - 3, 1);
		zoom_bd_.fillRect(aux_rc_, cl);
	}
//.............................................................................
	inline private function paint_Crosshair(nx: Float, ny: Float) : Void
	{
		var gr: Graphics = crosshair_.graphics;
		gr.clear();
		gr.lineStyle(1, k_.cfg_.crosshair_color_, 0.75, true, LineScaleMode.NONE, CapsStyle.SQUARE);
		var d: Float = 2;
		if (ny - d > 0)
		{
			gr.moveTo(nx, 0);
			gr.lineTo(nx, ny - d);
		}
		if (ny + d < height_ - 1)
		{
			gr.moveTo(nx, ny + d);
			gr.lineTo(nx, height_ - 1);
		}
		d = 2;
		if (nx - d > 0)
		{
			gr.moveTo(0, ny);
			gr.lineTo(nx - d, ny);
		}
		if (nx + d < width_ - 1)
		{
			gr.moveTo(nx + d, ny);
			gr.lineTo(width_ - 1, ny);
		}
	}
//.............................................................................
//.............................................................................
	private function paint_Tap(gr: Graphics, nx: Float, ny: Float) : Void
	{
		var d: Float = 2;
		var dd: Float = 5;
		gr.moveTo(nx - dd, ny);
		gr.lineTo(nx - d, ny);
		gr.moveTo(nx + d, ny);
		gr.lineTo(nx + dd, ny);

		gr.moveTo(nx, ny - dd);
		gr.lineTo(nx, ny - d);
		gr.moveTo(nx, ny + d);
		gr.lineTo(nx, ny + dd);
	}
//.............................................................................
//.............................................................................
	public function prepare_Zoom_Paint(): Bool
	{
		var bd: BitmapData = zoom_bd_;
		var bw: Float = bd.width;
		var bh: Float = bd.height;
		var bw_half: Float = bw / 2;
		var bh_half: Float = bh / 2;
		aux_rc_.setTo(0, 0, bw, bh);
		bd.fillRect(aux_rc_, stage.color);
		var cx: Float = 0;
		var cy: Float = 0;
		var nx: Float = cur_x_ - bw_half;
		var ny: Float = cur_y_ - bh_half;
		var nw: Float = bw;
		var nh: Float = bh;
		var src_w: Float = stage.stageWidth;//?TODO review?may be context3d.backBufferWidth?
		var src_h: Float = stage.stageHeight;
		//:avoid ArgumentError: Error #3802: Offset outside stage coordinate bound.
		if (nx < 0)
		{
			cx = -nx;
			nx = 0;
		}
		if (nx + nw > src_w)
		{
			nw = src_w - nx;
		}
		if (ny < 0)
		{
			cy = -ny;
			ny = 0;
		}
		if (ny + nh > src_h)
		{
			nh = src_h - ny;
		}
		if ((nw > 0) && (nh > 0) && (cx < bw) && (cy < bh))
		{
			aux_rc_.setTo(nx, ny, nw, nh);
			aux_pt_.setTo(cx, cy);
			return true;
		}
		return false;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
}