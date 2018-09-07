package com.gs.console;

import com.gs.femto_ui.Root;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.KeyboardEvent;

class KonController
{
	static public inline var VERSION: String = "0.9.0";
	static private var instance_: Konsole = null;
	static private var ruler_: Ruler = null;
	static private var view_: DisplayObject = null;
	static private var password_idx_: Int = 0;

	static public function start(owner: DisplayObject, cfg: KonsoleConfig): Void
	{
		var r: Root = Root.create(owner);
		if (null == cfg)
			cfg = new KonsoleConfig();

		var k: Konsole = new Konsole(cfg);

		k.register_Command("ruler", cmd_Ruler, "Show display ruler");

		instance_ = k;

		var stg: Stage = r.stage_;
		if (stg != null)
			add_Stage_Listeners(stg);
		else
			r.owner_.addEventListener(Event.ADDED_TO_STAGE, on_Added_To_Stage);
	}
//.............................................................................
	static function on_Added_To_Stage(e: Event): Void
	{
		var r: Root = Root.instance;
		r.owner_.removeEventListener(Event.ADDED_TO_STAGE, on_Added_To_Stage);
		add_Stage_Listeners(r.owner_.stage);
	}
//.............................................................................
	static private function add_Stage_Listeners(stage: Stage) : Void
	{
		//TODO add gesture
		stage.addEventListener(KeyboardEvent.KEY_DOWN, on_Key_Down_Stage, false, 1);
		stage.addEventListener(KeyboardEvent.KEY_UP, on_Key_Up_Stage, false, 1);
	}
//.............................................................................
	static private function on_Key_Down_Stage(e : KeyboardEvent) : Void
	{
		//trace("stage::key down: 0x" + Std.string(e.keyCode));
		var cfg: KonsoleConfig = get_Config();
		if ((null == cfg) || (null != cfg.password_))
		{
			return;
		}
		switch (e.keyCode)
		{
			case 0xc0:
				e.preventDefault();
		}
	}
//.............................................................................
	static private function on_Key_Up_Stage(e : KeyboardEvent) : Void
	{
		//trace("stage::key up: 0x" + Std.string(e.keyCode));
		var cfg: KonsoleConfig = get_Config();
		if (null == cfg)
			return;
		var pass: String = cfg.password_;
		if (null != pass)
		{
			if (e.charCode == pass.charCodeAt(password_idx_))
			{
				++password_idx_;
				if (password_idx_ == pass.length)
				{
					show();
					password_idx_ = 0;
				}
				return;
			}
			password_idx_ = 0;
			return;
		}
		switch (e.keyCode)
		{
			case 0xc0:
				e.preventDefault();
				toggle();
		}
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
	static public function get_Visible(): Bool
	{
		if (view_ != null)
			return view_.visible;
		return false;
	}
	static public function set_Visible(value: Bool): Bool
	{
		if (instance_ != null)
		{
			if (value)
			{
				if (null == view_)
				{
					var r: Root = Root.instance;
					instance_.cfg_.init_View(r.platform_, r.ui_factor_);
					view_ = new KonsoleView(instance_);
				}
				else
				{
					view_.visible = true;
				}
				instance_.signal_show_.fire();
			}
			else
			{
				if (view_ != null)
					view_.visible = false;
			}
		}
		return value;
	}
	static public function toggle(): Void
	{
		set_Visible(!get_Visible());
	}
	static public function show(): Void
	{
		set_Visible(true);
	}
	static public function hide(): Void
	{
		set_Visible(false);
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
				{
					if (view_ != null)
						view_.visible = false;
				}
				return;
			}
			ruler_ = new Ruler(instance_);
			if (view_ != null)
				view_.visible = false;
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