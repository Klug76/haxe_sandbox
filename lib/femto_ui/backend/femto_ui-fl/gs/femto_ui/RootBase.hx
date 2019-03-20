package gs.femto_ui;

import flash.Lib;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import flash.display.Bitmap;
import flash.events.Event;
import flash.system.Capabilities;

#if (!openfl && (flash >= 10.1))
import flash.system.TouchscreenType;
#end

typedef NativeUIObject = DisplayObject;
typedef NativeUIContainer = DisplayObjectContainer;
typedef NativeBitmap = Bitmap;

class RootBase
{
	public var frame_signal_ : EnterFrameSignal = new EnterFrameSignal();

	public var owner_ : NativeUIContainer = null;
	public var stage_ : Stage = null;
	public var font_ : String = "Helvetica";

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
		var r: Root = cast this;
#if openfl
		//TODO fix me
		//is_touch_supported_ = ?
	#if js
		var agent = js.Browser.navigator.userAgent;
		if (agent != null)
		{
			//trace(agent);
			if (agent.indexOf("Windows") >= 0)//?windows phone is dead?
				r.platform_ |= PlatformFlags.FLAG_WIN;
		}
		r.platform_ |= PlatformFlags.FLAG_WEB;
	#end
#elseif flash
	#if	(flash >= 10.1)
		if (Capabilities.touchscreenType == TouchscreenType.FINGER)
			r.platform_ |= PlatformFlags.FLAG_TOUCH;
	#end
		var ver = Capabilities.version.substr(0, 3);
		if ("WIN" == ver)
			r.platform_ |= PlatformFlags.FLAG_WIN;
		else if ("MAC" == ver)
			r.platform_ |= PlatformFlags.FLAG_MAC;
		else if ("AND" == ver)
			r.platform_ |= PlatformFlags.FLAG_ANDROID;
		else if ("IOS" == ver)
			r.platform_ |= PlatformFlags.FLAG_IOS;
#end
		r.drag_threshold_ = Math.min(8, Capabilities.screenDPI * 2 / 25.4);//~2 mm

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
	public var stage_x(get, never): Float;
	inline private function get_stage_x(): Float
	{
		return stage_.x;
	}
//.............................................................................
	public var stage_y(get, never): Float;
	inline private function get_stage_y(): Float
	{
		return stage_.y;
	}
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
	inline public function update(): Void
	{
		//:nop
	}
//.............................................................................
}