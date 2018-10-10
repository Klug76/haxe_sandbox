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
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
		addEventListener(MouseEvent.ROLL_OVER, set_Hover_State);
		addEventListener(MouseEvent.ROLL_OUT, remove_Hover_State);
		//addEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up);//:TODO review: cause problems with Scrollbar::Thumb
	}
//.............................................................................
	override private function destroy_Base(): Void
	{
		super.destroy_Base();
		removeEventListener(MouseEvent.CLICK, on_Mouse_Click);
		removeEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
		removeEventListener(MouseEvent.ROLL_OVER, set_Hover_State);
		removeEventListener(MouseEvent.ROLL_OUT, remove_Hover_State);
		//removeEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up);
	}
//.............................................................................
//.............................................................................
//.............................................................................
	override private function draw_Base_Background() : Void
	{
		//if (1100101 == tag_)
			//trace("***");
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SKIN | Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			graphics.clear();
			var nw : Float = width_;
			var nh : Float = height_;
			var al = dummy_alpha_;
			if ((al >= 0) && (nw > 0) && (nh > 0))
			{
				var r : Root = Root.instance;
				var b: Button = cast this;
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
				graphics.beginFill(cl, al);
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
		ev.stopPropagation();

		//flash.Lib.trace("button::on_Mouse_Down " + ev.stageX + ":" + ev.stageY);
		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

		stage.addEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage, false, 1);//TODO review: how to handle out-of window event!?

		var b: Button = cast this;
		b.handle_Tap(0, ev.stageX, ev.stageY, ev.localX, ev.localY);
		//trace("button::" + ev.type + " '" + b.text + "', target=" + ev.target);
	}
//.............................................................................
//.............................................................................
	private function on_Mouse_Up_Stage(ev : MouseEvent) : Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage, false);
		if (disposed)
			return;
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			state_ &= ~Visel.STATE_DOWN;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

			ev.stopImmediatePropagation();
		}
	}
//.............................................................................
//.............................................................................
	private function on_Mouse_Click(ev : MouseEvent) : Void
	{
		ev.stopPropagation();

		var b: Button = cast this;
		b.handle_Click(ev.stageX, ev.stageY, ev.localX, ev.localY);
		//trace("button::" + ev.type + " '" + b.text + "', target=" + ev.target);
	}
//.............................................................................
}

