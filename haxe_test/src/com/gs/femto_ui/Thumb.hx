package com.gs.femto_ui;

import flash.Lib;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

class Thumb extends Visel
{
	public var is_drag_mode(get, never) : Bool;

	private var drag_rect_ : Rectangle;

	public function new(owner : Scrollbar)
	{
		super(owner);
		create_Listeners();
	}
//.............................................................................
	private function create_Listeners() : Void
	{
		addEventListener(MouseEvent.ROLL_OVER, on_Mouse_Over);
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
	}
//.............................................................................
	private function on_Mouse_Down(ev : MouseEvent) : Void
	{
		ev.stopImmediatePropagation();
		if ((state_ & Visel.STATE_DRAG) != 0)
		{
			return;
		}
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
		{
			drag_rect_ = new Rectangle(0, 0, 0, nh);
		}
		else
		{
			drag_rect_.height = nh;
		}
		startDrag(false, drag_rect_);
	}
//.............................................................................
	private function on_Mouse_Up_Stage(ev : MouseEvent) : Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage);
		if ((state_ & Visel.STATE_DRAG) != 0)
		{
			state_ &= ~Visel.STATE_DRAG;
			ev.stopImmediatePropagation();
			stopDrag();
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
			var p : Scrollbar = Lib.as(parent, Scrollbar);
			if (p != null)
			{
				p.on_Thumb_Finish_Drag();
			}
		}
	}
//.............................................................................
	private function on_Mouse_Move_Stage(ev : MouseEvent) : Void
	{
		if (disposed)
			return;
		if ((state_ & Visel.STATE_DRAG) != 0)
		{
			var p : Scrollbar = Lib.as(parent, Scrollbar);
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
//.............................................................................
//.............................................................................
//.............................................................................
	private function on_Mouse_Over(ev : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_HOVER) != 0)
		{
			return;
		}
		state_ |= Visel.STATE_HOVER;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		addEventListener(MouseEvent.ROLL_OUT, on_Mouse_Out);
	}
//.............................................................................
	private function on_Mouse_Out(ev : MouseEvent) : Void
	{
		state_ &= ~Visel.STATE_HOVER;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		removeEventListener(MouseEvent.ROLL_OUT, on_Mouse_Out);
	}
//.............................................................................
//.............................................................................
//.............................................................................
	override public function draw() : Void
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
					{
						cl = r.color_pressed_;
					}
					if ((state_ & Visel.STATE_HOVER) != 0)
					{
						frame = r.hover_inflation_;
					}
				}
				graphics.beginFill(cl, dummy_alpha_);
				graphics.drawRoundRect(-frame, -frame, width_ + 2 * frame, height_ + 2 * frame, r.round_frame_, r.round_frame_);
				graphics.endFill();
			}
		}
	}
//.............................................................................
//.............................................................................
	private function get_is_drag_mode() : Bool
	{
		return (state_ & Visel.STATE_DRAG) != 0;
	}
}
