package gs.femto_ui;


import flash.display.GraphicsPathCommand;
import flash.events.MouseEvent;
import flash.Vector;
import gs.femto_ui.util.Util;

using gs.femto_ui.RootBase.NativeUIContainer;

class MoverBase extends Visel
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

		var m: Mover = cast this;
		m.handle_Tap(ev.stageX, ev.stageY);
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
			var m: Mover = cast this;
			m.handle_Move(ev.stageX, ev.stageY);
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
			var nw : Float = width_;
			var nh : Float = height_;
			var al : Float = dummy_alpha_;
			if ((al >= 0) && (nw > 0) && (nh > 0))
			{
				var r : Root = Root.instance;
				var cmd : Vector<Int> = new Vector<Int>(5);
				cmd[0] = GraphicsPathCommand.MOVE_TO;
				cmd[1] = GraphicsPathCommand.LINE_TO;
				cmd[2] = GraphicsPathCommand.LINE_TO;
				cmd[3] = GraphicsPathCommand.LINE_TO;
				cmd[4] = GraphicsPathCommand.LINE_TO;
				var ppt : Vector<Float> = new Vector<Float>(10);
				ppt[0] = 0;
				ppt[1] = nh * .5;
				ppt[2] = nw * .5;
				ppt[3] = 0;
				ppt[4] = nw;
				ppt[5] = nh * .5;
				ppt[6] = nw * .5;
				ppt[7] = nh;
				ppt[8] = 0;
				ppt[9] = nh * .5;
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

