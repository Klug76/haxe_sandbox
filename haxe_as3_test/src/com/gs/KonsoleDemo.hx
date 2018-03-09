package com.gs;

import com.gs.femto_ui.Root;
import flash.display.Stage;
import com.gs.console.Konsole;
import com.gs.console.KonsoleConfig;
import com.gs.console.KonsoleView;
import haxe.Timer;

class KonsoleDemo
{
	private var stage: Stage;
	public var k: Konsole;

	public function new(st: Stage)
	{
		stage = st;
		create_UI();
	}

	function create_UI()
	{
		var r: Root = Root.create(stage);

		var cfg: KonsoleConfig = new KonsoleConfig();
		k = new Konsole(cfg);
		k.set_View(KonsoleView);
		k.start(stage);
		k.add("foo");
		k.add("bar");
		//k.toggle_View();
		Timer.delay(append_Test1, 100);
	}

	function append_Test1()
	{
		for (i in 0...10)
		{
			k.add(i);
		}
		Timer.delay(append_Test2, 200);
	}

	function append_Test2()
	{
		for (i in 10...14)
		{
			k.add(i);
		}
	}

}