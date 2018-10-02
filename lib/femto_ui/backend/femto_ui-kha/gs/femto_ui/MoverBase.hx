package gs.femto_ui;

import gs.femto_ui.kha.Event;
import kha.Color;
import kha.graphics2.Graphics;
import kha.input.Mouse;

using gs.femto_ui.RootBase.NativeUIContainer;

class MoverBase extends Visel
{
	public function new(owner : NativeUIContainer)
	{
		super(owner);
		hit_test_bits = ViselBase.HIT_TEST_RECT;
	}
//.............................................................................
	override private function init_Base(): Void
	{
		super.init_Base();
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
		case Event.MOUSE_UP:
			on_Mouse_Up(ev);
		case Event.MOUSE_IN:
			on_Mouse_In(ev);
		case Event.MOUSE_OUT:
			on_Mouse_Out(ev);
		}
	}
//.............................................................................
	private function on_Stage_Event(ev: Event): Void
	{
		switch(ev.type)
		{
		case Event.MOUSE_UP:
			on_Mouse_Up(ev);
		case Event.MOUSE_MOVE:
			on_Mouse_Move(ev);
		}
	}
//.............................................................................
//.............................................................................
	private function on_Mouse_Down(ev: Event): Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;

		var m: Mover = cast this;
		m.handle_Tap(ev.inputId, ev.globalX, ev.globalY);

		var r: Root = Root.instance;
		r.stage_.add_Listener(on_Stage_Event);
	}
//.............................................................................
	private function on_Mouse_Up(ev: Event): Void
	{
		var m: Mover = cast this;
		if (m.tap_id != ev.inputId)
			return;
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			state_ &= ~Visel.STATE_DOWN;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

			var r: Root = Root.instance;
			r.stage_.remove_Listener(on_Stage_Event);
		}
	}
//.............................................................................
	private function on_Mouse_Move(ev: Event): Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			var m: Mover = cast this;
			m.handle_Move(ev.inputId, ev.globalX, ev.globalY);
		}
	}
//.............................................................................
//.............................................................................
	private function on_Mouse_In(_): Void
	{
		if ((state_ & Visel.STATE_HOVER) != 0)
			return;
		state_ |= Visel.STATE_HOVER;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
	}
//.............................................................................
	private function on_Mouse_Out(_): Void
	{
		if ((state_ & Visel.STATE_HOVER) == 0)
			return;
		state_ &= ~Visel.STATE_HOVER;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
	}
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
			var u : Int = r.color_gripper_;
			var offset: Float = 0;
			if ((state_ & Visel.STATE_DOWN) != 0)
			{
				u = r.color_pressed_;
			}
			if ((state_ & Visel.STATE_HOVER) != 0)
			{
				offset = r.hover_inflation_;
			}
			var cl: Color = u;
			cl.A = al;
			gr.color = cl;
			gr.fillTriangle(nx - offset, ny + nh * .5, nx + nw * .5, ny - offset,		nx + nw + offset, ny + nh * .5);
			gr.fillTriangle(nx - offset, ny + nh * .5, nx + nw * .5, ny + nh + offset,	nx + nw + offset, ny + nh * .5);
		}
	}
}

