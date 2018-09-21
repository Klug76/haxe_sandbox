package gs.femto_ui;

import kha.graphics2.Graphics;
import kha.Font;
import kha.Color;

using gs.femto_ui.RootBase.NativeUIContainer;

class LabelBase extends Visel
{
	public function new(owner : NativeUIContainer)
	{
		super(owner);
	}
//.............................................................................
//.............................................................................
//.............................................................................
	override public function render_To(gr: Graphics, nx: Float, ny: Float) : Void
	{
		if (!visible)
			return;
		nx += x;
		ny += y;
		update_Last_Coords(nx, ny);
		render_Base(gr, nx, ny);
		render_Text(gr, nx, ny);
		render_Children(gr, nx, ny);
	}
//.............................................................................
	private function render_Text(gr: Graphics, nx: Float, ny: Float) : Void
	{
		var r : Root = Root.instance;
		var al: Label = cast this;
		if ((null == al.text_) || (al.text_.length <= 0))
			return;
		var font: Font = r.font_;
		var font_size: Int = Std.int(r.def_text_size_);
		var text_x : Float = 0;
		var text_y : Float = 0;
		var text: String = al.safe_text;
		if (al.align_ != 0)
		{
			var text_w : Float = font.width(font_size, text);
			var text_h : Float = font.height(font_size);
			if (text_w > width_)
				text_w = width_;
			if (text_h > height_)
				text_h = height_;
			switch (al.h_align)
			{
				case Align.NEAR:
					//nop
				case Align.CENTER:
					text_x = (width_ - text_w) * 0.5;
				case Align.FAR:
					text_x = width_ - text_w;
			}
			switch (al.v_align)
			{
				case Align.NEAR:
					//nop
				case Align.CENTER:
					text_y = (height_ - text_h) * 0.5;
				case Align.FAR:
					text_y = height_ - text_h;
			}
		}
		gr.font = font;
		gr.fontSize = font_size;
		gr.color = Color.fromValue(r.color_ui_text_ | 0xFF000000);
		gr.drawString(text, nx + text_x, ny + text_y);

	}
}
