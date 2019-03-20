package gs.femto_ui;

import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import gs.femto_ui.util.Util;

using gs.femto_ui.RootBase.NativeUIContainer;

class EditBase extends Visel
{
	private var tf_ : TextField = null;
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
		tf_ = new TextField();
		tf_.type = TextFieldType.INPUT;
		tf_.defaultTextFormat = get_Default_Text_Format();
		tf_.selectable = get_Edit_Option(Edit.SELECTABLE);
		tf_.tabEnabled = get_Edit_Option(Edit.TAB_ENABLED);//?
#if flash
		tf_.condenseWhite = false;
#end
		//:html5 crash with zero size:
		//:HTML5GLRenderContext.hx:2545 WebGL: INVALID_VALUE: texImage2D: no canvas
		update_Text_Field_Size();
		invalid_flags_ &= ~Visel.INVALIDATION_FLAG_SIZE;
		tf_.addEventListener(Event.CHANGE, on_Text_Changed);
		addChild(tf_);
	}
//.............................................................................
	private function on_Text_Changed(ev: Event): Void
	{
		var ed: Edit = cast this;
		ed.on_Changed(tf_.text);
	}
//.............................................................................
	private function get_Default_Text_Format(): TextFormat
	{
		var r : Root = Root.instance;
		return new TextFormat(r.font_, Std.int(r.input_font_size_));
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
			update_Text_Field_Size();
		}
	}
//.............................................................................
	function update_Text_Field_Size()
	{
		var r : Root = Root.instance;
		tf_.width = Util.fmax(r.small_tool_width_, width_);
		tf_.height = Util.fmax(r.small_tool_height_, height_);
	}
//.............................................................................
	//public function set_Focus(): Void
	//{
		//stage.focus = tf_;
	//}
//.............................................................................
	private function set_Caret_To_End() : Void
	{
		var len : Int = tf_.length;
		tf_.setSelection(len, len);
	}
//.............................................................................
}
//.............................................................................
//.............................................................................

