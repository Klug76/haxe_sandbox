package gs.femto_ui;

import kha.Color;
import kha.graphics2.Graphics;
import kha.input.Mouse;

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
		Mouse.get().notify(on_Mouse_Down, on_Mouse_Up, on_Mouse_Move, null);
	}
//.............................................................................
	override private function destroy_Base(): Void
	{
		Mouse.get().remove(on_Mouse_Down, on_Mouse_Up, on_Mouse_Move, null);
		super.destroy_Base();
	}
//.............................................................................
//.............................................................................
	private function on_Mouse_Down(button: Int, mouseX: Int, mouseY: Int): Void
	{
		if (!hit_Test(mouseX, mouseY))
			return;
		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;

		var m: Mover = cast this;
		m.handle_Tap(mouseX, mouseY);
	}
//.............................................................................
	private function on_Mouse_Up(button: Int, mouseX: Int, mouseY: Int): Void
	{
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			state_ &= ~Visel.STATE_DOWN;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		}
	}
//.............................................................................
	private function on_Mouse_Move(mouseX: Int, mouseY: Int, mx: Int, my: Int): Void
	{
		if (disposed)
			return;
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			var m: Mover = cast this;
			m.handle_Move(mouseX, mouseY);
		}
		if (hit_Test(mouseX, mouseY))
		{
			if ((state_ & Visel.STATE_HOVER) != 0)
				return;
			state_ |= Visel.STATE_HOVER;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		}
		else
		{
			if ((state_ & Visel.STATE_HOVER) == 0)
				return;
			state_ &= ~Visel.STATE_HOVER;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		}
	}
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

