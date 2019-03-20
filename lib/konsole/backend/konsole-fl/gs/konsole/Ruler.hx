package gs.konsole;

import gs.konsole.Konsole;
import gs.femto_ui.Root;
import gs.femto_ui.Visel;
import gs.femto_ui.util.Util;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.CapsStyle;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.LineScaleMode;
import flash.display.PixelSnapping;
import flash.display.Shape;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Keyboard;

using gs.femto_ui.TextFieldExt;

class Ruler extends Visel
{
	private var k_: Konsole;
	private var bg_: Visel;
	private var crosshair_: Shape;
	private var zoom_background_: Bitmap;
	private var zoom_3D_: Bitmap;
	private var zoom_2D_: Bitmap;
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
	private var num_tp_: Int = 0;
	private var touch_mode_: Bool = false;

	private var zoom_bd_3D_: BitmapData;//:see @:privateAccess in KonController
	private var zoom_bd_2D_: BitmapData;
	private var aux_rc_: Rectangle = new Rectangle();
	private var aux_pt_: Point = new Point();
	private var aux_pt2_: Point = new Point();

	static private inline var STATE_DEFAULT : Int	= 0;
	static private inline var STATE_TAP1 	: Int	= 1;
	static private inline var STATE_TAP2 	: Int	= 2;
	static private var arr_code = [Keyboard.LEFT, Keyboard.RIGHT, Keyboard.DOWN, Keyboard.UP];

	public function new(k: Konsole)
	{
		k_ = k;
		super(Root.instance.stage_);
		init_Ex();
	}
//.............................................................................
	private function init_Ex() : Void
	{
		var r : Root = Root.instance;

		bg_ = new Visel(this);
		bg_.dummy_color = k_.cfg_.ruler_overlay_color_;
		bg_.dummy_alpha = k_.cfg_.ruler_overlay_alpha_;
		addChild(bg_);

		crosshair_ = new Shape();
		bg_.addChild(crosshair_);
//#if flash
		//crosshair_.blendMode = BlendMode.INVERT;//TODO review
//#end

		tap_shape_ = new Shape();
		bg_.addChild(tap_shape_);

		var fmt: TextFormat = new TextFormat(r.font_, Std.int(r.def_font_size_), k_.cfg_.ruler_text_color_, true);

		label_dist_info_ = TextField.create_AutoSize_Text_Field("0", fmt);
		label_dist_info_.backgroundColor = k_.cfg_.ruler_bg_color_;
		label_dist_info_.background = true;
		bg_.addChild(label_dist_info_);

		label_cur_pt_ = TextField.create_AutoSize_Text_Field("0:0", fmt);
		label_cur_pt_.backgroundColor = k_.cfg_.ruler_bg_color_;
		label_cur_pt_.background = true;
		bg_.addChild(label_cur_pt_);

		var size: Int = Math.round(k_.cfg_.zoom_size_);
		size_ = size;
		var zoom_factor: Int = k_.cfg_.zoom_factor_;
		zoom_offset2_ = size * zoom_factor + zoom_offset_;

		var tmp = new BitmapData(size, size, false, 0xff000000 | k_.cfg_.zoom_bg_color_);
		zoom_background_ = new Bitmap(tmp, PixelSnapping.ALWAYS, false);
		zoom_background_.scaleX = zoom_background_.scaleY = zoom_factor;
		zoom_background_.x = zoom_offset_;
		zoom_background_.y = zoom_offset_;
		bg_.addChild(zoom_background_);

		zoom_bd_3D_ = new BitmapData(size, size, true, 0);
		zoom_3D_ = new Bitmap(zoom_bd_3D_, PixelSnapping.ALWAYS, false);
		zoom_3D_.scaleX = zoom_3D_.scaleY = zoom_factor;
		zoom_3D_.x = zoom_offset_;
		zoom_3D_.y = zoom_offset_;
		bg_.addChild(zoom_3D_);

		zoom_bd_2D_ = new BitmapData(size, size, true, 0);
		zoom_2D_ = new Bitmap(zoom_bd_2D_, PixelSnapping.ALWAYS, false);
		zoom_2D_.scaleX = zoom_2D_.scaleY = zoom_factor;
		zoom_2D_.x = zoom_offset_;
		zoom_2D_.y = zoom_offset_;
		bg_.addChild(zoom_2D_);

		k_.signal_show_.add(on_Show_Console);

		on_Show = resume;
		on_Hide = suspend;
		resume();
	}
//.............................................................................
	private function on_Show_Console() : Void
	{
		bring_To_Top();
	}
//.............................................................................
	function resume() : Void
	{
		add_Tap_Listeners();
		stage.addEventListener(Event.RESIZE, on_Stage_Resize);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, on_Stage_Key_Down, false, 1);
		stage.addEventListener(KeyboardEvent.KEY_UP, on_Stage_Key_Up, false, 1);
		on_Stage_Resize(null);
		reset();
		bring_To_Top();
	}
//.............................................................................
	function suspend() : Void
	{
		remove_Tap_Listeners();
		stage.removeEventListener(Event.RESIZE, on_Stage_Resize);
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, on_Stage_Key_Down);
		stage.removeEventListener(KeyboardEvent.KEY_UP, on_Stage_Key_Up);
	}
//.............................................................................
	private function add_Tap_Listeners() : Void
	{
#if (openfl || (flash >= 10.1))
		//trace("add touch listeners");
		addEventListener(TouchEvent.TOUCH_BEGIN, on_Touch_Begin);
		addEventListener(TouchEvent.TOUCH_END, on_Touch_End);
		addEventListener(TouchEvent.TOUCH_MOVE, on_Touch_Move);
#end
		//trace("add mouse listeners");
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
		addEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up);
		addEventListener(MouseEvent.MOUSE_MOVE, on_Mouse_Move);
	}
//.............................................................................
	private function remove_Tap_Listeners() : Void
	{
#if (openfl || (flash >= 10.1))
		removeEventListener(TouchEvent.TOUCH_BEGIN, on_Touch_Begin);
		removeEventListener(TouchEvent.TOUCH_END, on_Touch_End);
		removeEventListener(TouchEvent.TOUCH_MOVE, on_Touch_Move);
#end
		removeEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
		removeEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up);
		removeEventListener(MouseEvent.MOUSE_MOVE, on_Mouse_Move);
	}
//.............................................................................
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
			ev.stopImmediatePropagation();
			return;
		}
		var prev = tap_state_;
		aux_pt_.x = tap1_.x;
		aux_pt_.y = tap1_.y;
		aux_pt2_.x = tap2_.x;
		aux_pt2_.y = tap2_.y;
		var idx: Int = arr_code.indexOf(code);
		if (idx >= 0)
		{
			ev.preventDefault();
			ev.stopImmediatePropagation();
			var replace: Bool = ev.shiftKey || ev.ctrlKey;
			var arr_d = [-1, 1, 0, 0];
			var dx: Float = arr_d[idx];
			var dy: Float = arr_d[3 - idx];//:3 == arr_d.length - 1
			if (STATE_DEFAULT == tap_state_)
			{
				tap_state_ = STATE_TAP1;
				tap1_.x = stage.mouseX;
				tap1_.y = stage.mouseY;
			}
			else if (replace || (STATE_TAP1 == tap_state_))
			{
				tap1_.x += dx;
				tap1_.y += dy;
			}
			else//: if (STATE_TAP2 == tap_state_)
			{
				tap2_.x += dx;
				tap2_.y += dy;
			}
		}
		if ((prev != tap_state_) || !aux_pt_.equals(tap1_) || !aux_pt2_.equals(tap2_))
			update_Taps();
	}
//.............................................................................
	private function on_Stage_Key_Up(ev : KeyboardEvent) : Void
	{
		//trace("stage::key up: 0x" + Std.string(ev.keyCode));
		var code: UInt = ev.keyCode;
		if (is_Cancel_Key(code))
		{
			ev.preventDefault();
			ev.stopImmediatePropagation();
			visible = false;
			return;
		}
		var idx: Int = arr_code.indexOf(code);
		if (idx >= 0)
		{
			ev.preventDefault();
			ev.stopImmediatePropagation();
		}
	}
//.............................................................................
	function is_Cancel_Key(code: UInt): Bool
	{
		if (Keyboard.ESCAPE == code)
			return true;
#if (flash >= 10.2)
		if (Keyboard.BACK == code)
			return true;
#end
		return false;
	}
//.............................................................................
	private function on_Mouse_Down(ev : MouseEvent) : Void
	{
		if (touch_mode_)
			return;
		ev.stopImmediatePropagation();
	}
//.............................................................................
	private function on_Mouse_Up(ev : MouseEvent) : Void
	{
		if (touch_mode_)
			return;
		ev.stopImmediatePropagation();
		advance_State(ev.shiftKey || ev.ctrlKey, ev.stageX, ev.stageY);
		update_Taps();
	}
//.............................................................................
	private function on_Mouse_Move(ev : MouseEvent) : Void
	{
		if (touch_mode_)
			return;
		ev.stopImmediatePropagation();
		move_Crosshair(ev.stageX,  ev.stageY);
	}
//.............................................................................
	private function move_Crosshair(nx: Float, ny: Float) : Void
	{
		if ((cur_x_ != nx) || (cur_y_ != ny))
		{
			cur_x_ = nx;
			cur_y_ = ny;
			//?ev.updateAfterEvent();
			invalid_flags_ |= Visel.INVALIDATION_FLAG_DATA;
			draw_Visel();
			validate_Visel();
			//?TODO if tap1 show realtime distance?
		}
	}
//.............................................................................
	private function advance_State(replace: Bool, nx: Float, ny: Float) : Void
	{
		if ((STATE_DEFAULT == tap_state_) || (STATE_TAP2 == tap_state_))
		{
			tap_state_ = STATE_TAP1;
			tap1_.x = nx;
			tap1_.y = ny;
		}
		else if (STATE_TAP1 == tap_state_)
		{
			if (replace)
			{//:replace tap 1
				tap1_.x = nx;
				tap1_.y = ny;
			}
			else
			{
				tap_state_ = STATE_TAP2;
				tap2_.x = nx;
				tap2_.y = ny;
			}
		}
	}
//.............................................................................
	private function update_Taps() : Void
	{
		invalid_flags_ |= Visel.INVALIDATION_FLAG_DATA2;
		draw_Visel();
		validate_Visel();
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
//.............................................................................
	private function on_Touch_Begin(ev : TouchEvent) : Void
	{
		touch_mode_ = true;
		ev.stopImmediatePropagation();
		++num_tp_;
	}
//.............................................................................
	private function on_Touch_End(ev : TouchEvent) : Void
	{
		touch_mode_ = true;
		ev.stopImmediatePropagation();
		--num_tp_;
		if (num_tp_ > 1)
		{
			visible = false;
		}
		else if (ev.isPrimaryTouchPoint)
		{
			advance_State(false, ev.stageX, ev.stageY);
			update_Taps();
		}
	}
//.............................................................................
	private function on_Touch_Move(ev : TouchEvent) : Void
	{
		touch_mode_ = true;
		ev.stopImmediatePropagation();
		if (ev.isPrimaryTouchPoint)
		{
			move_Crosshair(ev.stageX,  ev.stageY);
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
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
		var dw: Float = Util.fabs(tap1_.x - tap2_.x);
		var dh: Float = Util.fabs(tap1_.y - tap2_.y);
		var s: String = "<p>points: <font color='#" + Util.toHex(k_.cfg_.pt1_color_, 6) + "'>[" + tap1_.x + ", " + tap1_.y +
			"]</font> - <font color='#" + Util.toHex(k_.cfg_.pt2_color_, 6) + "'>[" + tap2_.x + ", " + tap2_.y + "]</font><br>";
		s += "distance: " + Util.ftoFixed(d, 2) + ", dw: " + dw + ", dh: " + dh + "<br>";
		s += "bound rect: " + (dw + 1) + "x" + (dh + 1) + " px";
		s += "</p>";

		k_.log_Html(s);

		label_dist_info_.text = Util.ftoFixed(d, ((tap1_.x == tap2_.x) || (tap1_.y == tap2_.y)) ? 0 : 2);
		var label_w = label_dist_info_.width;
		var label_h = label_dist_info_.height;
		aux_rc_.left = (tap1_.x + tap2_.x - label_w) * .5;
		aux_rc_.top  = (tap1_.y + tap2_.y - label_h) * .5;
		aux_rc_.width = label_w;
		aux_rc_.height = label_h;
		aux_rc_.inflate(2, 2);
		find_Popup_Pos(aux_rc_, tap1_, tap2_);
		aux_rc_.inflate(-2, -2);

		label_dist_info_.x = aux_rc_.left;
		label_dist_info_.y = aux_rc_.top;
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
	override public function draw_Visel() : Void
	{
		//:no super.draw();
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_STAGE_SIZE) != 0)
		{
			resize_Visel(stage.stageWidth, stage.stageHeight);
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_DATA)) != 0)
		{
			paint_Crosshair();
			print_Cur_Info();
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_DATA2)) != 0)
		{
			paint_Taps();
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_DATA | Visel.INVALIDATION_FLAG_DATA2)) != 0)
		{
			paint_Zoom();
			paint_Zoom_Overlay();
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE)) != 0)
		{
			bg_.resize_Visel(width_, height_);
		}
	}
//.............................................................................
//.............................................................................
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
//.............................................................................
	private function paint_Zoom_Overlay(): Void
	{
		if (k_.cfg_.zoom_root_ == stage)
			return;
		var al: UInt = Math.round(k_.cfg_.crosshair_alpha_ * 255) << 24;
		var cl: UInt = k_.cfg_.crosshair_color_ | al;

		var bd: BitmapData = zoom_bd_2D_;
		var bw: Int = bd.width;
		var bh: Int = bd.height;
		var bw_half: Int = Math.floor(bw / 2);
		var bh_half: Int = Math.floor(bh / 2);
		paint_Box(bd, bw, bh, bw_half,		0,				1,				bh_half - 1,	cl);
		paint_Box(bd, bw, bh, bw_half,		bh_half + 2,	1,				bh_half - 2,	cl);
		paint_Box(bd, bw, bh, 0,			bh_half,		bw_half - 1,	1,				cl);
		paint_Box(bd, bw, bh, bw_half + 2,	bh_half,		bw_half - 2,	1,				cl);

		var nx: Int;
		var ny: Int;
		var len: Int = 4;
		if ((STATE_TAP1 == tap_state_) || (STATE_TAP2 == tap_state_))
		{
			cl = k_.cfg_.pt1_color_ | al;
			aux_pt_.x = tap1_.x;
			aux_pt_.y = tap1_.y;
			aux_pt_.offset(-cur_x_, -cur_y_);
			aux_pt_.offset(bw_half, bh_half);
			nx = Math.round(aux_pt_.x);
			ny = Math.round(aux_pt_.y);
			paint_Box(bd, bw, bh, nx + 2,			ny,				len,	1,		cl);
			paint_Box(bd, bw, bh, nx - len - 1,		ny,				len,	1,		cl);
			paint_Box(bd, bw, bh, nx,				ny - len - 1,	1,		len,	cl);
			paint_Box(bd, bw, bh, nx,				ny + 2,			1,		len,	cl);
		}
		if (STATE_TAP2 == tap_state_)
		{
			cl = k_.cfg_.pt2_color_ | al;
			aux_pt_.x = tap2_.x;
			aux_pt_.y = tap2_.y;
			aux_pt_.offset(-cur_x_, -cur_y_);
			aux_pt_.offset(bw_half, bh_half);
			nx = Math.round(aux_pt_.x);
			ny = Math.round(aux_pt_.y);
			paint_Box(bd, bw, bh, nx + 2,			ny,				len,	1,		cl);
			paint_Box(bd, bw, bh, nx - len - 1,		ny,				len,	1,		cl);
			paint_Box(bd, bw, bh, nx,				ny - len - 1,	1,		len,	cl);
			paint_Box(bd, bw, bh, nx,				ny + 2,			1,		len,	cl);
		}
	}
//.............................................................................
	private function paint_Box(bd: BitmapData, bw: Int, bh: Int, nx: Int, ny: Int, nw: Int, nh: Int, cl: UInt) : Void
	{
		if (nx < 0)
		{
			nw += nx;
			nx = 0;
		}
		if (ny < 0)
		{
			nh += ny;
			ny = 0;
		}
		if (nx + nw > bw)
		{
			nw = bw - nx;
		}
		if (ny + nh > bh)
		{
			nh = bh - ny;
		}
		if ((nw <= 0) || (nh <= 0))
			return;
		aux_rc_.left = nx;
		aux_rc_.top = ny;
		aux_rc_.width = nw;
		aux_rc_.height = nh;
		bd.fillRect(aux_rc_, cl);
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
		zoom_background_.x = zx;
		zoom_background_.y = zy;
		zoom_3D_.x = zx;
		zoom_3D_.y = zy;
		zoom_2D_.x = zx;
		zoom_2D_.y = zy;

		var bd: BitmapData = zoom_bd_2D_;
		var bw: Float = bd.width;
		var bh: Float = bd.height;
		aux_rc_.left = 0;
		aux_rc_.top = 0;
		aux_rc_.width = bw;
		aux_rc_.height = bh;
		bd.fillRect(aux_rc_, 0);

		var ui: DisplayObject = k_.cfg_.zoom_root_;
		if (null == ui)
			return;

		var cnt: Float = size_ * .5;
		mat_.tx = -cur_x_ + cnt;
		mat_.ty = -cur_y_ + cnt;
		try
		{
			render_Zoom2D(bd, ui, mat_);
		}
		catch (err: Dynamic)
		{}
	}
//.............................................................................
	private static function render_Zoom2D(bd: BitmapData, ui: DisplayObject, mat: Matrix) : Void
	{
		bd.draw(ui, mat);
	}
//.............................................................................
//.............................................................................
	private function paint_Crosshair() : Void
	{
		var gr: Graphics = crosshair_.graphics;
		gr.clear();
		gr.lineStyle(1, k_.cfg_.crosshair_color_, k_.cfg_.crosshair_alpha_, true, LineScaleMode.NONE, CapsStyle.SQUARE);
		paint_Crosshair_Ex(gr, cur_x_, cur_y_, width_, height_, 2);
	}
//.............................................................................
	private function paint_Crosshair_Ex(gr: Graphics, nx: Float, ny: Float, nw: Float, nh: Float, offset: Float) : Void
	{
		if (ny - offset > 0)
		{
			gr.moveTo(nx, 0);
			gr.lineTo(nx, ny - offset);
		}
		if (ny + offset < nh - 1)
		{
			gr.moveTo(nx, ny + offset);
			gr.lineTo(nx, nh - 1);
		}
		if (nx - offset > 0)
		{
			gr.moveTo(0, ny);
			gr.lineTo(nx - offset, ny);
		}
		if (nx + offset < nw - 1)
		{
			gr.moveTo(nx + offset, ny);
			gr.lineTo(nw - 1, ny);
		}
	}
//.............................................................................
//.............................................................................
	private function paint_Taps() : Void
	{
		var gr: Graphics = tap_shape_.graphics;
		gr.clear();
		var ui_factor: Float = Root.instance.ui_factor_;
		var offs: Float = 2 * ui_factor;
		var len: Float = 5 * ui_factor;
		if ((STATE_TAP1 == tap_state_) || (STATE_TAP2 == tap_state_))
		{
			gr.lineStyle(1, k_.cfg_.pt1_color_, k_.cfg_.crosshair_alpha_, true, LineScaleMode.NONE, CapsStyle.NONE);
			paint_Tap(gr, tap1_.x, tap1_.y, offs, len);
		}
		if (STATE_TAP2 == tap_state_)
		{
			gr.lineStyle(1, k_.cfg_.pt2_color_, k_.cfg_.crosshair_alpha_, true, LineScaleMode.NONE, CapsStyle.NONE);
			paint_Tap(gr, tap2_.x, tap2_.y, offs, len);

			paint_Line_Between(gr, tap1_.x, tap1_.y, tap2_.x, tap2_.y);
		}
	}
//.............................................................................
	private function paint_Tap(gr: Graphics, nx: Float, ny: Float, offset: Float, len: Float) : Void
	{
		gr.moveTo(nx - len, ny);
		gr.lineTo(nx - offset, ny);
		gr.moveTo(nx + offset, ny);
		gr.lineTo(nx + len, ny);

		gr.moveTo(nx, ny - len);
		gr.lineTo(nx, ny - offset);
		gr.moveTo(nx, ny + offset);
		gr.lineTo(nx, ny + len);
	}
//.............................................................................
//.............................................................................
	inline private function paint_Line_Between(gr: Graphics, nx1: Float, ny1: Float, nx2: Float, ny2: Float) : Void
	{
		gr.lineStyle(1, k_.cfg_.ruler_line_color_, 1, true, LineScaleMode.NONE, CapsStyle.NONE);
		gr.moveTo(nx1, ny1);
		gr.lineTo(nx2, ny2);
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public function prepare_Zoom_Paint(): Bool
	{
		var bd: BitmapData = zoom_bd_3D_;
		var bw: Float = bd.width;
		var bh: Float = bd.height;
		var bw_half: Float = bw / 2;
		var bh_half: Float = bh / 2;
		aux_rc_.left = 0;
		aux_rc_.top = 0;
		aux_rc_.width = bw;
		aux_rc_.height = bh;
		bd.fillRect(aux_rc_, 0);
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
			aux_rc_.left = nx;
			aux_rc_.top = ny;
			aux_rc_.width = nw;
			aux_rc_.height = nh;
			aux_pt_.x = cx;
			aux_pt_.y = cy;
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
