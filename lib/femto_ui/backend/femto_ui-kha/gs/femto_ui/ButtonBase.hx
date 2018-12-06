package gs.femto_ui;

import gs.femto_ui.kha.Event;
import kha.graphics2.Graphics;
import gs.femto_ui.util.Util;

using gs.femto_ui.RootBase.NativeUIContainer;
//:________________________________________________________________________________________________
class ButtonBase extends Visel
{
	public function new(owner : NativeUIContainer)
	{
		super(owner);
	}
//.............................................................................
	override private function init_Base(): Void
	{
		super.init_Base();
		//:hit_test_bits = ViselBase.HIT_TEST_FUNC;//:conflict with scrollbar etc
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
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	private function on_Mouse_Down(ev: Event): Void
	{
		//flash.Lib.trace("button::on_Mouse_Down " + ev.globalX + ":" + ev.globalY);
		ev.stop_propagation = true;

		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

		var b: Button = cast this;
		b.handle_Tap(ev.input_id, ev.globalX, ev.globalY, ev.targetX, ev.targetY);

		var r: Root = Root.instance;
		r.stage_.add_Listener(on_Stage_Event);
	}
//.............................................................................
	private function on_Mouse_Up_Stage(ev: Event): Void
	{
		var b: Button = cast this;
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			if (b.tap_id != ev.input_id)
				return;
			state_ &= ~Visel.STATE_DOWN;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

			var r: Root = Root.instance;
			r.stage_.remove_Listener(on_Stage_Event);

			if (ev.target == this)
			{
				ev.stop_propagation = true;
				//flash.Lib.trace("button::on_Mouse_Up " + ev.globalX + ":" + ev.globalY);
				b.handle_Click(ev.globalX, ev.globalY, ev.targetX, ev.targetY);
			}
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	override function render_Base(gr: Graphics, nx: Float, ny: Float): Void
	{
		render_Button_Background(gr, nx, ny);
		render_Children(gr, nx, ny);
	}
//.............................................................................
	private function render_Button_Background(gr: Graphics, nx: Float, ny: Float): Void
	{
		var nw : Float = width_;
		var nh : Float = height_;
		var al = dummy_alpha_;
		if ((al > 0) && (nw > 0) && (nh > 0))
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
			gr.color = Util.RGB_A(cl, al);
			gr.fillRect(nx - frame, ny - frame, width_ + 2 * frame, height_ + 2 * frame);
		}
	}
//.............................................................................
//.............................................................................
}

