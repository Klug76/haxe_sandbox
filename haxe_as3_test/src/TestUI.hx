package;

import com.gs.femto_ui.Align;
import com.gs.femto_ui.Root;
import com.gs.femto_ui.Visel;
import flash.display.Stage;
import haxe.unit.TestCase;

class TestUI extends TestCase
{
	var stage_: Stage;

	public function new(stage: Stage)
	{
		super();
		stage_ = stage;
	}

	public function test1()
	{
		var a = Align.NEAR;
		var b = Align.FAR;
		var c = Align.CENTER;
		//trace("a=" + a);
		//trace("b=" + b);
		assertEquals(a, Align.NEAR);
	}

	public function test2()
	{
		var r: Root = Root.create(stage_);
		assertEquals(r.stage_, stage_);
		var v: Visel;
	}
}