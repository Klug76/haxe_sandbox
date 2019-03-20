package gs.femto_ui;

import kha.graphics2.Graphics;
import kha.Font;

using gs.femto_ui.RootBase.NativeUIContainer;

class LabelBase extends Visel
{
	private var fname_: String = null;//TODO fix me
	private var fsize_: Int = 0;
	private var fcolor_: Int = 0;

	public function new(owner : NativeUIContainer)
	{
		super(owner);
		hit_test_bits = ViselBase.HIT_TEST_NONE;
	}
//.............................................................................
//.............................................................................
	public function set_Text_Format_Base(fname: String, fsize: Int, fcolor: Int): Void
	{
		fname_ = fname;
		fsize_ = fsize;
		fcolor_ = fcolor;
	}
//.............................................................................
//.............................................................................
	override function render_Base(gr: Graphics, nx: Float, ny: Float) : Void
	{
		render_Base_Background(gr, nx, ny);
		render_Text(gr, nx, ny);
		render_Children(gr, nx, ny);
	}
//.............................................................................
	private function render_Text(gr: Graphics, nx: Float, ny: Float) : Void
	{
		var al: Label = cast this;
		if ((null == al.text_) || (al.text_.length <= 0))
			return;
		var r: Root = Root.instance;
		var font: Font = r.font_;//TODO fix me
		var font_size: Int = fsize_;
		if (0 == font_size)
		{
			font_size = Std.int(r.def_font_size_);
			fcolor_ = r.color_ui_text_;
		}
		var text_x: Float = 0;
		var text_y: Float = 0;
		var text: String = al.safe_text;
		if (al.align_ != 0)
		{
			var text_w: Float = font.width(font_size, text);
			var text_h: Float = font.height(font_size);
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
		gr.color = fcolor_ | 0xFF000000;
		gr.drawString(text, Math.round(nx + text_x), Math.round(ny + text_y));
	}
}

