package gs.femto_ui;

import h2d.Interactive;
import hxd.Cursor;
import hxd.Event;

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
		alloc_Interactive(Cursor.Button);

		var ni: Interactive = interactive_;
		ni.onClick = on_Mouse_Click;
		ni.onOver = on_Mouse_Over;
		ni.onOut = on_Mouse_Out;
		ni.onPush = on_Mouse_Down;
		ni.onRelease = on_Mouse_Up;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	override public function draw_Visel() : Void
	{
		//if (1100101 == tag_)
			//trace("***");
		var r : Root = Root.instance;
		var b: Button = cast this;
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SKIN | Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			var al = b.dummy_alpha_;
			if (al >= 0)
			{
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
						frame = b.hover_inflation_;
				}
				cl &= 0xFFffFF;
				var bg = alloc_Background();
				bg.clear();
				bg.beginFill(cl, al);
				//bg.drawRoundRect(-frame, -frame, width_ + 2 * frame, height_ + 2 * frame, r.round_frame_, r.round_frame_);
				bg.drawRect(-frame, -frame, width_ + 2 * frame, height_ + 2 * frame);
				bg.endFill();
			}
			else
			{
				clear_Background();
			}
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			var al: Label = b.label;
			if ((state_ & Visel.STATE_DOWN) != 0)
			{
				al.movesize_(r.content_down_offset_x_, r.content_down_offset_y_,
						width_ + r.content_down_offset_x_, height_ + r.content_down_offset_y_);
			}
			else
			{
				al.movesize_(0, 0, width_, height_);
			}
			al.draw_Visel();
			al.validate();
		}
		draw_Interactive();
	}
//.............................................................................
//.............................................................................
//.............................................................................
	private function on_Mouse_Down(ev : Event) : Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;

		ev.propagate = false;

		var b: Button = cast this;
		b.handle_Tap(ev.relX, ev.relY);
	}
//.............................................................................
	private function on_Mouse_Up(ev : Event) : Void
	{
		if (disposed)
			return;

		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			ev.propagate = false;

			state_ &= ~Visel.STATE_DOWN;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		}
	}
//.............................................................................
	private function on_Mouse_Over(ev : Event) : Void
	{
		if ((state_ & Visel.STATE_HOVER) != 0)
			return;
		state_ |= Visel.STATE_HOVER;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
	}
//.............................................................................
	private function on_Mouse_Out(ev : Event) : Void
	{
		if ((state_ & Visel.STATE_HOVER) == 0)
			return;
		state_ &= ~Visel.STATE_HOVER;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
	}
//.............................................................................
	private function on_Mouse_Click(ev : Event) : Void
	{
		//trace("button::click '" + label_.text + "', target=" + e.target);
		//trace("_______");
		if (!enable_interactive_)
			return;

		ev.propagate = false;

		var b: Button = cast this;
		b.handle_Click(ev.relX, ev.relY);
	}
//.............................................................................
}

