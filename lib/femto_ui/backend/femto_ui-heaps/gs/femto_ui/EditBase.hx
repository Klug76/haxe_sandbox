package gs.femto_ui;

import h2d.Font;
import h2d.TextInput;

using gs.femto_ui.RootBase.NativeUIContainer;

class EditBase extends Visel
{
	private var tf_ : TextInput = null;
	private var text_: String;

	public function new(owner: NativeUIContainer, txt: String = null)
	{
		super(owner);
		text_ = txt;
		invalidate_Visel(Visel.INVALIDATION_FLAG_TEXT);
	}
//.............................................................................
	private function get_Base_Text(): String
	{
		if (tf_ != null)
			return tf_.text;//:actual
		if (text_ != null)
			return text_;
		return "";
	}
//.............................................................................
	private function set_Base_Text(value: String): Void
	{
		if (tf_ != null)
		{
			tf_.text = value;
			return;
		}
		text_ = value;
	}
//.............................................................................
	private function alloc_TextField(): Void
	{
		tf_ = new TextInput(get_Default_Font(), this);
		tf_.inputWidth = Math.round(width_);
		//?tf_.height = height_;
		invalid_flags_ &= ~Visel.INVALIDATION_FLAG_SIZE;

		tf_.onChange = on_Text_Changed;
	}
//.............................................................................
	private function on_Text_Changed(): Void
	{
		var ed: Edit = cast this;
		ed.on_Changed(tf_.text);
	}
//.............................................................................
	private function get_Default_Font(): Font
	{
		//TODO fix me:
		return hxd.res.DefaultFont.get();
		//return new TextFormat(null, Std.int(Root.instance.input_text_size_));
	}
//.............................................................................
//.............................................................................
//.............................................................................
	override public function draw_Visel(): Void
	{
		super.draw_Visel();
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_TEXT) != 0)
		{
			if (null == tf_)
				alloc_TextField();
			if (text_ != null)
			{
				tf_.text = text_;
				text_ = null;
			}
		}
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
		{
			tf_.inputWidth = Math.round(width_);
			//?tf_.height = height_;
		}
	}
//.............................................................................
	//public function set_Focus(): Void
	//{
		//TODO fix me
	//}
//.............................................................................
}
//.............................................................................
//.............................................................................

