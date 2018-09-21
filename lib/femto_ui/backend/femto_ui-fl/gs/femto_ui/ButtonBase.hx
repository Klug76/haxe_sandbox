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
	inline private function init_Base() : Void
	{
#if debug
		name = "button";
#end
		buttonMode = true;//:If true, this sprite behaves as a button, which means that it triggers the display of the hand
		//:cursor when the pointer passes over the sprite and can receive a click event if the enter or space keys are
		//:pressed when the sprite has focus.
		//:tabEnabled = true;//:For a Sprite object or MovieClip object with buttonMode = true, the value is true.
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	override public function draw_Visel() : Void
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
						frame = b.hover_inflation_;
				}
				graphics.beginFill(cl, dummy_alpha_);
				graphics.drawRoundRect(-frame, -frame, width_ + 2 * frame, height_ + 2 * frame, r.round_frame_, r.round_frame_);
				graphics.endFill();
			}
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			var al: Label = b.label;
			if ((state_ & Visel.STATE_DOWN) != 0)
			{
				al.movesize_(r.content_down_offset_x_, r.content_down_offset_y_,
						width_ + r.content_down_offset_x_, height_ + r.content_down_offset_y_);
			}
			else
			{
				al.movesize_(0, 0, width_, height_);
			}
			al.draw_Visel();
			al.validate();
		}
	}
//.............................................................................
	private function add_Mouse_Listeners() : Void
	{
		addEventListener(MouseEvent.CLICK, on_Mouse_Click);
		addEventListener(MouseEvent.ROLL_OVER, on_Mouse_Over);
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
	}
//.............................................................................
	private function on_Mouse_Down(ev : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;

		ev.stopPropagation();
		stage.addEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage, false, 1);//TODO review: how to handle out-of window event!?

		var b: Button = cast this;
		b.handle_Tap(ev.localX, ev.localY);
	}
//.............................................................................
	private function on_Mouse_Up_Stage(ev : MouseEvent) : Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage, false);

		if (disposed)
			return;
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			ev.stopImmediatePropagation();

			state_ &= ~Visel.STATE_DOWN;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		}
	}
//.............................................................................
	private function on_Mouse_Over(e : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_HOVER) != 0)
			return;
		state_ |= Visel.STATE_HOVER;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

		addEventListener(MouseEvent.ROLL_OUT, on_Mouse_Out);
	}
//.............................................................................
	private function on_Mouse_Out(e : MouseEvent) : Void
	{
		state_ &= ~Visel.STATE_HOVER;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

		removeEventListener(MouseEvent.ROLL_OUT, on_Mouse_Out);
	}
//.............................................................................
	private function on_Mouse_Click(ev : MouseEvent) : Void
	{
		//trace("button::click '" + label_.text + "', target=" + e.target);
		//trace("_______");
		ev.stopPropagation();

		var b: Button = cast this;
		b.handle_Click(ev.localX, ev.localY);
	}
//.............................................................................
}

