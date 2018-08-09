package;


import com.gs.KonsoleDemo;
import com.gs.console.Konsole;
import com.gs.console.KonsoleConfig;
import com.gs.console.KonsoleView;
import com.gs.femto_ui.Align;
import com.gs.femto_ui.Button;
import com.gs.femto_ui.Label;
import com.gs.femto_ui.Root;
import com.gs.femto_ui.Viewport;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import haxe.Timer;
import haxe.unit.TestRunner;

//TODO fix me: \Pictures\bug_bug.png

class Main extends Sprite
{
	var counter_: Int = 0;
	var tf_: TextField = null;
	var b2: Button = null;
	var al_: Label = null;
	var vp: Viewport = null;
	var k: Konsole = null;

	public function new()
	{

		super ();

		//trace("Hello, OpenFL");
		//test1();
		//test2();
		test3();
	}

	function test1()
	{
		var tr = new TestRunner();
		tr.add(new TestRingBuf());
		tr.add(new TestNumUtils());
		tr.run();

	}

	/*
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

		vp = new Viewport(stage);
		vp.dummy_color = 0x80dFdF51;
		vp.movesize(100, 250, 120, 120);
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
		if (!vp.visible)
			vp.visible = true;
	}
	*/

	function test3()
	{
		tf_ = new TextField();
		addChild(tf_);
		tf_.x = 10;
		tf_.y = 20;
		tf_.htmlText = "1<br>";
		tf_.htmlText += "2<br>";
		tf_.htmlText = "<p>1</p>";
		tf_.htmlText += "<p>2</p>";
		tf_.htmlText += "<p>1</p><p>2</p>";

		KonsoleDemo.create_UI(this);
	}


}