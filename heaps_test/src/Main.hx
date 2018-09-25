//import com.gs.console.KonsoleConfig;

import gs.femto_ui.Align;
import gs.femto_ui.InfoClick;
import gs.femto_ui.Label;
import gs.femto_ui.Button;
import gs.femto_ui.Root;
import gs.femto_ui.Toolbar;
//import gs.femto_ui.Viewport;
import gs.femto_ui.Visel;
import hxd.Event;
import hxd.Key;

import h2d.Bitmap;
import hxd.App;

#if flash
	//import com.gs.console.KonController;
	import flash.Lib;
#end

class Main extends App
{
	var b: h2d.Bitmap;

	var v_: Visel;
	var al_: Label;
	var b_: Button;
	var tb_: Toolbar;
	//var vp_: Viewport;
	var debug_counter_: Int = 0;

	static function main()
	{
		init_Console();
		new Main();
	}

	static function init_Console()
	{
//#if flash
		//var cfg: KonsoleConfig = new KonsoleConfig();
		//KonController.start(null, cfg);
//#end
	}

	override function init(): Void
	{
		trace("ENTER init");

		engine.backgroundColor = 0x4A4137;

		b = new h2d.Bitmap(h2d.Tile.fromColor(0xff0000, 160, 160), s2d);
		b.x = 250;
		b.y = 280;

		b.tile = b.tile.center();
		b.rotation = Math.PI / 4;

		var ni = new h2d.Interactive(b.tile.width, b.tile.height, b);
		ni.propagateEvents = true;
		// необходимо сместить интерактивный объект для учета его якорной точки,
		// которая находится посередине тайла
		ni.x = -0.5 * b.tile.width;
		ni.y = -0.5 * b.tile.height;

		// Обработчики событий
		ni.onOver = function(_) b.alpha = 0.5;
		ni.onOut = function(_) b.alpha = 1.0;

		add_Root();

		add_UI();

		//test_Visel();

		add_Text();

		hxd.Stage.getInstance().addEventTarget(onEvent);

		trace("LEAVE init");
	}

	function add_Root()
	{
		#if flash
		var ui_owner = Lib.current;
		#else
		var ui_owner = s2d;
		#end
		Root.create(ui_owner);
	}

	function add_UI()
	{
		var r: Root = Root.instance;
		v_ = new Visel(r.owner_);
		v_.dummy_color_ = 0xff00ff;
		v_.dummy_alpha_ = .75;
		v_.x = 400;
		v_.y = 20;
		v_.resize_Visel(150, 100);

		var panel: Visel = new Visel(r.owner_);
		panel.move_Visel(50, 100);
		panel.resize_Visel(800, 600);
		panel.dummy_color = 0x443322;
		panel.dummy_alpha = 0.5;

		al_ = new Label(panel, "Foo");
		al_.dummy_color_ = 0x8f008f;
		al_.dummy_alpha_ = 0.5;
		al_.movesize(20, 20, 220, 60);

		b_ = new Button(panel, "Click me!", on_Click);
		b_.tag_ = 1100101;
		b_.dummy_color_ = 0x00008f;
		b_.dummy_alpha_ = 1;
		b_.movesize(20, 20 + 100, 220, 60);
		b_.auto_repeat = true;

		tb_ = new Toolbar(panel);
		tb_.dummy_color_ = 0x00008f;
		tb_.dummy_alpha_ = .5;
		tb_.spacing_ = 8;
		tb_.x_border_ = 8;
		tb_.move_Visel(10, panel.height - 60);
		tb_.resize_Visel(panel.width - 20, 60);

		var btn = new Button(tb_, "1", on_Click1);
		btn.dummy_color = 0xc02040;
		btn.resize_Visel(120, 42);
		btn = new Button(tb_, "2", on_Click);
		btn.dummy_color = 0x202040;
		btn.resize_Visel(120, 42);
	}

	function on_Click(ev: InfoClick)
	{
		trace("click #" + debug_counter_++ + ", " + ev.mx_ + ": " + ev.my_);
	}

	function on_Click1(ev: InfoClick)
	{
		/*
		if (null == vp_)
		{
			vp_ = new Viewport();
			vp_.dummy_color_ = 0x408040;
			vp_.dummy_alpha_ = 0.5;
			vp_.movesize(10, 20, 320, 200);
		}
		else
		{
			vp_.visible = !vp_.visible;
		}
		*/
	}
	/*
			p.find("#fps").text(Std.string(engine.fps));
			p.find("#calls").text(numberFormat(engine.drawCalls));
			p.find("#tris").text(numberFormat(engine.drawTriangles));
	*/

	function onEvent(event : Event)
	{
		switch (event.kind)
		{
			case EKeyDown:
				trace('DOWN keyCode: 0x${StringTools.hex(event.keyCode, 2)}');
			case EKeyUp:
				trace('UP keyCode: 0x${StringTools.hex(event.keyCode, 2)}');
				on_Key_Down(event);
			case _:
		}
	}

	function on_Key_Down(event: Event)
	{
		switch (event.keyCode)
		{
			case Key.V:
				v_.visible = !v_.visible;
			case Key.A:
				v_.dummy_alpha = if (v_.dummy_alpha < 0.5) 1. else 0.25;
			case Key.C:
				v_.dummy_color = v_.dummy_color ^ 0xff00ff;
			case Key.W:
				v_.width = 200 - v_.width;
			case Key.H:
				v_.height = 450 - v_.height;
			case Key.R:
				v_.resize_Visel(200 - v_.width, 450 - v_.height);
			case Key.DELETE:
				v_.destroy_Visel();
			case Key.Q:
				al_.h_align =
					switch (al_.h_align)
				{
					case Align.NEAR:
						Align.CENTER;
					case Align.CENTER:
						Align.FAR;
					case Align.FAR:
						Align.NEAR;
				}
			case Key.Z:
				al_.v_align =
					switch (al_.v_align)
				{
					case Align.NEAR:
						Align.CENTER;
					case Align.CENTER:
						Align.FAR;
					case Align.FAR:
						Align.NEAR;
				}
		}
	}

	function test_Visel()
	{
		Test1.run_All();
	}

	function add_Text()
	{
		var maxw = 220;
		var mask = new h2d.Mask(maxw, 260, s2d);
		mask.x = 10;
		mask.y = 300;
		var t = new h2d.HtmlText(hxd.res.DefaultFont.get(), mask);
		//var t = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
		t.maxWidth = maxw;
		//t.
		//t.scale(10);
		t.x = 10;
		t.y = 10;
		//var s = "Haxe <font color='#ff0000'>Rocks!!!</font>";
		var s = gen_Text();
		t.text = s;
	}

	function gen_Text() : String
	{
		var s: StringBuf = new StringBuf();
		for (i in 0...2048)
		{
			if ((i & 1) != 0)
				s.add("#<font color='#ff0000'>");
			else
				s.add("#<font color='#0000ff'>");
			s.add(i);
			s.add("</font>");
			s.add(" bla bla bla bla bla bla bla bla bla bla bla!");
			s.add("<br/>");
			//s.add("\n");
		}
		return s.toString();
	}

	override function update(dt: Float): Void
	{
		b.rotation += 0.01;

		Root.instance.update();
	}
}