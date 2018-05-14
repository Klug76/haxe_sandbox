package com.gs;
import com.gs.console.Konsole;
import com.gs.femto_ui.Visel;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.ui.Keyboard;

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
		bg_ = new Visel(this);
		bg_.dummy_color = 0x40000040;
		addChild(bg_);

		pointer_ = new Shape();
		pointer_.blendMode = BlendMode.INVERT;//TODO review
		addChild(pointer_);

		var size: Int = Math.round(k_.cfg_.zoom_size_);
		bd_ = new BitmapData(size, size, false, stage.color);
		size_ = size;
		zoom_ = new Bitmap(bd_);
		zoom_.scaleX = zoom_.scaleY = 2.;
		zoom_.x = zoom_offset_;
		zoom_.y = zoom_offset_;
		addChild(zoom_);

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
		removeEventListener(MouseEvent.MOUSE_MOVE, on_Mouse_Move);
		stage.removeEventListener(Event.RESIZE, on_Stage_Resize);
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, on_Stage_Key_Down);
		stage.removeEventListener(KeyboardEvent.KEY_UP, on_Stage_Key_Up);
	}
//.............................................................................
	private function on_Stage_Resize(ev : Event) : Void
	{
		invalidate(Visel.INVALIDATION_FLAG_DATA);
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
	private function on_Mouse_Move(ev : MouseEvent) : Void
	{
		if ((cur_x_ != ev.stageX) || (cur_y_ != ev.stageY))
		{
			cur_x_ = ev.stageX;
			cur_y_ = ev.stageY;
			//invalidate(Visel.INVALIDATION_FLAG_DATA);
			//ev.updateAfterEvent();
			invalid_flags_ |= Visel.INVALIDATION_FLAG_DATA;
			draw();
			validate();
		}
	}
//.............................................................................
	private function reset(): Void
	{
		cur_x_ = stage.mouseX;
		cur_y_ = stage.mouseY;
	}
//.............................................................................
	override public function draw() : Void
	{
		//:no super.draw();
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_DATA)) != 0)
		{
			var gr: Graphics = pointer_.graphics;
			gr.clear();
			gr.lineStyle(1, 0xAACC00, 1);
			paint_Cross(gr, cur_x_, cur_y_);
			paint_Zoom();
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE)) != 0)
		{
			bg_.resize(width_, height_);
		}
	}
//.............................................................................
	function paint_Zoom(): Void
	{
		//?if (( -1 == cur_x_) && ( -1 == cur_y_))
			//return;
		bd_.fillRect(bd_.rect, stage.color);
		mat_.tx = -cur_x_ + size_ * .5;
		mat_.ty = -cur_y_ + size_ * .5;
		try
		{
			bd_.draw(stage, mat_);
		}
		catch (err: Dynamic)
		{}
		var zx: Float = zoom_offset_;
		var zy: Float = zoom_offset_;
		if ((cur_x_ < zx + size_ * 3) && (cur_y_ < zy + size_ * 3))
		{
			zx = width_ - size_ * 2 - zoom_offset_;
			zy = height_ - size_ * 2 - zoom_offset_;
		}
		zoom_.x = zx;
		zoom_.y = zy;
	}
//.............................................................................
	function paint_Cross(gr: Graphics, nx: Float, ny: Float) : Void
	{
		gr.moveTo(nx, 0);
		gr.lineTo(nx, height_);
		gr.moveTo(0, ny);
		gr.lineTo(width_, ny);
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
//.............................................................................
}