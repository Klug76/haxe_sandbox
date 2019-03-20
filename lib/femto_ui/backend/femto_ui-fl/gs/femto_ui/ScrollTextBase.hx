package gs.femto_ui;

import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import gs.femto_ui.util.Util;

#if flash
import flash.text.StyleSheet;
#end

using gs.femto_ui.RootBase.NativeUIContainer;

class ScrollTextBase extends Visel
{
#if flash
	private var aux_ : TextField = null;
#else
	private var html_text_: String = "";
#end
	private var text_field_ : TextField;
	private var is_html_: Bool;

	public function new(owner : NativeUIContainer, is_html: Bool)
	{
		super(owner);
		is_html_ = is_html;
		create_Children_Ex();
	}
//.............................................................................
	private function create_Children_Ex() : Void
	{
#if flash
		if (is_html_)
		{
			aux_ = new TextField();
			aux_.type = TextFieldType.DYNAMIC;
			aux_.selectable = false;
			aux_.condenseWhite = false;
			aux_.multiline = true;
		}
#end

		text_field_ = new TextField();
		text_field_.type = TextFieldType.DYNAMIC;
		//:text_field_.styleSheet = null!!!
		text_field_.wordWrap = true;
		text_field_.multiline = true;
#if flash
		text_field_.condenseWhite = false;
#end
		update_Tf_Size();
		addChild(text_field_);
		//?text_field_.addEventListener(Event.CHANGE, on_Text_Change);
		text_field_.addEventListener(Event.SCROLL, on_Text_Scroll);
	}
//.............................................................................
	private function update_Tf_Size(): Void
	{
		var r : Root = Root.instance;

		var tw: Float = Util.fmax(r.small_tool_width_, width_);
		var th: Float = Util.fmax(r.small_tool_height_, height_);

#if flash
		if (aux_ != null)
		{
			aux_.width = tw;
			aux_.height = th;
		}
#end
		text_field_.width = tw;//:avoid bug in openfl
		text_field_.height = th;
	}
//.............................................................................
	public function set_Text_Format_Base(fname: String, fsize: Int, fcolor: Int): Void
	{
		var tf: TextFormat = new TextFormat(fname, fsize, fcolor);
		text_field_.defaultTextFormat = tf;
		//??text_field_.setTextFormat(tf);
#if flash
		if (is_html_)
		{//:assume aux_ != null
			var css: StyleSheet = new StyleSheet();
			css.setStyle("p",
			{
				fontFamily : fname,
				fontSize : fsize,
				color : "#" + Util.toHex(fcolor, 6)
				//?display:'inline'//:Supported values are inline, block, and none.
				});
			aux_.styleSheet = css;
		}
#end
	}
//.............................................................................
//.............................................................................
	public inline function get_Word_Wrap_Base(): Bool
	{
		return text_field_.wordWrap;
	}
//.............................................................................
	public inline function set_Word_Wrap_Base(value: Bool): Void
	{
		if (text_field_.wordWrap == value)
			return;
		text_field_.wordWrap = value;
	}
//.............................................................................
//.............................................................................
//.............................................................................
	private function on_Text_Scroll(e : Event) : Void
	{
		var st: ScrollText = cast this;
		st.on_text_scroll();
	}
//.............................................................................
	override public function draw_Visel(): Void
	{
		super.draw_Visel();
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
		{
			update_Tf_Size();
			//trace("******** text size=" + width_ + "x" + height_);
		}
	}
//.............................................................................
	//public function debug_Dump(): String
	//{
		//return ":scrolltext:" + width_ + "x" + height_ + "::tf:" + text_field_.width + "x" + text_field_.height + "::aux:" + aux_.width + "x" + aux_.height;
	//}
//.............................................................................
//.............................................................................
	public inline function append_Text_Base(value: String) : Void
	{
		if ((null == value) || (value.length <= 0))
			return;
		var st: ScrollText = cast this;
		var in_tail : Bool = text_field_.scrollV == text_field_.maxScrollV;
		if (is_html_)
		{
#if flash
			var ins_idx : Int = text_field_.length;
			aux_.htmlText = value;
			var temp : String = aux_.getXMLText();
			text_field_.insertXMLText(ins_idx, ins_idx, temp, false);
			aux_.htmlText = "";
#else
			html_text_ += value;
			text_field_.htmlText = html_text_;
			//:BUGBUG: get_htmlText doesn't work in openfl (yet, v.7,1,2)
			//:text_field_.htmlText += s;
#end
		}
		else
		{
			text_field_.appendText(value);
		}
		if (in_tail)
			text_field_.scrollV = text_field_.maxScrollV;
		st.on_text_change();
	}
//.............................................................................
	public inline function replace_Text_Base(value: String) : Void
	{
		if (value.length > 0)
		{
			if (is_html_)
			{
#if flash
				var len : Int = text_field_.length;
				aux_.htmlText = value;
				var temp : String = aux_.getXMLText();
				text_field_.insertXMLText(0, len, temp, false);//:fastest way
				aux_.htmlText = "";
#else
				html_text_ = value;
				text_field_.htmlText = value;
#end
			}
			else
			{
				text_field_.text = value;
			}

			text_field_.scrollV = text_field_.maxScrollV;
		}
		else
		{//:clear
			var len : Int = text_field_.length;
			if (len > 0)
			{
				text_field_.text = "";
				text_field_.scrollV = 1;//:If the first line displayed is the first line in the text field, scrollV is set to 1 (not 0).
#if !flash
				html_text_ = "";
#end
			}
		}
		var st: ScrollText = cast this;
		st.on_text_change();
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public inline function get_Max_ScrollV_Base() : Int
	{
		return text_field_.maxScrollV;
	}
//.............................................................................
	public inline function get_ScrollV_Base() : Int
	{
		return text_field_.scrollV;
	}
//.............................................................................
	public inline function set_ScrollV_Base(value: Int) : Void
	{
		text_field_.scrollV = value;
	}
}