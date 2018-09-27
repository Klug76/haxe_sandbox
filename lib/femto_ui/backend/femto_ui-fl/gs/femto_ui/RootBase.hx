package gs.femto_ui;

import flash.Lib;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import flash.events.Event;
import flash.system.Capabilities;

#if (!openfl && (flash >= 10.1))
import flash.system.TouchscreenType;
#end

typedef NativeUIObject = DisplayObject;
typedef NativeUIContainer = DisplayObjectContainer;

class RootBase
{
	public var frame_signal_ : EnterFrameSignal = new EnterFrameSignal();

	public var is_touch_supported_: Bool = false;
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

#if (!openfl && (flash >= 10.1))
		is_touch_supported_ = Capabilities.touchscreenType == TouchscreenType.FINGER;
#end
		platform_ = Capabilities.version.substr(0, 3);

		//trace("*** is_touch_supported_=" + is_touch_supported_);
		//trace("*** platform_ = " + platform_);//:html5 return WEB

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
		var r: Root = cast this;
		r.init_Ex();
	}
//.............................................................................
//.............................................................................
	public var stage_width(get, never): Float;
	inline private function get_stage_width(): Float
	{
		return stage_.stageWidth;
	}
//.............................................................................
	public var stage_height(get, never): Float;
	inline private function get_stage_height(): Float
	{
		return stage_.stageHeight;
	}
//.............................................................................
	public function update(): Void
	{
		//:nop
	}
//.............................................................................
}