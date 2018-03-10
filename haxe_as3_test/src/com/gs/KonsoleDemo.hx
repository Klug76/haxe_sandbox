package com.gs;

import com.gs.console.Util;
import com.gs.femto_ui.Button;
import com.gs.femto_ui.Label;
import com.gs.femto_ui.Root;
import com.gs.femto_ui.Toolbar;
import com.gs.femto_ui.Visel;
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import com.gs.console.Konsole;
import com.gs.console.KonsoleConfig;
import com.gs.console.KonsoleView;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import haxe.Timer;

class KonsoleDemo extends Visel
{
	private var tb_: Toolbar;
	private var aux_: TextField;
	private var counter_: Int = 0;
	private static var k: Konsole;

	public function new(owner : DisplayObjectContainer)
	{
		super(owner);
		create_Children();
	}

	function create_Children()
	{
		var r: Root = Root.instance;

		aux_ = new TextField();
		aux_.autoSize = TextFieldAutoSize.LEFT;
		aux_.defaultTextFormat = new TextFormat(null, r.def_text_size_);

		tb_ = new Toolbar(this);
		tb_.spacing_ = 6;
		tb_.dummy_color = 0xd0d0d0;

		add_Tool_Button(0x0000c0, "~", toggle_Konsole);
		add_Tool_Button(0x00c0c0, "test1", test1);
		add_Tool_Button(0x00c0c0, "test2", test2);

		stage.addEventListener(Event.RESIZE, on_Stage_Resize);
		invalidate(Visel.INVALIDATION_FLAG_SIZE);
	}

	function toggle_Konsole(v: Dynamic): Void
	{
		k.toggle_View();
	}

	function add_Tool_Button(cl: Int, txt: String, f: Dynamic->Void): Button
	{
		var r: Root = Root.instance;
		var b: Button = new Button(tb_, txt, f);
		var w: Float = r.tool_width_;
		aux_.text = txt;
		w = Util.fmax(w, aux_.width + 8);
		b.resize(w, r.tool_height_);
		b.dummy_color = cl;
		return b;
	}

	private function on_Stage_Resize(e:Event):Void
	{
		invalidate(Visel.INVALIDATION_FLAG_SIZE);
	}

	override public function draw(): Void
	{
		super.draw();
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
		{
			resize(stage.stageWidth, stage.stageHeight);
			var r: Root = Root.instance;
			tb_.movesize(0, height_ - r.tool_height_, width_, r.tool_height_);
		}
	}

	public static function create_UI(stage: Stage)
	{
		var r: Root = Root.create(stage);

		var cfg: KonsoleConfig = new KonsoleConfig();
		k = new Konsole(cfg);
		k.set_View(KonsoleView);
		k.start(stage);
		//k.add("foo");
		//k.add("bar");

		new KonsoleDemo(stage);
	}

	function test1(v: Dynamic): Void
	{
		add_Counter();
	}

	function test2(v: Dynamic): Void
	{
		Timer.delay(append_Test1, 100);
	}


	function append_Test1()
	{
		for (i in 0...10)
		{
			add_Counter();
		}
		Timer.delay(append_Test1_1, 200);
	}

	function append_Test1_1()
	{
		for (i in 1...5)
		{
			add_Counter();
		}
	}

	function add_Counter(): Void
	{
		//k.add(Std.string(++counter_));
		var s: String = Std.string(++counter_);
		if ((counter_ & 1) != 0)
			s = "<b>" + s + "</b>";
		s = "<p>" + s + "</p>";
		k.add_Html(s);
	}

}