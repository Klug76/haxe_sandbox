package gs.femto_ui;

import gs.femto_ui.kha.TextInputLine;

using gs.femto_ui.RootBase.NativeUIContainer;

class EditBase extends Visel
{
	private var tf_ : TextInputLine = null;
	private var text_: String;
	private var on_changed_: String->Void;

	public function new(owner: NativeUIContainer, on_Changed: String->Void, txt: String = null)
	{
		super(owner);
		text_ = txt;
		on_changed_ = on_Changed;
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
		tf_ = new TextInputLine(this);
		tf_.width = width_;
		tf_.height = height_;
		invalid_flags_ &= ~Visel.INVALIDATION_FLAG_SIZE;

		if (on_changed_ != null)
			tf_.on_Change = on_Text_Changed;
	}
//.............................................................................
	private function on_Text_Changed(): Void
	{
		on_changed_(tf_.text);
	}
//.............................................................................
	//private function get_Default_Text_Format(): TextFormat
	//{
		//return new TextFormat(null, Std.int(Root.instance.input_text_size_));
	//}
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
			tf_.width = width_;
			tf_.height = height_;
		}
	}
//.............................................................................
//.............................................................................
}
//.............................................................................
//.............................................................................

