package;


import com.gs.femto_ui.Align;
import com.gs.femto_ui.Button;
import com.gs.femto_ui.Label;
import com.gs.femto_ui.Root;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import haxe.unit.TestRunner;


class Main extends Sprite
{
	var al_: Label;
	var counter_: Int = 0;
	var b2: Button;

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
		var r: Root = Root.create(stage);
		al_ = new Label(stage, "Hello, Мир!");
		al_.movesize(10, 20, 220, 140);
		al_.dummy_color = 0xc00000;
		al_.h_align = Align.CENTER;

		var b: Button = new Button(stage, "foo", on_Click);
		b.dummy_color = 0x0000c0;
		b.movesize(250, 20, 220, 40);

		b2 = new Button(stage, "align", on_Click2);
		b2.dummy_color = 0x0000c0;
		b2.movesize(250, 120, 220, 40);

	}

	function on_Click2(e: MouseEvent)
	{
		switch(al_.h_align)
		{
			case Align.NEAR:
				al_.h_align = Align.CENTER;
			case Align.CENTER:
				al_.h_align = Align.FAR;
			case Align.FAR:
				al_.h_align = Align.NEAR;
		}
	}

	function on_Click(e: Event)
	{
		trace("click!");
		al_.text += "\nclick #" + counter_++;
		b2.enabled = !b2.enabled;
	}

}