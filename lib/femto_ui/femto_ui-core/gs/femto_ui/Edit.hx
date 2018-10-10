package gs.femto_ui;

using gs.femto_ui.RootBase.NativeUIContainer;

@:allow(gs.femto_ui.EditBase)
class Edit extends EditBase
{
	public var text(get, set) : String;
	//textField.maxChars
	//textField.restrict
	//textField.displayAsPassword

	public function new(owner: NativeUIContainer, on_Changed: String->Void, txt: String = null)
	{
		super(owner, on_Changed, txt);
#if debug
		name = "edit";
#end
	}
//.............................................................................
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

