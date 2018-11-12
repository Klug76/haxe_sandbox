package gs.femto_ui;

using gs.femto_ui.RootBase.NativeUIContainer;

@:allow(gs.femto_ui.EditBase)
class Edit extends EditBase
{
	public var text(get, set) : String;
	//textField.maxChars
	//textField.restrict
	//textField.displayAsPassword

	public static inline var SELECTABLE : Int	= 1;
	public static inline var TAB_ENABLED : Int	= 2;

	public function new(owner: NativeUIContainer, on_changed: String->Void, txt: String = null)
	{
		super(owner, txt);
#if debug
		name = "edit";
#end
		if (on_changed != null)
			on_Changed = on_changed;
	}
//.............................................................................
//.............................................................................
	public dynamic function on_Changed(text: String): Void
	{
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	private function get_text() : String
	{
		return get_Base_Text();
	}
	private function set_text(value : String) : String
	{
		if (null == value)
			value = "";
		if (get_Base_Text() != value)
		{
			set_Base_Text(value);
			invalidate_Visel(Visel.INVALIDATION_FLAG_TEXT);
		}
		return value;
	}
}
//.............................................................................
//.............................................................................

