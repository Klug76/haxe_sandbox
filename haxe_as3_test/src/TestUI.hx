package;

import com.gs.console.Util;
import com.gs.femto_ui.Align;
import com.gs.femto_ui.Button;
import com.gs.femto_ui.Label;
import com.gs.femto_ui.Root;
import com.gs.femto_ui.Visel;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
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
		var ch: Visel = new Visel(v);
		var sp: Sprite = new Sprite();
		new Visel(v);
		new Visel(v);
		v.destroy_Children();
		assertEquals(0, v.numChildren);
		assertTrue(ch.disposed);
		v.destroy_Children();
		//v.destroy();
	}

	public function _test3()
	{
		var r: Root = Root.create(stage_);
		var al: Label = new Label(stage_, "Hello, Мир!");
		al.movesize(100, 200, 220, 40);
		al.dummy_color = 0xc00000;
		al.v_align = Align.CENTER;
		assertEquals(Align.NEAR, al.h_align);
		assertEquals(Align.CENTER, al.v_align);
		var al2: Label = new Label(stage_, "Hello, Мир!");
		al2.movesize(110, 280, 220, 40);
		al2.dummy_color = 0x0000c0;
		al2.h_align = Align.CENTER;
		al2.v_align = Align.FAR;
	}

	public function test4()
	{
		var r: Root = Root.create(stage_);
		var b: Button = new Button(stage_, "foo", on_Click);
		b.dummy_color = 0x0000c0;
		b.movesize(100, 200, 220, 40);
		//assertEquals("foo", b.text);
		assertFalse(b.auto_repeat);
	}

	function on_Click(e: Event)
	{
		trace("click!");
	}
}