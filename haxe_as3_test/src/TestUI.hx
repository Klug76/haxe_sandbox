package;

import com.gs.console.Util;
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
		assertEquals(stage_, r.stage_);
		var n: Int = Visel.INVALIDATION_FLAG_ALL;
		var s: String = "0x" + Util.toHex(n);
		assertEquals("0xFFFFFFFF", s);
		var v: Visel = new Visel(stage_);
		v.dummy_color = 0x80008000;
		v.movesize_(10.3, 20.8, 200, 100);
		v.draw();
		v.validate();
		assertEquals(10., v.x);
		assertEquals(21., v.y);
		assertEquals(200., v.width);
		assertEquals(100., v.height);
		assertEquals(0x80 / 255., v.dummy_alpha_);
		//v.destroy();
	}
}