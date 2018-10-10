package gs.femto_ui;


import gs.femto_ui.util.Util;
import h2d.Interactive;
import h2d.Scene;
import hxd.Cursor;
import hxd.Event;

using gs.femto_ui.RootBase.NativeUIContainer;

class ThumbBase extends Visel
{
	private var cur_scene_: Scene = null;
	private var drag_enter_: Bool = false;

	//private var start_x_ : Float;
	private var start_y_ : Float;

	public function new(owner : Scrollbar)
	{
		super(owner);
	}
//.............................................................................
	override private function init_Base() : Void
	{
		super.init_Base();

		var ni: Interactive = alloc_Interactive(Cursor.Button);
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
		//trace("thumb::" + ev.kind + ": " + ev.button + ": " + ev.touchId + ": " + ev.propagate);
		if ((state_ & Visel.STATE_DRAG) != 0)
			return;
		state_ |= Visel.STATE_DRAG;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

		ev.propagate = false;

		drag_enter_ = false;
		cur_scene_ = Root.instance.scene_;
		cur_scene_.startDrag(on_Mouse_Move, null, ev);
	}
//.............................................................................
	private function on_Mouse_Up(ev : Event) : Void
	{
		if ((state_ & Visel.STATE_DRAG) != 0)
		{
			state_ &= ~Visel.STATE_DRAG;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

			ev.propagate = false;
			stop_Drag();

			if (parent != null)
			{
				var p : Scrollbar = cast parent;
				p.on_Thumb_Finish_Drag();
			}
		}
	}
//.............................................................................
	private function on_Mouse_Move(ev : Event) : Void
	{
		if ((state_ & Visel.STATE_DRAG) != 0)
		{
			ev.propagate = false;

			if (parent != null)
			{
				var p : Scrollbar = cast parent;

				if (!drag_enter_)
				{
					drag_enter_ = true;
					//start_x_ = x - ev.globalX;
					start_y_ = y - ev.relY;
				}
				else
				{
					var ny: Float = Util.fclamp(start_y_ + ev.relY, 0, p.height - height_);
					y = ny;

					p.on_Thumb_Do_Drag();
				}
			}
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
	override private function draw_Base_Background() : Void
	{
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SKIN | Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			var nw : Float = width_;
			var nh : Float = height_;
			var al : Float = dummy_alpha_;
			if ((al >= 0) && (nw > 0) && (nh > 0))
			{
				var r : Root = Root.instance;
				var cl : Int = dummy_color_;
				var frame: Float = 0;
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
				var bg = alloc_Background();
				bg.clear();
				bg.beginFill(cl & 0xFFffFF, al);
				//TODO bg.drawRoundRect
				bg.drawRect(-frame, -frame, nw + 2 * frame, nh + 2 * frame);
				bg.endFill();
			}
			else
			{
				clear_Background();
			}
		}
		//:super.draw_Base_Background();
	}
}

