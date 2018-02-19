package;

import com.gs.console.RingBuf;
import flash.Lib;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

class TestRingBuf extends TestCase
{
	public function testFloat()
	{
		assertEquals("A", "A");
		var r = new RingBuf<Float>(3);
		assertEquals(0, r.length);
		assertEquals(4, r.capacity);
		r.push(1.);
		r.push(2.);
		r.push(3.);
		assertEquals(3, r.length);
		r.push(4.);
		assertEquals(1., r.item(r.tail));
		r.push(5.);
		assertEquals(2., r.item(r.head));
		assertEquals(2., r.item(r.tail));
		assertEquals(4., r.length);
	}
}

class Main
{

	static function main()
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		// Entry point
		var r = new TestRunner();
		r.add(new TestRingBuf());
		// add other TestCases here

		// finally, run the tests
		r.run();
		//trace("OK");
	}

}