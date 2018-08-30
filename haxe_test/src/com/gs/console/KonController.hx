package com.gs.console;

import com.gs.femto_ui.Root;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

//haxe -cp src -swf bin/hxlib.swc com.gs.console.KonController -lib hscript -swf-version 22 -dce no -D fdb -debug --macro include('com.gs')
//-D native-trace

class KonController
{
	static public inline var VERSION: String = "0.9.0";
	static private var instance_: Konsole;
	static private var ruler_: Ruler;

	static public function start(owner: DisplayObject, cfg: KonsoleConfig): Void
	{
		var r: Root = Root.create(owner);
		cfg.init();//:use Root

		var k: Konsole = new Konsole(cfg);
		k.set_View(KonsoleView);
		k.start();

		k.register_Command("ruler", cmd_Ruler, "Show display ruler");

		instance_ = k;
	}
//.............................................................................
	static public function add(v: Dynamic) : Void
	{
		if (instance_ != null)
			instance_.add(v);
	}
//.............................................................................
	static public function add_Html(html: String) : Void
	{
		if (instance_ != null)
			instance_.add_Html(html);
	}
//.............................................................................
	static public var visible (get, set) : Bool;
	#if swc @:getter(visible) #end
	static public function get_visible(): Bool
	{
		if (instance_ != null)
			return instance_.visible;
		return false;
	}
	#if swc @:setter(visible) #end
	static public function set_visible(value: Bool): Bool
	{
		if (instance_ != null)
			instance_.visible = value;
		return value;
	}
//.............................................................................
//.............................................................................
	static public function clear() : Void
	{
		if (instance_ != null)
			instance_.clear();
	}
//.............................................................................
	static public function eval(s : String) : Void
	{
		if (instance_ != null)
			instance_.eval(s);
	}
//.............................................................................
	static public function register_Command(cmd : String, f : Array<String>->Void, hint : String = null) : Void
	{
		if (instance_ != null)
			instance_.register_Command(cmd, f, hint);
	}
//.............................................................................
	static public function register_Object(name : String, obj: Dynamic) : Void
	{
		if (instance_ != null)
			instance_.register_Object(name, obj);
	}
//.............................................................................
	static public function get_Text() : String
	{
		if (instance_ != null)
			return instance_.get_Text();
		return null;
	}
//.............................................................................
	static public function get_Html() : String
	{
		if (instance_ != null)
			return instance_.get_Html();
		return null;
	}
//.............................................................................
//.............................................................................
	static public function get_Config() : KonsoleConfig
	{
		if (instance_ != null)
			return instance_.cfg_;
		return null;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	static private function cmd_Ruler(dummy: Array<String>): Void
	{
		if (instance_ != null)
		{
			if (ruler_ != null)
			{
				ruler_.visible = !ruler_.visible;
				if (ruler_.visible)
					instance_.visible = false;
				return;
			}
			ruler_ = new Ruler(instance_);
			instance_.visible = false;
		}
	}
//.............................................................................
//.............................................................................
	static public function is_Zoom_Visible(): Bool
	{
		return (ruler_ != null) && ruler_.visible;
	}
//.............................................................................
	static public function prepare_Zoom_Paint(): Bool
	{
		return ruler_.prepare_Zoom_Paint();
	}
//.............................................................................
	static public function get_Zoom_BitmapData(): BitmapData
	{
		@:privateAccess return ruler_.zoom_bd_3D_;
	}
//.............................................................................
	static public function get_Zoom_Src_Rect(): Rectangle
	{
		@:privateAccess return ruler_.aux_rc_;
	}
//.............................................................................
	static public function get_Zoom_Dst_Pt(): Point
	{
		@:privateAccess return ruler_.aux_pt_;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
}