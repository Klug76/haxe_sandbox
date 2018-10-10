package gs.femto_ui;

import gs.femto_ui.kha.Event;
import gs.femto_ui.util.Util;
import kha.graphics2.Graphics;

class ThumbBase extends Visel
{
	//private var start_x_ : Float;
	private var start_y_ : Float;
	private var tap_id_: Int;

	public function new(owner : Scrollbar)
	{
		super(owner);
	}
//.............................................................................
	override private function init_Base() : Void
	{
		super.init_Base();
		hit_test_bits = ViselBase.HIT_TEST_FUNC;
		add_Listener(on_Event);
	}
//.............................................................................
	override private function destroy_Base(): Void
	{
		super.destroy_Base();
		remove_Listener(on_Event);
	}
//.............................................................................
	private function on_Event(ev: Event): Void
	{
		switch(ev.type)
		{
		case Event.MOUSE_DOWN:
			on_Mouse_Down(ev);
		case Event.MOUSE_IN:
			set_Hover_State(ev);
		case Event.MOUSE_OUT:
			remove_Hover_State(ev);
		}
	}
//.............................................................................
	private function on_Stage_Event(ev: Event): Void
	{
		switch(ev.type)
		{
		case Event.MOUSE_UP:
			on_Mouse_Up_Stage(ev);
		case Event.MOUSE_MOVE:
			on_Mouse_Move_Stage(ev);
		}
	}
//.............................................................................
	private function on_Mouse_Down(ev : Event) : Void
	{
		//flash.Lib.trace("thumb::on_Mouse_Down " + ev.globalX + ":" + ev.globalY);
		ev.stop_propagation = true;

		if ((state_ & Visel.STATE_DRAG) != 0)
			return;
		var p : Scrollbar = cast parent;
		var nh : Float = Math.floor(p.height - height_);
		if (nh <= 0)
		{//:unable to drag
			return;
		}

		state_ |= Visel.STATE_DRAG;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

		var r: Root = Root.instance;
		r.stage_.add_Listener(on_Stage_Event);

		tap_id_ = ev.input_id;
		//start_x_ = x - ev.globalX;
		start_y_ = y - ev.globalY;

		//flash.Lib.trace("thumb::start drag on " + tap_id_);
	}
//.............................................................................
	private function on_Mouse_Up_Stage(ev : Event) : Void
	{
		if ((state_ & Visel.STATE_DRAG) != 0)
		{
			if (tap_id_ != ev.input_id)
				return;
			state_ &= ~Visel.STATE_DRAG;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

			var r: Root = Root.instance;
			r.stage_.remove_Listener(on_Stage_Event);

			if (ev.target == this)
				ev.stop_propagation = true;

			if (parent != null)
			{
				var p : Scrollbar = cast parent;
				p.on_Thumb_Finish_Drag();
			}
			//flash.Lib.trace("thumb::stop drag on " + ev.inputId);
		}
	}
//.............................................................................
	private function on_Mouse_Move_Stage(ev : Event) : Void
	{
		if ((state_ & Visel.STATE_DRAG) != 0)
		{
			if (tap_id_ != ev.input_id)
				return;
			if (parent != null)
			{
				var p: Scrollbar = cast parent;

				var ny: Float = Util.fclamp(start_y_ + ev.globalY, 0, p.height - height_);
				y = ny;

				//flash.Lib.trace("thumb::do drag on " + ev.inputId);
				p.on_Thumb_Do_Drag();
			}
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	override private function render_Base_Background(gr: Graphics, nx: Float, ny: Float): Void
	{
		var al = dummy_alpha_;
		if (al >= 0)
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
					cl = r.color_pressed_;
				if ((state_ & Visel.STATE_HOVER) != 0)
					frame = r.hover_inflation_;
			}
			gr.color = Util.RGB_A(cl, al);
			gr.fillRect(nx - frame, ny - frame, width_ + 2 * frame, height_ + 2 * frame);
		}
	}
//.............................................................................
//.............................................................................
}
