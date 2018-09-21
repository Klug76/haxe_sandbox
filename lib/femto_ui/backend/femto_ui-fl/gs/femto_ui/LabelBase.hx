package gs.femto_ui;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

using gs.femto_ui.RootBase.NativeUIContainer;

class LabelBase extends Visel
{
	private var text_field_ : TextField;
	private var text_size_valid_for_ : Float = 0;
	private var text_width_ : Float = 0;
	private var text_height_ : Float = 0;

	public function new(owner : NativeUIContainer)
	{
		super(owner);
		mouseEnabled = mouseChildren = false;
		tabEnabled = false;
	}
//.............................................................................
	private function init_Text_Field() : Void
	{
		var r : Root = Root.instance;
		text_field_ = new TextField();
		text_field_.type = TextFieldType.DYNAMIC;
		text_field_.defaultTextFormat = new TextFormat(null, Std.int(r.def_text_size_), r.color_ui_text_);
		text_field_.selectable = false;
		//text_field_.background = true;
		//text_field_.backgroundColor = 0xc080f0;
		addChild(text_field_);
	}
//.............................................................................
	override public function draw_Visel() : Void
	{
		super.draw_Visel();
		var al: Label = cast this;
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_DATA) != 0)
		{
			text_size_valid_for_ = 0;
			invalid_flags_ |= Visel.INVALIDATION_FLAG_ALIGN;
			if ((null == text_field_) && (al.text_ != null) && (al.text_.length > 0))
				init_Text_Field();//:alloc if have text only
			if (text_field_ != null)
				text_field_.text = al.safe_text;
		}
		if (null == text_field_)
			return;
		if ((text_size_valid_for_ != width_) && (al.align_ != 0))
		{
			text_size_valid_for_ = width_;
			text_field_.width = width_;
			text_field_.autoSize = TextFieldAutoSize.LEFT;
			text_width_ = text_field_.width;
			text_height_ = text_field_.height;
			text_field_.autoSize = TextFieldAutoSize.NONE;
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_ALIGN)) != 0)
		{
			var text_x : Float = 0;
			var text_y : Float = 0;
			var text_w : Float = text_width_;
			var text_h : Float = text_height_;
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
			text_field_.x = Math.round(text_x);
			text_field_.y = Math.round(text_y);
		}
	}
}

