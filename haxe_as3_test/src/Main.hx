package;

import com.gs.KonsoleDemo;
import com.gs.femto_ui.util.RingBuf;
import flash.Lib;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

/*
haxe -cp src -as3 as3_gen -swf-version 21.0 -D analyzer-optimize -main Main -dce full
*/

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

		KonsoleDemo.create_UI(stage);
		//trace("OK");
	}

}