package gs.femto_ui;

import gs.femto_ui.kha.Event;
import kha.graphics2.Graphics;
import kha.Color;
import kha.input.Mouse;

using gs.femto_ui.RootBase.NativeUIContainer;
//:________________________________________________________________________________________________
class ButtonBase extends Visel
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
		//TODO review: how to avoid this?
		var r: Root = Root.instance;
		r.stage_.add_Listener(on_Stage_Event);
	}
//.............................................................................
	override private function destroy_Base(): Void
	{
		super.destroy_Base();
		remove_Listener(on_Event);
		var r: Root = Root.instance;
		r.stage_.remove_Listener(on_Stage_Event);
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
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	private function on_Mouse_Down(ev: Event): Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

		ev.stop_propagation = true;

		var b: Button = cast this;
		b.handle_Tap(ev.inputId, ev.globalX, ev.globalY);
	}
//.............................................................................
	private function on_Mouse_Up(ev: Event): Void
	{
		var b: Button = cast this;
		if (b.tap_id != ev.inputId)
			return;
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			state_ &= ~Visel.STATE_DOWN;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

			if (ev.target == this)
			{
				ev.stop_propagation = true;
				b.handle_Click(ev.globalX, ev.globalY);
			}
		}
	}
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
//.............................................................................
//.............................................................................
	override public function render_To(gr: Graphics, nx: Float, ny: Float): Void
	{
		if (!visible)
			return;
		nx += x;
		ny += y;
		render_Button_Background(gr, nx, ny);
		render_Children(gr, nx, ny);
	}
//.............................................................................
	private function render_Button_Background(gr: Graphics, nx: Float, ny: Float): Void
	{
		var r : Root = Root.instance;
		var b: Button = cast this;
		var al = dummy_alpha_;
		if (al >= 0)
		{
			var color : Int = dummy_color_;
			var frame : Float = 0;
			if ((state_ & Visel.STATE_DISABLED) != 0)
			{
				color = r.color_disabled_;
			}
			else
			{
				if ((state_ & Visel.STATE_DOWN) != 0)
					color = r.color_pressed_;
				if ((state_ & Visel.STATE_HOVER) != 0)
					frame = b.hover_inflation_;
			}
			var cl: Color = color;
			cl.A = al;
			gr.color = cl;
			gr.fillRect(nx - frame, ny - frame, width_ + 2 * frame, height_ + 2 * frame);
		}
	}
//.............................................................................
//.............................................................................
}

