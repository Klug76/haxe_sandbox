package com.gs;
import com.gs.console.Konsole;
import com.gs.femto_ui.Root;
import com.gs.femto_ui.Visel;
import com.gs.femto_ui.util.Util;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.display.Sprite;
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
	private var cur_x_: Float = 0;
	private var cur_y_: Float = 0;
	private var bg_: Visel;
	private var pointer_: Shape;
	private var zoom_: Bitmap;
	private var size_: Float;
	private var mat_: Matrix = new Matrix();
	private var bd_: BitmapData;
	private var zoom_offset_: Float = 8;
	private var zoom_factor_: Float = 4;
	private var tap_state_: Int = 0;
	private var tap1_: Point = new Point();
	private var tap2_: Point = new Point();
	private var aux_pt_: Point = new Point();
	private var aux_rc_: Rectangle = new Rectangle();
	private var tap_shape_: Shape;
	private var info_: TextField;
	private var line_text_: TextField;

	static private inline var STATE_DEFAULT : Int	= 0;
	static private inline var STATE_TAP1 	: Int	= 1;
	static private inline var STATE_TAP2 	: Int	= 2;
	static private inline var color_pt1_	: Int = 0xff0000;
	static private inline var color_pt2_	: Int = 0xffff00;

	public function new(k: Konsole)
	{
		k_ = k;
		super(k.stage_);
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

		pointer_ = new Shape();
		addChild(pointer_);
#if flash
		pointer_.blendMode = BlendMode.INVERT;//TODO review
#end

		tap_shape_ = new Shape();
		bg_.addChild(tap_shape_);

		var fmt: TextFormat = new TextFormat(null, Std.int(r.def_text_size_), 0x000000, true);

		line_text_ = TextField.create_AutoSize_Text_Field("0", fmt);
		line_text_.backgroundColor = 0xffFFff;
		line_text_.background = true;
		line_text_.alpha = 0.75;
		bg_.addChild(line_text_);

		fmt = new TextFormat(null, Std.int(r.def_text_size_), 0x000000, true);
		fmt.align = TextFormatAlign.CENTER;
		info_ = TextField.create_Fixed_Text_Field("0000:0000", "0:0", fmt);
		info_.backgroundColor = 0xffFFff;
		info_.background = true;
		bg_.addChild(info_);

		var size: Int = Math.round(k_.cfg_.zoom_size_);
		bd_ = new BitmapData(size, size, false, stage.color);
		size_ = size;
		zoom_ = new Bitmap(bd_);
		zoom_.scaleX = zoom_.scaleY = zoom_factor_;
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
		invalidate_Visel(Visel.INVALIDATION_FLAG_DATA);
		resize(stage.stageWidth, stage.stageHeight);
	}
//.............................................................................
	private function on_Stage_Key_Down(ev : KeyboardEvent) : Void
	{
		var code: UInt = ev.keyCode;
		if (is_Cancel_Key(code))
		{
			ev.preventDefault;
		}
	}
//.............................................................................
	private function on_Stage_Key_Up(ev : KeyboardEvent) : Void
	{
		//trace("stage::key up: 0x" + Std.string(ev.keyCode));
		var code: UInt = ev.keyCode;
		if (is_Cancel_Key(code))
		{
			ev.preventDefault;
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
			line_text_.visible = false;
		}
	}
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
		line_text_.visible = false;
	}
//.............................................................................
	private function dump_Info(): Void
	{
		var d: Float = Point.distance(tap1_, tap2_);
		var w: Float = Util.fabs(tap1_.x - tap2_.x);
		var h: Float = Util.fabs(tap1_.y - tap2_.y);
		var s: String = "<p>points: <font color='#" + Util.toHex(color_pt1_, 6) + "'>[" + tap1_.x + ", " + tap1_.y +
			"]</font> - <font color='#" + Util.toHex(color_pt2_) + "'>[" + tap2_.x + ", " + tap2_.y + "]</font><br>";
		s += "distance: " + Util.ftoFixed(d, 2) + "<br>";
		s += "width: " + w + ", height: " + h + "</p>";
		//TODO show more info...
		k_.add_Html(s);

		line_text_.visible = true;
		if ((tap1_.x == tap2_.x) || (tap1_.y == tap2_.y))
			line_text_.text = Util.ftoFixed(d, 0);
		else
			line_text_.text = Util.ftoFixed(d, 2);
		aux_pt_.x = (tap1_.x + tap2_.x) * .5;
		aux_pt_.y = (tap1_.y + tap2_.y) * .5;
		aux_rc_.setTo(aux_pt_.x, aux_pt_.y, line_text_.width, line_text_.height);
		aux_rc_.inflate(2, 2);
		find_Popup_Pos(aux_rc_, tap1_, tap2_);
		aux_rc_.inflate( -2, -2);

		aux_pt_.x = aux_rc_.left;
		aux_pt_.y = aux_rc_.top;

		line_text_.x = aux_pt_.x;
		line_text_.y = aux_pt_.y;
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
		//TODO do not overlap pt1, pt2
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
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_DATA)) != 0)
		{
			var gr: Graphics = pointer_.graphics;
			gr.clear();
			gr.lineStyle(1, 0xAAcc00, 0.75, true, LineScaleMode.NONE, CapsStyle.SQUARE);
			paint_Cross(gr, cur_x_, cur_y_);
			print_Cur_Info();
			//paint_Aim(gr, cur_x_ + 5, cur_y_ + 5);
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
		info_.text = cur_x_ + ":" + cur_y_;
		var nx: Float = cur_x_ + 4;
		var ny: Float = cur_y_ - size_ * .5 - info_.height - 4;
		if (ny < 0)
			ny = cur_y_ + size_ * .5 + 4;
		if (nx + info_.width > width_)
			nx = cur_x_ - info_.width - 4;
		info_.x = nx;
		info_.y = ny;
	}
//.............................................................................
	private function paint_Taps(): Void
	{
		var gr: Graphics = tap_shape_.graphics;
		gr.clear();
		if ((STATE_TAP1 == tap_state_) || (STATE_TAP2 == tap_state_))
		{
			gr.lineStyle(1, color_pt1_, 0.75, true, LineScaleMode.NONE, CapsStyle.NONE);
			paint_Aim(gr, tap1_.x, tap1_.y);
		}
		if (STATE_TAP2 == tap_state_)
		{
			gr.lineStyle(1, color_pt2_, 0.75, true, LineScaleMode.NONE, CapsStyle.NONE);
			paint_Aim(gr, tap2_.x, tap2_.y);

			gr.lineStyle(1, 0, 1, true, LineScaleMode.NONE, CapsStyle.NONE);
			gr.moveTo(tap1_.x, tap1_.y);
			gr.lineTo(tap2_.x, tap2_.y);
		}
	}
//.............................................................................
	private function paint_Zoom(): Void
	{
		//?if (( -1 == cur_x_) && ( -1 == cur_y_))
			//return;
		var zx: Float = width_ - size_ * zoom_factor_ - zoom_offset_;
		var zy: Float = height_ - size_ * zoom_factor_ - zoom_offset_;
		if ((cur_x_ >= zx - size_) && (cur_y_ >= zy - size_))
		{
			zx = zoom_offset_;
			zy = zoom_offset_;
		}
		zoom_.x = zx;
		zoom_.y = zy;

		bd_.fillRect(bd_.rect, stage.color);
		var cnt: Float = size_ * .5;
		mat_.tx = -cur_x_ + cnt;
		mat_.ty = -cur_y_ + cnt;
		try
		{
			bd_.draw(stage, mat_);
		}
		catch (err: Dynamic)
		{}
	}
//.............................................................................
	function paint_Cross(gr: Graphics, nx: Float, ny: Float) : Void
	{
		var d: Float = 1;
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
	function paint_Aim(gr: Graphics, nx: Float, ny: Float) : Void
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