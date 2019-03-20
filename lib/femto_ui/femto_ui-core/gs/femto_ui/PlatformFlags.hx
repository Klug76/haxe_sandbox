package gs.femto_ui;

@:enum abstract PlatformFlags(Int) from Int to Int
{
	var FLAG_UNKNOWN					= 0x0000;
	var FLAG_TOUCH						= 0x0001;
	var FLAG_IOS						= 0x0002;
	var FLAG_ANDROID					= 0x0004;
	var FLAG_WEB						= 0x0008;
	var FLAG_WIN						= 0x0010;
	var FLAG_MAC						= 0x0020;
}
