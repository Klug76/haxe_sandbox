package com.gs;

import com.gs.console.Konsole;
import com.gs.console.KonsoleConfig;
import com.gs.console.KonsoleView;
import com.gs.femto_ui.Button;
import com.gs.femto_ui.Root;
import com.gs.femto_ui.Toolbar;
import com.gs.femto_ui.Visel;
import com.gs.femto_ui.util.Util;
import flash.Vector;
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import flash.errors.Error;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.ByteArray;
import haxe.Json;
import haxe.Timer;
#if flash
import flash.xml.XML;
#end

class KonsoleDemo extends Visel
{
	private var tb_: Toolbar;
	private var aux_: TextField;
	private var counter_: Int = 0;
	private static var k: Konsole;
	private var arr_: Array<Int>;
	private var ruler_: Ruler;

	public function new(owner : DisplayObjectContainer)
	{
		super(owner);
		visible = false;
		create_Children();
	}

	function create_Children()
	{
		var r: Root = Root.instance;

		aux_ = new TextField();
		aux_.autoSize = TextFieldAutoSize.LEFT;
		aux_.defaultTextFormat = new TextFormat(null, Std.int(r.def_text_size_));

		tb_ = new Toolbar(this);
		tb_.spacing_ = 6;
		tb_.dummy_color = 0xd0d0d0;

		add_Tool_Button(0x0000c0, "~", toggle_Konsole);
		add_Tool_Button(0x9C27B0, "test1", test1);
		add_Tool_Button(0xDB4437, "test2", test2);
		add_Tool_Button(0x3F51B5, "eat", eat_Mem);
		add_Tool_Button(0x9C27B0, "err", log_Error);
		add_Tool_Button(0xFF9800, "cmd", do_Command);
		add_Tool_Button(0x3F51B5, "xml", log_Xml);
		add_Tool_Button(0xDB4437, "data", log_Data);
		add_Tool_Button(0xFF9800, "eval", eval_Test);
		add_Tool_Button(0xc00020, "clear", clear);

		k.register_Command("foo", cmd_Foo, "test command");
		k.register_Command("zoo", cmd_Zoo, "test command #2");
		k.register_Command("ruler", cmd_Ruler, "show display ruler");


		stage.addEventListener(Event.RESIZE, on_Stage_Resize);
		stage.addEventListener(Event.ACTIVATE, on_Stage_Activate);
		stage.addEventListener(Event.DEACTIVATE, on_Stage_Deactivate);
 		invalidate(Visel.INVALIDATION_FLAG_SIZE);
	}

	function toggle_Konsole(v: Dynamic): Void
	{
		k.toggle_View();
	}

	function clear(v: Dynamic): Void
	{
		k.clear();
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

	private function on_Stage_Resize(e: Event): Void
	{
		invalidate(Visel.INVALIDATION_FLAG_SIZE);
	}

	private function on_Stage_Activate(e: Event): Void
	{
		//trace("demo::activate");
		//TODO review: openfl bug: set 29
		if (stage.frameRate <= 15)
			stage.frameRate = 30;
	}

	private function on_Stage_Deactivate(e: Event): Void
	{
		//trace("demo::deactivate");
		stage.frameRate = 15;
	}

	override public function draw(): Void
	{
		super.draw();
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
		{
			resize(stage.stageWidth, stage.stageHeight);
			var r: Root = Root.instance;
			tb_.movesize(0, height_ - r.tool_height_, width_, r.tool_height_);
			visible = true;
		}
	}

	public static function create_UI(stage: Stage) : Void
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

	private function cmd_Foo(dummy: Array<String>): Void
	{
		k.add("command::foo()");
	}

	private function cmd_Zoo(dummy: Array<String>): Void
	{
		k.add("command::zoo()");
	}

	private function cmd_Ruler(dummy: Array<String>): Void
	{
		if (ruler_ != null)
		{
			ruler_.visible = !ruler_.visible;
			return;
		}
		ruler_ = new Ruler(k);
		k.add("show ruler");
	}

	function test1(v: Dynamic): Void
	{
		add_Counter();
	}

	function test2(v: Dynamic): Void
	{
		k.add_Html("<p>Hello, <font color='#FFFF00'>World</font>! Тест!</p>");
		k.add("1 < 2 & 6\n  4 > 1 & 0");
		k.add("\n");
		k.add('');
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

	function eat_Mem(v: Dynamic): Void
	{
		arr_ = [for (i in 0...1000000) i];
	}

	function log_Error(v: Dynamic): Void
	{
		try
		{
			throw_String();
		}
		catch (err: Dynamic)
		{
			k.add(err);
		}
		try
		{
			throw_Error();
		}
		catch (err: Dynamic)
		{
			k.add(err);
		}
	}

	function throw_Error()
	{
		throw new Error("flash::error");
	}

	function throw_String()
	{
		throw "string::error";
	}

	function do_Command(ev: Dynamic): Void
	{
		var cmd = "/ruler";
		k.eval(cmd);
	}

	function eval_Test(ev: Dynamic): Void
	{
		k.eval("2+3");
	}

	function log_Xml(v: Dynamic): Void
	{
		var s: String = '<root><hello name="world!">Haxe is suxx!</hello><hello name="world!">Haxe is sux!</hello></root>';
#if flash
		var x = new XML(s);
#else
		var x = Xml.parse(s);
#end
		k.add(x);
	}

	function log_Data(ev: Dynamic): Void
	{
		k.add("null:");
		k.add(null);

		k.add("NaN:");
		k.add(Math.sqrt( -1));

		var b: Bool = true;
		k.add("Bool:");
		//k.add(Type.typeof(b));
		k.add(b);
		k.add(!b);

		var n: Int = 1100101;
		k.add("Int:");
		//k.add(Type.typeof(n));
		k.add(n);


		var u: UInt = 0xdeadbeaf;
		k.add("UInt:");
		k.add(Type.typeof(u));
		k.add(u);

		var f: Float = 1. / 3;
		k.add("Float:");
		//k.add(Type.typeof(f));
		k.add(f);

		var ai: Array<Int> = [for (i in 1...41) i];
		k.add("Array:");
		k.add(ai);

		k.add("Vector<Int>:");
		var vi: Vector<Int> = new Vector<Int>();
		k.add(vi);
		vi.push(1);
		vi.push(8);
		vi.push(2);
		k.add(vi);

		k.add("Vector<Float>:");
		var vf: Vector<Float> = new Vector<Float>();
		vf.push(f);
		vf.push(f);
		k.add(vf);

		k.add("Vector<String>:");
		var vs: Vector<String> = new Vector<String>();
		vs.push("foo");
		vs.push("bar");
		k.add(vs);

		k.add("ByteArray:");
		var ba: ByteArray = new ByteArray();
		//ba.writeByte('0'.code);
		//ba.writeByte('1'.code);
		//k.add(ba);
		for (i in 0...100)
			ba.writeByte(i & 0xFF);
		k.add(ba);

		var ob: Dynamic = Json.parse('{"key1":[{"key2":5},67,null,"test"],"key3":[true,false]}');
		k.add("Object:");
		k.add(ob);
	}
}