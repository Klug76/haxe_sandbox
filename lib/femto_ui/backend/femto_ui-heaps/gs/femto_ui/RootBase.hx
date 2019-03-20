package gs.femto_ui;

import gs.femto_ui.util.Signal;
import h2d.Scene;

import h2d.Object;
import hxd.System;

typedef NativeUIObject = Object;
typedef NativeUIContainer = Object;

class RootBase
{
	public var frame_signal_ : Signal = new Signal();

	public var owner_: NativeUIContainer;
	public var scene_: Scene;

	public function new(owner: NativeUIContainer)
	{
		owner_ = owner;
		scene_ = @:privateAccess owner.getScene();
		init();
	}
//.............................................................................
	private function init() : Void
	{
		var r: Root = cast this;
		if (System.getValue(SystemValue.IsTouch))
			r.platform_ |= PlatformFlags.FLAG_TOUCH;
		switch(System.platform)
		{
		case Platform.IOS:
			r.platform_ |= PlatformFlags.FLAG_IOS;
		case Platform.Android:
			r.platform_ |= PlatformFlags.FLAG_ANDROID;
		case Platform.WebGL:
			r.platform_ |= PlatformFlags.FLAG_WEB;
		default:
			//TODO fix me
		};
		r.init_Ex();
	}
//.............................................................................
	public var stage_x(get, never): Float;
	inline private function get_stage_x(): Float
	{
		return scene_.x;
	}
//.............................................................................
	public var stage_y(get, never): Float;
	inline private function get_stage_y(): Float
	{
		return scene_.y;
	}
//.............................................................................
	public var stage_width(get, never): Float;
	inline private function get_stage_width(): Float
	{
		return scene_.width;
	}
//.............................................................................
	public var stage_height(get, never): Float;
	inline private function get_stage_height(): Float
	{
		return scene_.height;
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