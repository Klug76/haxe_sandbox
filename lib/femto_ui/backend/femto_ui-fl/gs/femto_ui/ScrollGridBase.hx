package gs.femto_ui;

import flash.Lib;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import gs.femto_ui.grid.ScrollGrid;

using gs.femto_ui.RootBase.NativeUIContainer;

class ScrollGridBase extends Visel
{
	private var rect_: Rectangle = new Rectangle();
	private var scroll_rect_x(get, set): Float;
	private var scroll_rect_y(get, set): Float;

	public function new(owner : NativeUIContainer)
	{
		super(owner);
	}
//.............................................................................
	override private function init_Base() : Void
	{
		super.init_Base();
		buttonMode = true;
		addEventListener(MouseEvent.CLICK, on_Mouse_Click);
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
	}
//.............................................................................
	override private function destroy_Base(): Void
	{
		super.destroy_Base();
		removeEventListener(MouseEvent.CLICK, on_Mouse_Click);
		removeEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
	}
//.............................................................................
	private function on_Mouse_Down(ev : MouseEvent) : Void
	{
		ev.stopPropagation();

		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

		stage.addEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage, false, 1);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, on_Mouse_Move_Stage, false, 1);

		var time: Float = Lib.getTimer();
		var sg: ScrollGrid = cast this;
		sg.handle_Tap(0, ev.stageX, ev.stageY, time);
	}
//.............................................................................
	private function on_Mouse_Up_Stage(ev : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			state_ &= ~Visel.STATE_DOWN;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

			ev.stopImmediatePropagation();
			if (!disposed)
			{
				var time: Float = Lib.getTimer();
				var sg: ScrollGrid = cast this;
				sg.handle_Tap_End(0, ev.stageX, ev.stageY, time);
				return;
			}
		}
		stage.removeEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage);
	}
//.............................................................................
	private function on_Mouse_Move_Stage(ev : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			ev.stopImmediatePropagation();

			if (!disposed)
			{
				var time: Float = Lib.getTimer();
				var sg: ScrollGrid = cast this;
				sg.handle_Move(0, ev.stageX, ev.stageY, time);
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
	inline function update_Size()
	{
		rect_.width = width_;
		rect_.height = height_;
	}
//.............................................................................
	inline function get_scroll_rect_x(): Float
	{
		return rect_.x;
	}
	inline function set_scroll_rect_x(value: Float): Float
	{
		return rect_.x = value;
	}
//.............................................................................
	inline function get_scroll_rect_y(): Float
	{
		return rect_.y;
	}
	inline function set_scroll_rect_y(value: Float): Float
	{
		return rect_.y = value;
	}
//.............................................................................
//.............................................................................
	inline function update_Scroll_Rect()
	{
		var v: ScrollGrid = cast this;
		v.view_.scrollRect = rect_;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
}