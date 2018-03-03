package;


import flash.display.Sprite;
import haxe.unit.TestRunner;


class Main extends Sprite
{

	public function new()
	{

		super ();

		//trace("Hello, OpenFL");
		//test1();
		test2();
	}

	function test1()
	{
		var tr = new TestRunner();
		tr.add(new TestRingBuf());
		tr.add(new TestNumUtils());
		tr.run();

	}

	function test2()
	{

	}

}