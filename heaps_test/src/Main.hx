//import com.gs.console.KonsoleConfig;

import gs.femto_ui.Align;
import gs.femto_ui.Edit;
import gs.femto_ui.InfoClick;
import gs.femto_ui.Label;
import gs.femto_ui.Button;
import gs.femto_ui.Mover;
import gs.femto_ui.Resizer;
import gs.femto_ui.Root;
import gs.femto_ui.ScrollText;
import gs.femto_ui.Scrollbar;
import gs.femto_ui.Toolbar;
import gs.femto_ui.Viewport;
import gs.femto_ui.Visel;
import gs.femto_ui.util.Util;
import gs.konsole.Konsole;
import gs.konsole.KonsoleConfig;
import gs.konsole.KonsoleView;
import h2d.TextInput;
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
	var vp1_: Viewport;
	var vp2_: Viewport;
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
		b.alpha = 0.4;

		b.tile = b.tile.center();
		b.rotation = Math.PI / 4;

		var ni = new h2d.Interactive(b.tile.width, b.tile.height, b);
		ni.propagateEvents = true;
		// необходимо сместить интерактивный объект для учета его якорной точки,
		// которая находится посередине тайла
		ni.x = -0.5 * b.tile.width;
		ni.y = -0.5 * b.tile.height;

		// Обработчики событий
		ni.onOver = function(_) b.alpha = 1;
		ni.onOut = function(_) b.alpha = 0.4;

		add_Root();
		add_Konsole();
		add_UI();

		//test_Visel();

		//add_Text();

		hxd.Window.getInstance().addEventTarget(onEvent);

		trace("LEAVE init");
	}

	function add_Root()
	{
		//#if flash
		//var ui_owner = Lib.current;
		//#else
		var ui_owner = s2d;
		//#end
		Root.create(ui_owner);
	}

	function add_UI()
	{
		var r: Root = Root.instance;

		v_ = new Visel(r.owner_);
		v_.name = "v_";
		v_.dummy_color_ = 0xff00ff;
		v_.dummy_alpha_ = .75;
		v_.x = 620;
		v_.y = 10;
		v_.resize_Visel(150, 100);

		var panel: Visel = new Visel(r.owner_);
		panel.name = "panel";
		panel.move_Visel(100, 100);
		panel.resize_Visel(r.stage_width - 230, r.stage_height - 160);
		panel.dummy_color_ = 0x443322;
		panel.dummy_alpha_ = 0.25;

		al_ = new Label(panel, "Foo");
		al_.dummy_color_ = 0x8f008f;
		al_.dummy_alpha_ = 0.5;
		al_.movesize(110, 20, 200, 42);

		b_ = new Button(panel, "Click me!", on_Click);
		//b_.tag_ = 1100101;
		b_.dummy_color_ = 0x00008f;
		b_.dummy_alpha_ = 1;
		b_.movesize(-10, 100, 200, 50);
		b_.auto_repeat = true;

		tb_ = new Toolbar(panel);
		tb_.dummy_color_ = 0x00008f;
		tb_.dummy_alpha_ = .5;
		tb_.spacing_ = 8;
		tb_.x_border_ = 8;
		tb_.move_Visel(10, panel.height - 60);
		tb_.resize_Visel(panel.width - 20, 60);

		var btn: Button;
		btn = new Button(tb_, "1", on_Click1);
		btn.dummy_color = 0xc02040;
		btn.resize_Visel(120, 42);
		btn = new Button(tb_, "2", on_Click2);
		btn.dummy_color = 0x202040;
		btn.resize_Visel(120, 42);

		//for (i in 0...3)
		for (i in 0...1)
		{
			var st: ScrollText = new ScrollText(panel, true);
			st.set_Text_Format("", 18, 0xf0ff00);
			st.word_wrap = true;
			st.movesize(350 + i * 200, 10, 150, panel.height - 100);
			st.dummy_color = 0x000097;
			//st.text = "foo<br>bar";
			var txt = gen_Text(i);
			//trace(txt);
			st.replace_Text(txt);

			var sc: Scrollbar = new Scrollbar(panel, function(v: Int): Void
			{
				//trace("Scrollbar::scroll " + v);
				if (v > 0)
					st.set_ScrollV(v);
			});
			sc.movesize(350 + i * 200 + 150, 10, r.small_tool_width_, panel.height - 100);
			sc.reset(1, st.get_Max_ScrollV(), 1);

			st.on_text_scroll =
			st.on_text_change = function()
			{
				sc.max = st.get_Max_ScrollV();
				sc.value = st.get_ScrollV();
			};

			var m: Mover = new Mover(st);
			m.resize_Visel(r.tool_width_, r.tool_height_);
			m.dummy_color = 0x40000000 | r.color_movesize_;

			var rz: Resizer = new Resizer(st);
			rz.dummy_color = 0x40000000 | r.color_movesize_;
			rz.min_width_ = r.tool_width_;
			rz.min_height_ = r.tool_height_;
			st.on_Resize = function()
			{
				//trace("scrolltext::size=" + st.width + "x" + st.height);
				rz.movesize(st.width - r.small_tool_width_, st.height - r.small_tool_height_, r.small_tool_width_, r.small_tool_height_);
			};

			btn = new Button(tb_, "1_" + i, function(_)
			{
				st.append_Text("<br/>#" + debug_counter_++);
			});
			//btn.on_Click(null);
			btn.dummy_color = 0x202040;
			btn.resize_Visel(60, 42);
			btn = new Button(tb_, "2_" + i, function(_)
			{
				st.append_Text("<br/>#" + debug_counter_++ + "______________ __________");
			});
			btn.dummy_color = 0x202040;
			btn.resize_Visel(60, 42);
		}

		var m: Mover = new Mover(panel);
		m.resize_Visel(r.tool_width_, r.tool_height_);
		m.dummy_color = r.color_movesize_;

		var rz: Resizer = new Resizer(panel);
		rz.dummy_color = r.color_movesize_;
		rz.min_width_ = r.tool_width_;
		rz.min_height_ = r.tool_height_;

		panel.on_Resize = function()
		{
			rz.movesize(panel.width - r.small_tool_width_, panel.height - r.small_tool_height_, r.small_tool_width_, r.small_tool_height_);
		};
	}

	function on_Click(ev: InfoClick)
	{
		trace("click #" + debug_counter_++ + ", " + ev.global_x_ + ": " + ev.global_y_);
	}

	function on_Click1(ev: InfoClick)
	{
		var r: Root = Root.instance;
		if (null == vp1_)
		{
			vp1_ = new Viewport();
			vp1_.dummy_color_ = 0x408040;
			vp1_.dummy_alpha_ = 0.75;
			vp1_.movesize(10, 20, 320, 200);
		}
		else
		{
			vp1_.visible = !vp1_.visible;
		}
	}

	function on_Click2(ev: InfoClick)
	{
		var r: Root = Root.instance;
		if (null == vp2_)
		{
			vp2_ = new Viewport();
			vp2_.dummy_color_ = 0x208060;
			vp2_.dummy_alpha_ = 0.75;
			vp2_.movesize(15, 25, 320, 200);

			var edit = new Edit(vp2_, on_Edit_Changed, "123");
			edit.dummy_color = 0x445566;
			edit.movesize(50, 100, 180, 60);
		}
		else
		{
			vp2_.visible = !vp2_.visible;
		}
	}

	function on_Edit_Changed(s: String)
	{
		trace("***** edit::text = '" + s + "'");
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
				//trace('DOWN keyCode: 0x${StringTools.hex(event.keyCode, 2)}');
			case EKeyUp:
				//trace('UP keyCode: 0x${StringTools.hex(event.keyCode, 2)}');
				on_Key_Down(event);
			case _:
		}
	}

	function on_Key_Down(ev: Event)
	{
		switch (ev.keyCode)
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
		//default:
		}
		if (instance_ != null)
		{
			if (ev.keyCode == instance_.cfg_.toggle_key_)
			{
				ev.cancel = true;
				toggle_Konsole();
			}
		}

	}

	function test_Visel()
	{
		Test1.run_All();
	}

	function add_Text()
	{
		//TODO make native input!?
		//var inp = new TextInput(hxd.res.DefaultFont.get(), s2d);
		//inp.x = 10;
		//inp.y = 300;
		//inp.backgroundColor = 0x506070;
		var maxw = 220;
		var maxh = 260;
		var bg = new h2d.Bitmap(h2d.Tile.fromColor(0x608060, maxw, maxh), s2d);
		bg.x = 410;
		bg.y = 300;
		var mask = new h2d.Mask(maxw, maxh, s2d);
		mask.x = 410;
		mask.y = 300;
		var t = new h2d.HtmlText(hxd.res.DefaultFont.get(), mask);
		//var t = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
		//t.textAlign = h2d.Text.Align.Center;
		//t.condenseWhite = false;//TODO fix me!
		t.maxWidth = maxw;
		var s = gen_Text0();
		t.text = s;
	}

	function gen_Text00() : String
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
		}
		return s.toString();
	}

	function gen_Text0() : String
	{
		var s: StringBuf = new StringBuf();
		s.add("start:");
		/*
		for (i in 0...2)
		{
			//if ((i & 1) != 0)
				//s.add("#<font color='#ff0000'>");
			//else
				//s.add("#<font color='#0000ff'>");
			//s.add(i);
			//s.add("</font>");
			if ((i & 1) != 0)
				s.add("<p align='center'>bla bla bla bla bla bla bla bla bla bla bla!</p>");
			else
				s.add("<p>bla bla bla bla bla bla bla bla bla bla bla!</p>");
		}
		*/
		s.add("<p>1 &gt; 0 &lt;    1</p>");
		s.add("<p>2&amp;lt;2</p>");
		s.add("end.");
		return s.toString();
	}
/*
		h.set("amp", "&");
		h.set("quot", '"');
		h.set("apos", "'");
*/
	function gen_Text(id: Int) : String
	{
		var s: StringBuf = new StringBuf();
		for (i in 0...24)
		{
			if ((i & 1) != 0)
				s.add("#<font color='#ff0000'>");
			else
				s.add("#<font color='#0000ff'>");
			s.add(i);
			s.add("</font>");
			s.add(" bla bla bla bla bla bla bla bla bla bla bla!");
			s.add("<br/>");
		}
		s.add("end.");
		return s.toString();
	}

	function add_Konsole()
	{
		var cfg: KonsoleConfig = new KonsoleConfig();
		//cfg.allow_command_line_ = false;
		var k: Konsole = new Konsole(cfg);
		instance_ = k;
		k.log("Hello,");
		trace("World!");
		trace("char by 0x60='" + String.fromCharCode(0x60) + "'");
		trace("char by 0xc0='" + String.fromCharCode(0xc0) + "'");
		trace("'`'.code=0x" + Util.toHex('`'.code));
		trace("'~'.code=0x" + Util.toHex('~'.code));

		var dbg: String = "false";
#if debug
		dbg = "<font color='#FFFF00'>true</font>";
#end
		var info: String = "<p><b>Welcome to ";
		info								+= "konsole-heaps";
		info += ", debug=";
		info								+= dbg;
		info += "</b></p>";
		k.log_Html(info);

	}

	private var instance_: Konsole = null;
 	private var view_: KonsoleView = null;

	function get_Visible(): Bool
	{
		if (view_ != null)
			return view_.visible;
		return false;
	}
	function set_Visible(value: Bool): Bool
	{
		if (instance_ != null)
		{
			if (value)
			{
				if (null == view_)
				{
					//trace("******* ENTER new KonsoleView");
					var r: Root = Root.instance;
					instance_.cfg_.init_View(r.platform_, r.ui_factor_);
					//trace("*******");
					//view_ = new KonsoleView(instance_, false);
					view_ = new KonsoleView(instance_, true);
					//trace("******* LEAVE new KonsoleView");
				}
				else
				{
					view_.visible = true;
				}
				instance_.signal_show_.fire();
				//trace("******* Konsole::signal_show_.fire()");
			}
			else
			{
				if (view_ != null)
					view_.visible = false;
			}
		}
		return value;
	}

	function toggle_Konsole()
	{
		set_Visible(!get_Visible());
	}

	override function update(dt: Float): Void
	{
		b.rotation += 0.01;

		Root.instance.update();
	}
}

