package;

import com.gs.KonsoleDemo;
import com.gs.console.RingBuf;
import flash.Lib;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;


class Main
{

	static function main()
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		// Entry point

		//var tr = new TestRunner();
		//tr.add(new TestRingBuf());
		//tr.add(new TestAlchemy());
		//tr.add(new TestUI(stage));
		//tr.add(new TestConsole(stage));
		// add other TestCases here

		// finally, run the tests
		//tr.run();

		new KonsoleDemo(stage);
		//trace("OK");
	}

}