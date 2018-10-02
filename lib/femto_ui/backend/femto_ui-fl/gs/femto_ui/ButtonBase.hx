package gs.femto_ui;

import flash.events.Event;
import flash.events.MouseEvent;

using gs.femto_ui.RootBase.NativeUIContainer;
//:________________________________________________________________________________________________
class ButtonBase extends Visel
{

	public function new(owner : NativeUIContainer)
	{
		super(owner);
	}
//.............................................................................
	override private function init_Base() : Void
	{
		super.init_Base();
		buttonMode = true;//:If true, this sprite behaves as a button, which means that it triggers the display of the hand
		//:cursor when the pointer passes over the sprite and can receive a click event if the enter or space keys are
		//:pressed when the sprite has focus.
		//:tabEnabled = true;//:For a Sprite object or MovieClip object with buttonMode = true, the value is true.
		addEventListener(MouseEvent.CLICK, on_Mouse_Click);
		addEventListener(MouseEvent.ROLL_OVER, on_Mouse_Over);
		addEventListener(MouseEvent.ROLL_OUT, on_Mouse_Out);
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
		//addEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up);//:TODO review: cause problems with Scrollbar::Thumb
	}
//.............................................................................
//.............................................................................
	override private function destroy_Base(): Void
	{
		super.destroy_Base();
		removeEventListener(MouseEvent.CLICK, on_Mouse_Click);
		removeEventListener(MouseEvent.ROLL_OVER, on_Mouse_Over);
		removeEventListener(MouseEvent.ROLL_OUT, on_Mouse_Out);
		removeEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
		//removeEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up);
	}
//.............................................................................
//.............................................................................
//.............................................................................
	override public function draw_Base_Background() : Void
	{
		//if (1100101 == tag_)
			//trace("***");
		var r : Root = Root.instance;
		var b: Button = cast this;
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SKIN | Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			graphics.clear();
			if (dummy_alpha_ >= 0)
			{
				var cl : Int = dummy_color_;
				var frame : Float = 0;
				if ((state_ & Visel.STATE_DISABLED) != 0)
				{
					cl = r.color_disabled_;
				}
				else
				{
					if ((state_ & Visel.STATE_DOWN) != 0)
						cl = r.color_pressed_;
					if ((state_ & Visel.STATE_HOVER) != 0)
						frame = b.hover_inflation_;//:may be custom
				}
				graphics.beginFill(cl, dummy_alpha_);
				graphics.drawRoundRect(-frame, -frame, width_ + 2 * frame, height_ + 2 * frame, r.round_frame_, r.round_frame_);
				graphics.endFill();
			}
		}
		//:super.draw_Base_Background();
	}
//.............................................................................
//.............................................................................
	private function on_Mouse_Down(ev : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

		ev.stopPropagation();
		stage.addEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage, false, 1);//TODO review: how to handle out-of window event!?

		var b: Button = cast this;
		b.handle_Tap(0, ev.stageX, ev.stageY);
		//trace("button::" + ev.type + " '" + b.text + "', target=" + ev.target);
	}
//.............................................................................
	private function on_Mouse_Up(ev : MouseEvent) : Void
	{
		ev.stopImmediatePropagation();
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			state_ &= ~Visel.STATE_DOWN;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		}
	}
//.............................................................................
	private function on_Mouse_Up_Stage(ev : MouseEvent) : Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage, false);
		if (disposed)
			return;
		on_Mouse_Up(ev);
	}
//.............................................................................
	private function on_Mouse_Over(e : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_HOVER) != 0)
			return;
		state_ |= Visel.STATE_HOVER;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
	}
//.............................................................................
	private function on_Mouse_Out(e : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_HOVER) != 0)
		{
			state_ &= ~Visel.STATE_HOVER;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		}
	}
//.............................................................................
	private function on_Mouse_Click(ev : MouseEvent) : Void
	{
		ev.stopPropagation();

		var b: Button = cast this;
		b.handle_Click(ev.localX, ev.localY);
		//trace("button::" + ev.type + " '" + b.text + "', target=" + ev.target);
	}
//.............................................................................
}

