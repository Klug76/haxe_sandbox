package gs.femto_ui;

using gs.femto_ui.RootBase.NativeUIContainer;

@:allow(gs.femto_ui.ScrollTextBase)
class ScrollText extends ScrollTextBase
{
	public var word_wrap(get, set): Bool;

	public function new(owner : NativeUIContainer)
	{
		super(owner);
#if debug
		name = "scrolltext";
#end
	}
//.............................................................................
	public function set_Text_Format(fname: String, fsize: Int, fcolor: Int): Void
	{
		set_Text_Format_Base(fname, fsize, fcolor);
	}
//.............................................................................
	public function append_Text(value: String) : Void
	{
		append_Text_Base(value);
	}
//.............................................................................
	public function replace_Text(value: String) : Void
	{
		replace_Text_Base(value);
	}
//.............................................................................
	public function get_Max_ScrollV() : Int
	{
		return get_Max_ScrollV_Base();//:1-based like flash::TextField
	}
//.............................................................................
	public function get_ScrollV() : Int
	{
		return get_ScrollV_Base();//:1-based like flash::TextField
	}
	public function set_ScrollV(value: Int) : Void
	{
		set_ScrollV_Base(value);//:value 1-based like flash::TextField
	}
//.............................................................................
	public dynamic function on_text_change() : Void {};
	public dynamic function on_text_scroll() : Void {};
//.............................................................................
	function get_word_wrap(): Bool
	{
		return get_Word_Wrap_Base();
	}
//.............................................................................
	function set_word_wrap(value: Bool): Bool
	{
		set_Word_Wrap_Base(value);
		return value;
	}

}