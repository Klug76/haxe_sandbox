package;

import gs.femto_ui.InfoClick;
import gs.konsole.KonController;
import gs.konsole.Konsole;
import gs.konsole.KonsoleConfig;
import gs.konsole.KonsoleView;
import gs.konsole.Ruler;
import gs.femto_ui.Button;
import gs.femto_ui.Root;
import gs.femto_ui.Toolbar;
import gs.femto_ui.Visel;
import gs.femto_ui.util.Util;
import flash.Vector;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Loader;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.errors.Error;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import flash.utils.ByteArray;
import haxe.Json;
import haxe.Timer;
#if flash
import flash.xml.XML;
#end

import gs.konsole.KonController.Log;
import gs.konsole.KonController.Log_Html;

class KonsoleDemo extends Visel
{
	private var tb_: Toolbar;
	private var aux_: TextField;
	private var counter_: Int = 0;
	private var arr_: Array<Int>;
	private var asset_: Loader;

	public static function create_UI(owner: DisplayObjectContainer): Void
	{
		var cfg: KonsoleConfig = new KonsoleConfig();

		//cfg.zoom_root_ = owner.stage;
		cfg.zoom_root_ = owner;
		//cfg.con_bg_color_ = 0xFF000000;
		//cfg.con_text_color_ = 0x77BB77;
		//cfg.con_text_size_ = 18;

		KonController.start(owner, cfg);
		//KonController.start(owner.stage, cfg);

		new KonsoleDemo(owner);
	}

	public function new(owner : DisplayObjectContainer)
	{
		super(owner);
		visible = false;//:draw should make this visible
		create_Children();

		//test1(null);
		//test2(null);
		//KonController.visible = true;

		KonController.register_Object("world", this);
		//KonController.eval("world.counter_");
	}

	function create_Children(): Void
	{
		var r: Root = Root.instance;
		if (null == r)
		{
			r = Root.create(parent);
		}

		aux_ = new TextField();
		aux_.autoSize = TextFieldAutoSize.LEFT;
		aux_.defaultTextFormat = new TextFormat(null, Std.int(r.def_text_size_));

		add_Bitmap_Asset();
		add_Box();

		tb_ = new Toolbar(this);
		tb_.spacing_ = 6;
		tb_.dummy_color = 0xd0d0d0;

		add_Tool_Button(0x0000c0, "~", toggle_Konsole);
		add_Tool_Button(0x9C27B0, "test1", test1);
		add_Tool_Button(0xDB4437, "test2", test2);
		add_Tool_Button(0x3F51B5, "+mem", eat_Mem);
		add_Tool_Button(0x9C27B0, "err", log_Error);
		add_Tool_Button(0xFF9800, "cmd", do_Command);
		add_Tool_Button(0x3F51B5, "xml", log_Xml);
		add_Tool_Button(0xDB4437, "data", log_Data);
		add_Tool_Button(0xFF9800, "eval", eval_Test);
		add_Tool_Button(0xc00020, "clear", clear);

		KonController.register_Command("foo", cmd_Foo, "test command");
		KonController.register_Command("zoo", cmd_Zoo, "test command #2");

		stage.addEventListener(Event.RESIZE, on_Stage_Resize);
		stage.addEventListener(Event.ACTIVATE, on_Stage_Activate);
		stage.addEventListener(Event.DEACTIVATE, on_Stage_Deactivate);
		addEventListener(MouseEvent.CLICK, on_Click);

 		on_Stage_Resize(null);
	}

	private var click_id_: Int = 0;

	private function on_Click(ev: MouseEvent) : Void
	{
		Log("click " + click_id_++);
	}

	private function add_Box(): Void
	{
		var sp: Shape = new Shape();
		var gr: Graphics = sp.graphics;
		gr.clear();
		gr.beginFill(0x0000ff, 1);
		gr.drawRect(0, 0, 10, 20);
		gr.endFill();
		sp.x = 100;
		sp.y = 100;
		addChild(sp);
	}

	private function add_Bitmap_Asset(): Void
	{
		#if (openfl)
		var bitmapData = openfl.Assets.getBitmapData("assets/steam1.jpg");
        var bitmap = new Bitmap (bitmapData);
        place_Asset(bitmap);
		#else
		var uri: String = "https://fishgame.staticgs.com/thumb/collect/steam1.jpg";
		asset_ = new Loader();
		asset_.contentLoaderInfo.addEventListener(Event.COMPLETE, load_Complete_Handler);
		asset_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, load_Error_Handler);
		asset_.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, load_Error_Handler);
		var rq: URLRequest = new URLRequest(uri);
		asset_.load(rq);
		#end
	}


	private function load_Complete_Handler(e: Event): Void
	{
		//k.add("OK");
		asset_Cleanup();
		var b: DisplayObject = asset_.content;
		place_Asset(b);
	}

	private function place_Asset(b: DisplayObject) : Void
	{
		b.x = 250;
		b.y = 100;
		addChild(b);
	}

	private function load_Error_Handler(e: Event): Void
	{
		Log(e.toString());
	}

	private function asset_Cleanup(): Void
	{
		asset_.contentLoaderInfo.removeEventListener(Event.COMPLETE, load_Complete_Handler);
		asset_.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, load_Error_Handler);
		asset_.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, load_Error_Handler);
	}

	function toggle_Konsole(_): Void
	{
		KonController.toggle();
	}

	function clear(_): Void
	{
		KonController.clear();
	}

	function add_Tool_Button(cl: Int, txt: String, f: InfoClick->Void): Button
	{
		var r: Root = Root.instance;
		var b: Button = new Button(tb_, txt, f);
		var w: Float = r.tool_width_;
		aux_.text = txt;
		w = Util.fmax(w, aux_.width + 8);
		b.resize_Visel(w, r.tool_height_);
		b.dummy_color = cl;
		return b;
	}

	private function on_Stage_Resize(e: Event): Void
	{
		invalidate_Visel(Visel.INVALIDATION_FLAG_STAGE_SIZE);
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

	override public function draw_Visel(): Void
	{
		super.draw_Visel();
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_STAGE_SIZE) != 0)
		{
			resize_Visel(stage.stageWidth, stage.stageHeight);
		}
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_SIZE) != 0)
		{
			var r: Root = Root.instance;
			tb_.movesize(0, height_ - r.tool_height_, width_, r.tool_height_);
			visible = true;
		}
	}

	private function cmd_Foo(dummy: Array<String>): Void
	{
		Log("command::foo()");
	}

	private function cmd_Zoo(dummy: Array<String>): Void
	{
		Log("command::zoo()");
	}

	function test1(_): Void
	{
		add_Counter();
	}

	function test2(_): Void
	{
		Log("Konsole v." + KonController.VERSION + ", ui factor=" + Root.instance.ui_factor_);

		Log_Html("<p>Hello, <font color='#FF8000'>World</font>! Тест!</p>");
		Log_Html("pure text");
		Log("1 < 2 & 6\n  4 > 1 & 0");
		Log("\n");
		Log('');
		foo(Keyboard.ESCAPE);
#if (flash >= 10.2)
		foo(Keyboard.BACK);
		foo(Keyboard.BACK);
#end
#if (flash >= 10.1)
		foo(Keyboard.A);
#end
		Log('');
		Timer.delay(append_Test1, 100);

		var s: String = KonController.get_Text();
		if (null == s)
			s = "";
		Log("text.length=" + s.length);
	}

	private function foo(u: UInt): Void
	{
		Log(u);
		switch(u)
		{
		case Keyboard.ESCAPE:
			Log("Esc");
#if (flash >= 10.2)
		case Keyboard.BACK:
			Log("Back");
#end
		}
#if (flash >= 10.2)
		if (u == Keyboard.BACK)
			Log("*Back");
#end
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
		Log_Html(s);
	}

	function eat_Mem(_): Void
	{
		arr_ = [for (i in 0...1000000) i];
	}

	function log_Error(_): Void
	{
		try
		{
			throw_String();
		}
		catch (err: Dynamic)
		{
			Log(err);
		}
		try
		{
			throw_Error();
		}
		catch (err: Dynamic)
		{
			Log(err);
		}
	}

	function throw_Error(): Void
	{
		throw new Error("flash::error");
	}

	function throw_String(): Void
	{
		throw "string::error";
	}

	function do_Command(_): Void
	{
		var cmd = "/ruler";
		KonController.eval(cmd);
	}

	function eval_Test(_): Void
	{
		KonController.eval("2+3");
	}

	function log_Xml(_): Void
	{
		var s: String = '<root><hello name="world!">Haxe is suxx!</hello><hello name="world!">Haxe is sux!</hello></root>';
#if flash
		var x = new XML(s);
#else
		var x = Xml.parse(s);
#end
		Log(x);
	}

	function log_Data(_): Void
	{
		Log("null:");
		Log(null);

		Log("NaN:");
		Log(Math.sqrt( -1));

		var b: Bool = true;
		Log("Bool:");
		Log(b);
		Log(!b);

		var n: Int = 1100101;
		Log("Int:");
		Log(n);


		var u: UInt = 0xdeadbeaf;
		Log("UInt:");
		Log(Type.typeof(u));
		Log(u);

		var f: Float = 1. / 3;
		Log("Float:");
		Log(f);

		var ai: Array<Int> = [for (i in 1...41) i];
		Log("Array:");
		Log(ai);

		Log("Vector<Int>:");
		var vi: Vector<Int> = new Vector<Int>();
		Log(vi);
		vi.push(1);
		vi.push(8);
		vi.push(2);
		Log(vi);

		Log("Vector<Float>:");
		var vf: Vector<Float> = new Vector<Float>();
		vf.push(f);
		vf.push(f);
		Log(vf);

		Log("Vector<String>:");
		var vs: Vector<String> = new Vector<String>();
		vs.push("foo");
		vs.push("bar");
		Log(vs);

		Log("ByteArray:");
		var ba: ByteArray = new ByteArray();
		//ba.writeByte('0'.code);
		//ba.writeByte('1'.code);
		//k.add(ba);
		for (i in 0...100)
			ba.writeByte(i & 0xFF);
		Log(ba);

		var ob: Dynamic = Json.parse('{"key1":[{"key2":5},67,null,"test"],"key3":[true,false]}');
		Log("Object:");
		Log(ob);
	}
}