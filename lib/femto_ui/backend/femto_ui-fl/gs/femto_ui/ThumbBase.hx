package gs.femto_ui;

import flash.Lib;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

class ThumbBase extends Visel
{
	private var drag_rect_ : Rectangle;

	public function new(owner : Scrollbar)
	{
		super(owner);
	}
//.............................................................................
	override private function init_Base() : Void
	{
		super.init_Base();
		addEventListener(MouseEvent.CLICK, on_Mouse_Click);
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
		addEventListener(MouseEvent.ROLL_OVER, set_Hover_State);
		addEventListener(MouseEvent.ROLL_OUT, remove_Hover_State);
	}
//.............................................................................
	override private function destroy_Base(): Void
	{
		super.destroy_Base();
		removeEventListener(MouseEvent.CLICK, on_Mouse_Click);
		removeEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
		removeEventListener(MouseEvent.ROLL_OVER, set_Hover_State);
		removeEventListener(MouseEvent.ROLL_OUT, remove_Hover_State);
	}
//.............................................................................
	private function on_Mouse_Down(ev : MouseEvent) : Void
	{
		//flash.Lib.trace("thumb::on_Mouse_Down " + ev.stageX + ":" + ev.stageY);
		ev.stopPropagation();

		if ((state_ & Visel.STATE_DRAG) != 0)
			return;

		var p : Scrollbar = Lib.as(parent, Scrollbar);
		var nh : Float = Math.floor(p.height - height_);
		if (nh <= 0)
		{//:unable to drag
			return;
		}
		state_ |= Visel.STATE_DRAG;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

		stage.addEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage, false, 1);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, on_Mouse_Move_Stage, false, 1);

		if (null == drag_rect_)
			drag_rect_ = new Rectangle(0, 0, 0, nh);
		else
			drag_rect_.height = nh;

		startDrag(false, drag_rect_);
	}
//.............................................................................
	private function on_Mouse_Up_Stage(ev : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_DRAG) != 0)
		{
			ev.stopImmediatePropagation();
			stopDrag();

			state_ &= ~Visel.STATE_DRAG;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

			var p : Scrollbar = Lib.as(parent, Scrollbar);
			if (p != null)
			{
				p.on_Thumb_Finish_Drag();
			}
		}
		stage.removeEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage);
	}
//.............................................................................
	private function on_Mouse_Move_Stage(ev : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_DRAG) != 0)
		{
			var p: Scrollbar = Lib.as(parent, Scrollbar);
			if (p != null)
			{
				ev.stopImmediatePropagation();
				ev.updateAfterEvent();
				//trace("thumb::do drag");
				p.on_Thumb_Do_Drag();
				return;
			}
		}
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, on_Mouse_Move_Stage);
	}
//.............................................................................
	private function on_Mouse_Click(ev : MouseEvent) : Void
	{
		ev.stopPropagation();//:just eat it
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	override private function draw_Base_Background() : Void
	{
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SKIN | Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			graphics.clear();
			if (dummy_alpha_ >= 0)
			{
				var r : Root = Root.instance;
				var cl : Int = dummy_color_;
				var frame : Float = 0;
				if ((state_ & Visel.STATE_DISABLED) != 0)
				{
					cl = r.color_disabled_;
				}
				else
				{
					if ((state_ & Visel.STATE_DRAG) != 0)
						cl = r.color_pressed_;
					if ((state_ & Visel.STATE_HOVER) != 0)
						frame = r.hover_inflation_;
				}
				graphics.beginFill(cl, dummy_alpha_);
				graphics.drawRoundRect(-frame, -frame, width_ + 2 * frame, height_ + 2 * frame, r.round_frame_, r.round_frame_);
				graphics.endFill();
			}
		}
	}
//.............................................................................
//.............................................................................
}
