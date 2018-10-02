package gs.femto_ui;

import gs.femto_ui.util.Util;
import flash.Vector;
import flash.display.GraphicsPathCommand;
import flash.events.MouseEvent;

using gs.femto_ui.RootBase.NativeUIContainer;

class ResizerBase extends Visel
{
	public function new(owner : NativeUIContainer)
	{
		super(owner);
	}
//.............................................................................
	override private function init_Base() : Void
	{
		buttonMode = true;
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
		addEventListener(MouseEvent.ROLL_OVER, on_Mouse_Over);
	}
//.............................................................................
	private function on_Mouse_Down(ev : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;
		ev.stopPropagation();

		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		stage.addEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage, false, 1);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, on_Mouse_Move_Stage, false, 1);

		var rz: Resizer = cast this;
		rz.handle_Tap(0, ev.stageX, ev.stageY);
	}
//.............................................................................
	private function on_Mouse_Up_Stage(ev : MouseEvent) : Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage);
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, on_Mouse_Move_Stage);
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			state_ &= ~Visel.STATE_DOWN;
			ev.stopImmediatePropagation();
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		}
	}
//.............................................................................
	private function on_Mouse_Move_Stage(ev : MouseEvent) : Void
	{
		if (disposed)
			return;
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			ev.stopImmediatePropagation();
			var rz: Resizer = cast this;
			rz.handle_Move(0, ev.stageX, ev.stageY);
		}
	}
//.............................................................................
	private function on_Mouse_Over(ev : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_HOVER) != 0)
			return;
		state_ |= Visel.STATE_HOVER;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		addEventListener(MouseEvent.ROLL_OUT, on_Mouse_Out);
	}
//.............................................................................
	private function on_Mouse_Out(ev : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_HOVER) != 0)
		{
			state_ &= ~Visel.STATE_HOVER;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		}
		removeEventListener(MouseEvent.ROLL_OUT, on_Mouse_Out);
	}
//.............................................................................
//.............................................................................
	override public function draw_Visel() : Void
	{
		draw_Base_Background();
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SKIN | Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			//if (1100101 == tag_)
				//trace("Resizer::draw");
			var nw : Float = width_;
			var nh : Float = height_;
			var al : Float = dummy_alpha_;
			if ((al >= 0) && (nw > 0) && (nh > 0))
			{
				var r : Root = Root.instance;
				var cmd : Vector<Int> = new Vector<Int>(4);
				cmd[0] = GraphicsPathCommand.MOVE_TO;
				cmd[1] = GraphicsPathCommand.LINE_TO;
				cmd[2] = GraphicsPathCommand.LINE_TO;
				cmd[3] = GraphicsPathCommand.LINE_TO;
				var ppt : Vector<Float> = new Vector<Float>(8);
				ppt[0] = 0;
				ppt[1] = nh;
				ppt[2] = nw;
				ppt[3] = 0;
				ppt[4] = nw;
				ppt[5] = nh;
				ppt[6] = 0;
				ppt[7] = nh;
				var cl : Int = r.color_gripper_;
				if ((state_ & Visel.STATE_DOWN) != 0)
				{
					cl = r.color_pressed_;
				}
				if ((state_ & Visel.STATE_HOVER) == 0)
				{
					Util.inflate_Vector(ppt, -r.hover_inflation_);
				}
				graphics.beginFill(cl & 0xffffff, al);
				graphics.drawPath(cmd, ppt);
				graphics.endFill();
			}
		}
	}
}

