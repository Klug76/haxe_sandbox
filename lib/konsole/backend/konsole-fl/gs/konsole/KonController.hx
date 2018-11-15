package gs.konsole;

import gs.femto_ui.Root;
import gs.femto_ui.Viewport;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.KeyboardEvent;

class KonController
{
	static public inline var VERSION: String = "0.9.1";
	static private var instance_: Konsole = null;
	static private var ruler_: Ruler = null;
	static private var fps_view_ : Viewport = null;
	static private var mem_view_ : Viewport = null;
	static private var view_: DisplayObject = null;
	static private var password_idx_: Int = 0;

	static public function start(owner: DisplayObjectContainer, cfg: KonsoleConfig): Void
	{
		var r: Root = Root.create(owner);
		if (null == cfg)
			cfg = new KonsoleConfig();

		var k: Konsole = new Konsole(cfg);

		k.register_Command("fps", cmd_Fps, "Show fps");
		k.register_Command("mem", cmd_Mem, "Show memory usage");
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
	static private function on_Key_Down_Stage(ev : KeyboardEvent) : Void
	{
		var cfg: KonsoleConfig = get_Config();
		if ((null == cfg) || (null != cfg.password_))
		{
			return;
		}
		if (cfg.toggle_key_ == cast ev.keyCode)
		{
			ev.preventDefault();
			ev.stopImmediatePropagation();
		}
	}
//.............................................................................
	static private function on_Key_Up_Stage(ev : KeyboardEvent) : Void
	{
		//trace("stage::key up: 0x" + Std.string(e.keyCode));
		var cfg: KonsoleConfig = get_Config();
		if (null == cfg)
			return;
		var pass: String = cfg.password_;
		if (null != pass)
		{
			if (ev.charCode == pass.charCodeAt(password_idx_))
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
		if (cfg.toggle_key_ == cast ev.keyCode)
		{
			ev.preventDefault();
			ev.stopImmediatePropagation();
			toggle();
		}
	}
//.............................................................................
	static public function Log(v: Dynamic) : Void
	{
		if (instance_ != null)
			instance_.log(v);
	}
//.............................................................................
	static public function Log_Html(html: String) : Void
	{
		if (instance_ != null)
			instance_.log_Html(html);
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
					//view_ = new KonsoleView(instance_, false);
					view_ = new KonsoleView(instance_, true);
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
	static private function cmd_Ruler(_: Array<String>): Void
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
	static private function cmd_Fps(_: Array<String>): Void
	{
		var r: Root = Root.instance;
		if (null == fps_view_)
		{
			fps_view_ = new Viewport();
			var m : FpsMonitor = new FpsMonitor(fps_view_);//TODO unite monitors creation/suspend/resume
			fps_view_.content = m;
			fps_view_.movesize(100 * r.ui_factor_, 100 * r.ui_factor_, m.width + r.small_tool_width_, m.height);
			return;
		}
		fps_view_.visible = !fps_view_.visible;
	}
//.............................................................................
	static private function cmd_Mem(_: Array<String>): Void
	{
		var r: Root = Root.instance;
		if (null == mem_view_)
		{
			mem_view_ = new Viewport();
			var m : MemMonitor = new MemMonitor(mem_view_);
			mem_view_.content = m;
			mem_view_.movesize(100 * r.ui_factor_, 120 * r.ui_factor_ + m.height, m.width + r.small_tool_width_, m.height);
			return;
		}
		mem_view_.visible = !mem_view_.visible;
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