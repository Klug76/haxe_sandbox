package com.gs.femto_ui;

import flash.errors.Error;
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import flash.system.Capabilities;
import flash.ui.Multitouch;

class Root
{
	public static var instance(get, never) : Root;

	private static var instance_ : Root;

	public var frame_signal_ : EnterFrameSignal;
	public var is_touch_supported_ : Bool;
	public var desktop_mode_ : Bool;
	public var stage_ : Stage;
	public var os_: String;

	public var color_gripper_ : Int = 0x95D13A;
	public var color_pressed_ : Int = 0x00aaaa;
	public var color_disabled_ : Int = 0x808080;

	public var font_family_ : String = "Helvetica,Arial,_sans";
	public var con_font_ : String = null;

	public var ui_factor_ : Float = 1;

	public var def_text_size_ : Int = 14;
	public var input_text_size_ : Int = 16;
	public var small_tool_width_ : Int = 36;
	public var small_tool_height_ : Int = 32;
	public var tool_width_ : Int = 48;
	public var tool_height_ : Int = 42;
	public var tool_spacing_ : Int = 8;
	public var spacing_ : Int = 2;
	public var hover_inflation_ : Int = 2;

	public function new(owner : DisplayObjectContainer)
	{
		init(owner);
	}
//.............................................................................
	private function init(owner : DisplayObjectContainer) : Void
	{
		#if debug
		if (instance_ != null)
		{
			throw new Error("Root should be singleton!");
		}
		if ((null == owner) || (null == owner.stage))
		{
			throw new Error("Stage not found");
		}
		#end
		instance_ = this;

		is_touch_supported_ = Multitouch.supportsTouchEvents;
		os_ = Capabilities.os;
		var win: Bool = (os_.indexOf("Windows") == 0);
		//trace("*** os = " + os_);
		desktop_mode_ = win || (os_.indexOf("Mac OS") == 0);
		if (win || (os_.indexOf("HTML5") == 0))
		{//TODO fix me: how to detect desktop mode !!??
			con_font_ = "Consolas";
			font_family_ = con_font_;
		}
		stage_ = owner.stage;

		frame_signal_ = new EnterFrameSignal(stage_);

		var res_x : Float = Capabilities.screenResolutionX;
		var res_y : Float = Capabilities.screenResolutionY;
		if (desktop_mode_)
		{
			res_x = stage_.stageWidth;
			res_y = stage_.stageHeight;
		}
		var m : Float = Math.min(res_x, res_y);
		if (m >= 1080)
		{
			ui_factor_ = 2;
			/* TODO fix me
			def_text_size_		*= ui_factor_;
			input_text_size_	*= ui_factor_;
			small_tool_width_	*= ui_factor_;
			small_tool_height_	*= ui_factor_;
			tool_width_			*= ui_factor_;
			tool_height_		*= ui_factor_;
			tool_spacing_		*= ui_factor_;
			spacing_			*= ui_factor_;
			hover_inflation_	*= ui_factor_;
			*/
		}
	}
//.............................................................................
	private static inline function get_instance() : Root
	{
		return instance_;
	}
//.............................................................................
	public static function create(owner : DisplayObjectContainer) : Root
	{
		if (null == instance_)
		{
			instance_ = new Root(owner);
		}
		return instance_;
	}
}
