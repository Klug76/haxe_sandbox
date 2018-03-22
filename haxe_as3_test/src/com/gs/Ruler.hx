package com.gs;
import com.gs.console.Konsole;
import com.gs.femto_ui.Visel;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

class Ruler extends Visel
{
	private var k_: Konsole;
	private var cur_x_: Float = 0;
	private var cur_y_: Float = 0;
	private var bg_: Visel;
	//private var zoom_: MiniZoom;

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
		resize(stage.stageWidth, stage.stageHeight);
	}
//.............................................................................
	private function on_Stage_Key_Down(ev : KeyboardEvent) : Void
	{
		var code = ev.keyCode;
		if ((Keyboard.ESCAPE == code) || (Keyboard.BACK == code))
		{
			ev.preventDefault;
		}
	}
//.............................................................................
	private function on_Stage_Key_Up(ev : KeyboardEvent) : Void
	{
		//trace("stage::key up: 0x" + Std.string(ev.keyCode));
		var code = ev.keyCode;
		if ((Keyboard.ESCAPE == code) || (Keyboard.BACK == code))
		{
			ev.preventDefault;
			visible = false;
		}
	}
//.............................................................................
	private function on_Mouse_Move(ev : MouseEvent) : Void
	{
		if ((cur_x_ != ev.localX) || (cur_y_ != ev.localY))
		{
			cur_x_ = ev.localX;
			cur_y_ = ev.localY;
			invalidate(Visel.INVALIDATION_FLAG_DATA);
			ev.updateAfterEvent();
		}
	}
//.............................................................................
	private function reset(): Void
	{

	}
//.............................................................................
	override public function draw() : Void
	{
		//:no super.draw();
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_DATA)) != 0)
		{
			var gr: Graphics = graphics;
			gr.clear();
			gr.lineStyle(1, 0x404040, 0.75);
			gr.moveTo(cur_x_, 0);
			gr.lineTo(cur_x_, height_);
			gr.moveTo(0, cur_y_);
			gr.lineTo(width_, cur_y_);
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE)) != 0)
		{
			bg_.resize(width_, height_);
		}
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