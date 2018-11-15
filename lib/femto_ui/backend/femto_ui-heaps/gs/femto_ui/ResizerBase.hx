package gs.femto_ui;


import h2d.Interactive;
import h2d.Scene;
import hxd.Cursor;
import hxd.Event;

using gs.femto_ui.RootBase.NativeUIContainer;

class ResizerBase extends Visel
{
	private var cur_scene_: Scene = null;
	private var drag_enter_: Bool = false;

	public function new(owner : NativeUIContainer)
	{
		super(owner);
	}
//.............................................................................
	override private function init_Base() : Void
	{
		super.init_Base();

		var ni: Interactive = alloc_Interactive(Cursor.Button, true);
		ni.onPush = on_Mouse_Down;
		ni.onRelease = on_Mouse_Up;
		ni.onOver = set_Hover_State;
		ni.onOut = remove_Hover_State;
		//:ni.onMove = on_Mouse_Move;
	}
//.............................................................................
	override private function destroy_Base() : Void
	{
		super.destroy_Base();
		stop_Drag();
	}
//.............................................................................
	private function stop_Drag() : Void
	{
		if (cur_scene_ != null)
		{
			cur_scene_.stopDrag();
			cur_scene_ = null;
		}
	}
//.............................................................................
	private function on_Mouse_Down(ev : Event) : Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

		set_Event_Handled(ev);

		drag_enter_ = false;
		cur_scene_ = Root.instance.scene_;
		cur_scene_.startDrag(on_Mouse_Move, null, ev);
	}
//.............................................................................
	private function on_Mouse_Up(ev : Event) : Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			state_ &= ~Visel.STATE_DOWN;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

			set_Event_Handled(ev);

			stop_Drag();
		}
	}
//.............................................................................
	private function on_Mouse_Move(ev : Event) : Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			set_Event_Handled(ev);

			var rz: Resizer = cast this;
			if (!drag_enter_)
			{
				drag_enter_ = true;
				rz.handle_Tap(ev.button, ev.relX, ev.relY);
			}
			else
			{
				rz.handle_Move(ev.button, ev.relX, ev.relY);
			}
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
	override public function draw_Visel() : Void
	{
		draw_Base_Background();
		draw_Interactive();
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SKIN | Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			var nw : Float = width_;
			var nh : Float = height_;
			var al : Float = dummy_alpha_;
			if ((al > 0) && (nw > 0) && (nh > 0))
			{
				var r : Root = Root.instance;
				var cl : Int = r.color_gripper_;
				var offset: Float = 0;
				if ((state_ & Visel.STATE_DOWN) != 0)
				{
					cl = r.color_pressed_;
				}
				if ((state_ & Visel.STATE_HOVER) == 0)
				{
					offset = -r.hover_inflation_;
				}
				var bg = alloc_Background();
				bg.beginFill(cl & 0xffffff, al);
				bg.moveTo(-offset, nh + offset);
				bg.lineTo(nw + offset, -offset);
				bg.lineTo(nw + offset, nh + offset);
				bg.lineTo(-offset, nh + offset);
				bg.endFill();
			}
		}
		//:super.draw_Visel();
	}
}

