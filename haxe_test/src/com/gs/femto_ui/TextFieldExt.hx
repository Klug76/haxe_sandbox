package com.gs.femto_ui;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

class TextFieldExt
{
	public static function create_Fixed_Text_Field(cl:Class<TextField>, calc: String, def: String, fmt: TextFormat): TextField
	{
		var tf: TextField = new TextField();
		tf.type = TextFieldType.DYNAMIC;
		tf.defaultTextFormat = fmt;
		tf.selectable = false;
		tf.mouseEnabled = false;
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.text = calc;
		var tw: Int = Math.round(tf.width + 1);
		var th: Int = Math.round(tf.height + 1);
		tf.autoSize = TextFieldAutoSize.NONE;
		tf.width = tw;
		tf.height = th;
		tf.text = def;
		return tf;
	}
	public static function create_AutoSize_Text_Field(cl:Class<TextField>, def: String, fmt: TextFormat/*, ?tfas: TextFieldAutoSize*/): TextField
	{
		var tf: TextField = new TextField();
		tf.type = TextFieldType.DYNAMIC;
		tf.defaultTextFormat = fmt;
		tf.selectable = false;
		tf.mouseEnabled = false;
		/*
		if (null == tfas)
			tf.autoSize = TextFieldAutoSize.LEFT;
		else
			tf.autoSize = tfas;
		*/
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.text = def;
		return tf;
	}

}