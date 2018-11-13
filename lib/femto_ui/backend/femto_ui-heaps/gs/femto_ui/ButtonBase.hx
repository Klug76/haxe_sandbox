package gs.femto_ui;

import h2d.Interactive;
import h2d.col.Point;
import hxd.Cursor;
import hxd.Event;

using gs.femto_ui.RootBase.NativeUIContainer;
//:________________________________________________________________________________________________
class ButtonBase extends Visel
{
	private var aux_pt_: Point = null;

	public function new(owner : NativeUIContainer)
	{
		super(owner);
	}
//.............................................................................
	override private function init_Base() : Void
	{
		super.init_Base();

		var ni: Interactive = alloc_Interactive(Cursor.Button);
		ni.onClick = on_Mouse_Click;
		ni.onPush = on_Mouse_Down;
		ni.onRelease = on_Mouse_Up;
		ni.onOver = set_Hover_State;
		ni.onOut = remove_Hover_State;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	override private function draw_Base_Background() : Void
	{
		//if (1100101 == tag_)
			//trace("***");
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SKIN | Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
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
				var bg = alloc_Background();
				bg.clear();
				bg.beginFill(cl & 0xFFffFF, al);
				//bg.drawRect( -frame, -frame, nw + 2 * frame, nh + 2 * frame);
				bg.drawRoundedRect(-frame, -frame, nw + 2 * frame, nh + 2 * frame, r.round_frame_);
				bg.endFill();
			}
			else
			{
				clear_Background();
			}
		}
		//:super.draw_Base_Background();
	}
//.............................................................................
//.............................................................................
//.............................................................................
	private function on_Mouse_Down(ev : Event) : Void
	{
		//trace("Button::" + ev.kind + ": " + ev.button + ": " + ev.touchId + ": " + ev.propagate);
		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

		ev.propagate = false;

		to_Global(ev.relX, ev.relY);
		var b: Button = cast this;
		//TODO fix me: ev.button vs ev.touchId
		b.handle_Tap(ev.button, aux_pt_.x, aux_pt_.y, ev.relX, ev.relY);
	}
//.............................................................................
	private function on_Mouse_Up(ev : Event) : Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			ev.propagate = false;

			state_ &= ~Visel.STATE_DOWN;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		}
	}
//.............................................................................
//.............................................................................
	private function on_Mouse_Click(ev : Event) : Void
	{
		if (!enable_interactive_)
			return;

		ev.propagate = false;

		to_Global(ev.relX, ev.relY);
		var b: Button = cast this;
		b.handle_Click(aux_pt_.x, aux_pt_.y, ev.relX, ev.relY);
	}
//.............................................................................
	private function to_Global(relX: Float, relY: Float) : Void
	{
		if (null == aux_pt_)
			aux_pt_ = new Point();
		aux_pt_.x = relX;
		aux_pt_.y = relY;
		localToGlobal(aux_pt_);
	}
//.............................................................................
}

