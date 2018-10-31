package gs.femto_ui;

import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

using gs.femto_ui.RootBase.NativeUIContainer;

class EditBase extends Visel
{
	private var tf_ : TextField = null;
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
		tf_ = new TextField();
		tf_.type = TextFieldType.INPUT;
		tf_.defaultTextFormat = get_Default_Text_Format();
		tf_.selectable = get_Edit_Option(Edit.SELECTABLE);
		tf_.tabEnabled = get_Edit_Option(Edit.TAB_ENABLED);//?
#if flash
		tf_.condenseWhite = false;
#end
		tf_.width = width_;
		tf_.height = height_;
		invalid_flags_ &= ~Visel.INVALIDATION_FLAG_SIZE;

		if (on_changed_ != null)
			tf_.addEventListener(Event.CHANGE, on_Text_Changed);

		addChild(tf_);
	}
//.............................................................................
	private function on_Text_Changed(ev: Event): Void
	{
		on_changed_(tf_.text);
	}
//.............................................................................
	private function get_Default_Text_Format(): TextFormat
	{
		return new TextFormat(null, Std.int(Root.instance.input_text_size_));
	}
//.............................................................................
	private function get_Edit_Option(opt: Int): Bool
	{
		return true;
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
			tf_.width = width_;
			tf_.height = height_;
		}
	}
//.............................................................................
	//public function set_Focus(): Void
	//{
		//stage.focus = tf_;
	//}
//.............................................................................
}
//.............................................................................
//.............................................................................

