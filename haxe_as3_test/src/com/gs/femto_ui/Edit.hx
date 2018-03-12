package com.gs.femto_ui;

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
		init(txt);
	}
	//.............................................................................
	private function init(txt : String) : Void
	{
		tf_ = new TextField();
		tf_.type = TextFieldType.INPUT;
		tf_.defaultTextFormat = new TextFormat(null, Root.instance.input_text_size_);
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
	private function get_text_Field() : TextField
	{
		return tf_;
	}
	//.............................................................................
	//textField.maxChars
	//textField.restrict
	//textField.displayAsPassword
	//.............................................................................
	override public function draw() : Void
	{
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
		{
			tf_.width = width_;
			tf_.height = height_;
		}
		super.draw();
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
			invalidate(Visel.INVALIDATION_FLAG_DATA);
		}
		return value;
	}
}
//.............................................................................
//.............................................................................

