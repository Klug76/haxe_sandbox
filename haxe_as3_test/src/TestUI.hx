package;

import com.gs.console.Util;
import com.gs.femto_ui.Align;
import com.gs.femto_ui.Button;
import com.gs.femto_ui.Label;
import com.gs.femto_ui.Mover;
import com.gs.femto_ui.Resizer;
import com.gs.femto_ui.Root;
import com.gs.femto_ui.Toolbar;
import com.gs.femto_ui.Viewport;
import com.gs.femto_ui.Visel;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import haxe.unit.TestCase;

class TestUI extends TestCase
{
	var stage_: Stage;
	var vp:Viewport;

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
		v.destroy();
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
		var b: Button = new Button(null, "foo", on_Click);
		b.dummy_color = 0x0000c0;
		b.resize(120, 40);
		//assertEquals("foo", b.text);
		assertFalse(b.auto_repeat);

		var t: Toolbar = new Toolbar(stage_);
		t.addChild(b);
		t.movesize(10, 220, 420, 40);
		t.dummy_color = 0x000040;
		t.spacing_ = 8;

		{
			var b: Button = new Button(t, "foo2", on_Click);
			b.dummy_color = 0x3D5E83;
			b.resize(120, 40);
		}
		var v: SimpleViewport = new SimpleViewport(stage_);
		v.dummy_color = 0x80008000;
		v.movesize(103, 20, 200, 100);

		var mo: Mover = new Mover(v);
		mo.resize(r.small_tool_width_, r.small_tool_height_);
		mo.dummy_color = 0x400000;

		var re: Resizer = new Resizer(v);
		re.resize(r.small_tool_width_, r.small_tool_height_);
		re.dummy_color = 0x400000;
		re.move(v.width - re.width, v.height - re.height);
		v.resizer_ = re;

		vp = new Viewport(stage_);
		vp.dummy_color = 0x80FFFF51;
		vp.movesize(100, 250, 120, 120);
	}

	function on_Click(e: Event)
	{
		trace("click!");
		if (!vp.visible)
			vp.visible = true;
	}
}

class SimpleViewport extends Visel
{
	public var resizer_: Resizer;

	public function new(owner: DisplayObjectContainer)
	{
		super(owner);
	}

    override public function draw() : Void
    {
        super.draw();
		if (resizer_ != null)
		{
			if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
			{
				resizer_.move(width_ - resizer_.width, height_ - resizer_.height);
			}
		}
	}
}