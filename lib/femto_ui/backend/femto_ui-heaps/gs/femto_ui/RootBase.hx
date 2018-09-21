package gs.femto_ui;

import gs.femto_ui.util.Signal;

import h2d.Sprite;
import hxd.System;

typedef NativeUIContainer = Sprite;

class RootBase
{
	public var frame_signal_ : Signal = new Signal();

	public var is_touch_supported_ : Bool = false;
	public var desktop_mode_ : Bool = false;
	public var platform_: String = null;

	public var owner_: NativeUIContainer = null;

	public function new(owner: NativeUIContainer)
	{
		owner_ = owner;
		init();
	}
//.............................................................................
	private function init() : Void
	{
		is_touch_supported_ = System.getValue(SystemValue.IsTouch);
		platform_ = switch(System.platform)
		{
		case Platform.IOS:
			platform_ = "IOS";
		case Platform.Android:
			platform_ = "Android";
		case Platform.PC:
			platform_ = "PC";
		case Platform.WebGL:
			platform_ = "WEB";
		default:
			platform_ = "???";//TODO fix me
		};
		desktop_mode_ = !System.getValue(SystemValue.IsMobile);
		var r: Root = cast this;
		r.init_Ex(System.width, System.height);
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public function update() : Void
	{
		frame_signal_.fire();
	}

}