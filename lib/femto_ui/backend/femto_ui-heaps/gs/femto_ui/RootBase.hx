package gs.femto_ui;

import gs.femto_ui.util.Signal;

import h2d.Object;
import hxd.System;

typedef NativeUIObject = Object;
typedef NativeUIContainer = Object;

class RootBase
{
	public var frame_signal_ : Signal = new Signal();

	public var is_touch_supported_ : Bool = false;
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
		var r: Root = cast this;
		r.init_Ex();
	}
//.............................................................................
	public var stage_width(get, never): Float;
	inline private function get_stage_width(): Float
	{
		return System.width;
	}
//.............................................................................
	public var stage_height(get, never): Float;
	inline private function get_stage_height(): Float
	{
		return System.height;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public function update() : Void
	{
		frame_signal_.fire();
	}

}