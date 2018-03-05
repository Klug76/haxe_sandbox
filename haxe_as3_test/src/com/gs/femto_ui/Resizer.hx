package com.gs.femto_ui;

import com.gs.console.Util;
import flash.Vector;
import flash.display.DisplayObjectContainer;
import flash.display.GraphicsPathCommand;
import flash.events.MouseEvent;

class Resizer extends Visel
{
    private var start_w_ : Float;
    private var start_h_ : Float;

    public var min_width_ : Float = 0;
    public var min_height_ : Float = 0;

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
        start_w_ = parent.width - e.stageX;
        start_h_ = parent.height - e.stageY;
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
            parent.width = Util.fclamp(start_w_ + e.stageX, min_width_, stage.stageWidth);
            parent.height = Util.fclamp(start_h_ + e.stageY, min_height_, stage.stageHeight);
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
			//if (1100101 == tag_)
				//trace("Resizer::draw");
            var nw : Float = width_;
            var nh : Float = height_;
            if ((dummy_alpha_ > 0) && (nw > 0) && (nh > 0))
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
                    Util.Offset_Path(ppt, -r.hover_inflation_);
                }

                graphics.beginFill(cl & 0xffffff, dummy_alpha_);
                graphics.drawPath(cmd, ppt);
                graphics.endFill();
            }
        }
    }
}

