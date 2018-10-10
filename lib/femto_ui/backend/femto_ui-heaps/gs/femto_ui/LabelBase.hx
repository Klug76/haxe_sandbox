package gs.femto_ui;

import h2d.Text;

using gs.femto_ui.RootBase.NativeUIContainer;

class LabelBase extends Visel
{
	private var text_field_ : Text;

	public function new(owner : NativeUIContainer)
	{
		super(owner);
	}
//.............................................................................
	private function init_Text_Field() : Void
	{
		//var r : Root = Root.instance;
		//var al: Label = cast this;
		text_field_ = new Text(hxd.res.DefaultFont.get(), this);
		//TODO fix me: alloc font!?
		//text_field_.defaultTextFormat = new TextFormat(null, Std.int(r.def_text_size_), r.color_ui_text_);
	}
//.............................................................................
	override public function draw_Visel() : Void
	{
		super.draw_Visel();
		var al: Label = cast this;
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_TEXT) != 0)
		{
			invalid_flags_ |= Visel.INVALIDATION_FLAG_ALIGN;
			if ((null == text_field_) && (al.text_ != null) && (al.text_.length > 0))
				init_Text_Field();//:alloc if have text only
			if (text_field_ != null)
				text_field_.text = al.safe_text;
		}
		if (null == text_field_)
			return;
		text_field_.maxWidth = width_;
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_ALIGN)) != 0)
		{
			var text_y : Float = 0;
			var text_h : Float = text_field_.textHeight;
			if (text_h > height_)
				text_h = height_;
			//TODO fix me: multi-line
			switch (al.h_align)
			{
				case Align.NEAR:
					text_field_.textAlign = h2d.Align.Left;
				case Align.CENTER:
					text_field_.textAlign = h2d.Align.Center;
				case Align.FAR:
					text_field_.textAlign = h2d.Align.Right;
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
			text_field_.y = Math.round(text_y);
		}
	}
}

