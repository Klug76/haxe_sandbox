package com.gs.femto_ui;

import com.gs.console.Util;
import flash.Vector;
import flash.display.DisplayObjectContainer;
import flash.display.GraphicsPathCommand;
import flash.events.MouseEvent;

class Mover extends Visel
{
	private var start_x_ : Float;
	private var start_y_ : Float;

	public function new(owner : DisplayObjectContainer)
	{
		super(owner);
		init();
	}
	//.............................................................................
	private function init() : Void
	{
		buttonMode = true;
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down, false, 0, true);
		addEventListener(MouseEvent.ROLL_OVER, on_Mouse_Over, false, 0, true);
	}
	//.............................................................................
	private function on_Mouse_Down(e : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			return;
		}
		state_ |= Visel.STATE_DOWN;
		e.stopPropagation();
		start_x_ = parent.x - e.stageX;
		start_y_ = parent.y - e.stageY;
		invalidate(Visel.INVALIDATION_FLAG_STATE);
		stage.addEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage, false, 1);  //:set capture
		stage.addEventListener(MouseEvent.MOUSE_MOVE, on_Mouse_Move_Stage, false, 1);
	}
	//.............................................................................
	private function on_Mouse_Up_Stage(e : MouseEvent) : Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_UP, on_Mouse_Up_Stage);
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, on_Mouse_Move_Stage);
		if (disposed)
		{
			return;
		}
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			state_ &= ~Visel.STATE_DOWN;
			e.stopPropagation();
			invalidate(Visel.INVALIDATION_FLAG_STATE);
		}
	}
	//.............................................................................
	private function on_Mouse_Move_Stage(e : MouseEvent) : Void
	{
		if (disposed)
		{
			return;
		}
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			e.stopPropagation();
			var r : Root = Root.instance;
			parent.x = Util.fclamp(start_x_ + e.stageX, 0, stage.stageWidth - r.tool_width_ * .5);
			parent.y = Util.fclamp(start_y_ + e.stageY, 0, stage.stageHeight - r.tool_height_ * .5);
		}
	}
	//.............................................................................
	private function on_Mouse_Over(e : MouseEvent) : Void
	{
		if ((state_ & Visel.STATE_HOVER) != 0)
		{
			return;
		}
		state_ |= Visel.STATE_HOVER;
		invalidate(Visel.INVALIDATION_FLAG_STATE);
		addEventListener(MouseEvent.ROLL_OUT, on_Mouse_Out, false, 0, true);
	}
	//.............................................................................
	private function on_Mouse_Out(e : MouseEvent) : Void
	{
		state_ &= ~Visel.STATE_HOVER;
		invalidate(Visel.INVALIDATION_FLAG_STATE);
		removeEventListener(MouseEvent.ROLL_OUT, on_Mouse_Out);
	}
	//.............................................................................
	//.............................................................................
	//.............................................................................
	override public function draw() : Void
	{
		super.draw();
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SKIN | Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			var nw : Float = width_;
			var nh : Float = height_;
			if ((dummy_alpha_ > 0) && (nw > 0) && (nh > 0))
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
					Util.Offset_Path(ppt, -r.hover_inflation_);
				}

				graphics.beginFill(cl & 0xffffff, dummy_alpha_);
				graphics.drawPath(cmd, ppt);
				graphics.endFill();
			}
		}
	}
}

