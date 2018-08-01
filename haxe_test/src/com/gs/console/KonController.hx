package com.gs.console;
import com.gs.femto_ui.Root;
import flash.display.Stage;

//haxe -cp src -swf bin/hxlib.swc com.gs.console.KonController -lib hscript -swf-version 21.0 -dce no -D fdb -debug --macro include('com.gs')
//-D native-trace

class KonController
{
	static private var instance_: Konsole;
	static private var ruler_: Ruler;

	static public function start(stage: Stage, cfg: KonsoleConfig): Void
	{
		var r: Root = Root.create(stage);
		cfg.init();

		var k: Konsole = new Konsole(cfg);
		k.set_View(KonsoleView);
		k.start(stage);

		k.register_Command("ruler", cmd_Ruler, "show display ruler");

		instance_ = k;
	}
//.............................................................................
	static private function cmd_Ruler(dummy: Array<String>): Void
	{
		if (instance_ != null)
		{
			if (ruler_ != null)
			{
				ruler_.visible = !ruler_.visible;
				return;
			}
			ruler_ = new Ruler(instance_);
			instance_.add("show ruler");
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
	static public function toggle_View() : Void
	{
		if (instance_ != null)
			instance_.toggle_View();
	}
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

}