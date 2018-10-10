package gs.femto_ui;

import gs.femto_ui.kha.Event;
import gs.femto_ui.util.Util;
import kha.graphics2.Graphics;

using gs.femto_ui.RootBase.NativeUIContainer;

class MoverBase extends Visel
{
	public function new(owner : NativeUIContainer)
	{
		super(owner);
	}
//.............................................................................
	override private function init_Base(): Void
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
		//case Event.MOUSE_UP:
			//on_Mouse_Up(ev);
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
//.............................................................................
	private function on_Mouse_Down(ev: Event): Void
	{
		ev.stop_propagation = true;

		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

		var m: Mover = cast this;
		m.handle_Tap(ev.input_id, ev.globalX, ev.globalY);

		var r: Root = Root.instance;
		r.stage_.add_Listener(on_Stage_Event);
	}
//.............................................................................
	private function on_Mouse_Up_Stage(ev: Event): Void
	{
		var m: Mover = cast this;
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			if (m.tap_id != ev.input_id)
				return;
			state_ &= ~Visel.STATE_DOWN;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

			var r: Root = Root.instance;
			r.stage_.remove_Listener(on_Stage_Event);

			if (ev.target == this)
				ev.stop_propagation = true;
		}
	}
//.............................................................................
	private function on_Mouse_Move_Stage(ev: Event): Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			var m: Mover = cast this;
			m.handle_Move(ev.input_id, ev.globalX, ev.globalY);
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	override private function render_Base_Background(gr: Graphics, nx: Float, ny: Float): Void
	{
		super.render_Base_Background(gr, nx, ny);
		var nw : Float = width_;
		var nh : Float = height_;
		var al: Float = dummy_alpha_;
		if ((al > 0) && (nw > 0) && (nh > 0))
		{
			var r: Root = Root.instance;
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
			gr.color = Util.RGB_A(cl, al);
			gr.fillTriangle(nx - offset, ny + nh * .5, nx + nw * .5, ny - offset,		nx + nw + offset, ny + nh * .5);
			gr.fillTriangle(nx - offset, ny + nh * .5, nx + nw * .5, ny + nh + offset,	nx + nw + offset, ny + nh * .5);
		}
	}
}

