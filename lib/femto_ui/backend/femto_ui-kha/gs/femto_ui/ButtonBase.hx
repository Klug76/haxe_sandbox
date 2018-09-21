package gs.femto_ui;

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
	}
//.............................................................................
	inline private function init_Base() : Void
	{}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	private function add_Mouse_Listeners() : Void
	{
		Mouse.get().notify(on_Mouse_Down, on_Mouse_Up, on_Mouse_Move, null);
	}
//.............................................................................
	private function on_Mouse_Down(button: Int, mouseX: Int, mouseY: Int) : Void
	{
		if (!hit_Test(mouseX, mouseY))
			return;
		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;

		var b: Button = cast this;
		b.handle_Tap(mouseX - last_x_, mouseY - last_y_);//TODO fix me: button | tap id
	}
//.............................................................................
	private function on_Mouse_Up(button: Int, mouseX: Int, mouseY: Int) : Void
	{
		if (disposed)
			return;
		if ((state_ & Visel.STATE_DOWN) != 0)
		{
			state_ &= ~Visel.STATE_DOWN;
			invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
			if (hit_Test(mouseX, mouseY))
			{
				var b: Button = cast this;
				b.handle_Click(mouseX - last_x_, mouseY - last_y_);
			}
		}
	}
//.............................................................................
	private function on_Mouse_Move(mouseX: Int, mouseY: Int, mx: Int, my: Int) : Void
	{
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
	override public function draw_Visel() : Void
	{
		var r: Root = Root.instance;
		var b: Button = cast this;
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			var al: Label = b.label;
			if ((state_ & Visel.STATE_DOWN) != 0)
			{
				al.movesize(r.content_down_offset_x_, r.content_down_offset_y_,
						width_ + r.content_down_offset_x_, height_ + r.content_down_offset_y_);
			}
			else
			{
				al.movesize(0, 0, width_, height_);
			}
		}
	}
//.............................................................................
	override public function render_To(gr: Graphics, nx: Float, ny: Float) : Void
	{
		if (!visible)
			return;
		nx += x;
		ny += y;
		update_Last_Coords(nx, ny);
		render_Button_Background(gr, nx, ny);
		render_Children(gr, nx, ny);
	}
//.............................................................................
	private function render_Button_Background(gr: Graphics, nx: Float, ny: Float) : Void
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

