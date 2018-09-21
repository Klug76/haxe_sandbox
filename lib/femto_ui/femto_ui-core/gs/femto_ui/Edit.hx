package gs.femto_ui;

import flash.display.DisplayObjectContainer;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

class Edit extends Visel
{
	public var text_Field(get, never) : TextField;
	public var text(get, set) : String;

	private var tf_ : TextField;

	public function new(owner : DisplayObjectContainer, txt : String = "")
	{
		super(owner);
		init_Ex(txt);
	}
//.............................................................................
	private function init_Ex(txt : String) : Void
	{
#if debug
		name = "edit";
#end
		tf_ = new TextField();
		tf_.type = TextFieldType.INPUT;
		tf_.defaultTextFormat = get_Default_Text_Format();
		tf_.selectable = true;
		tf_.mouseEnabled = true;
		tf_.tabEnabled = false;//?
#if flash
		tf_.condenseWhite = false;
#end
		tf_.width = width_;
		tf_.height = height_;

		tf_.text = txt;

		addChild(tf_);
	}
//.............................................................................
	public function get_Default_Text_Format() : TextFormat
	{
		return new TextFormat(null, Std.int(Root.instance.input_text_size_));
	}
//.............................................................................
	private function get_text_Field() : TextField
	{
		return tf_;
	}
//.............................................................................
	//textField.maxChars
	//textField.restrict
	//textField.displayAsPassword
//.............................................................................
	override public function draw_Visel() : Void
	{
		super.draw_Visel();
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
		{
			tf_.width = width_;
			tf_.height = height_;
		}
	}
//.............................................................................
	public function set_Focus() : Void
	{
		stage.focus = tf_;
	}
//.............................................................................
	private function get_text() : String
	{
		return tf_.text;
	}
	private function set_text(value : String) : String
	{
		if (tf_.text != value)
		{
			tf_.text = value;
			invalidate_Visel(Visel.INVALIDATION_FLAG_DATA);
		}
		return value;
	}
}
//.............................................................................
//.............................................................................
