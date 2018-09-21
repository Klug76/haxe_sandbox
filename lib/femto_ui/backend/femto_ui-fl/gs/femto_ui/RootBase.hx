package gs.femto_ui;

import flash.Lib;
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import flash.events.Event;
import flash.system.Capabilities;

#if (openfl || (flash >= 10.1))
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
#end

typedef NativeUIContainer = DisplayObjectContainer;

class RootBase
{
	public var frame_signal_ : EnterFrameSignal = new EnterFrameSignal();

	public var is_touch_supported_ : Bool = false;
	public var desktop_mode_ : Bool = false;
	public var platform_: String = null;

	public var stage_ : Stage = null;
	public var owner_ : NativeUIContainer = null;

	public function new(owner : NativeUIContainer)
	{
		if (null == owner)
			owner = Lib.current;
		owner_ = owner;
		init();//:Haxe actually lacks real private behavior..
	}
//.............................................................................
	private function init() : Void
	{

#if (openfl || (flash >= 10.1))
		is_touch_supported_ = Multitouch.inputMode == MultitouchInputMode.TOUCH_POINT;
#end
		platform_ = Capabilities.version.substr(0, 3);
		//trace("*** platform_ = " + os_);//:html5 return WEB
		desktop_mode_ = (platform_ == "WIN") || (platform_ == "MAC");// || (platform_ == "LNX");

		var stg: Stage = owner_.stage;
		if (null == stg)
			owner_.addEventListener(Event.ADDED_TO_STAGE, on_Added_To_Stage);
		else
			on_Added_To_Stage(null);
	}
//.............................................................................
//.............................................................................
	private function on_Added_To_Stage(ev: Event): Void
	{
		if (ev != null)
			owner_.removeEventListener(Event.ADDED_TO_STAGE, on_Added_To_Stage);
		if (stage_ != null)
			return;
		stage_ = owner_.stage;
		frame_signal_.init(stage_);
		var res_x : Float = Capabilities.screenResolutionX;
		var res_y : Float = Capabilities.screenResolutionY;
		if (desktop_mode_)
		{
			res_x = stage_.stageWidth;
			res_y = stage_.stageHeight;
		}
		var r: Root = cast this;
		r.init_Ex(res_x, res_y);
	}
//.............................................................................
//.............................................................................
	public function update(): Void
	{
		//:nop
	}
//.............................................................................
}