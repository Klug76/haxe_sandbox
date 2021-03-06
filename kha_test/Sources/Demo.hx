package;

import gs.femto_ui.Align;
import gs.femto_ui.Button;
import gs.femto_ui.Edit;
import gs.femto_ui.InfoClick;
import gs.femto_ui.Label;
import gs.femto_ui.Mover;
import gs.femto_ui.Resizer;
import gs.femto_ui.Root;
import gs.femto_ui.Scrollbar;
import gs.femto_ui.ScrollText;
import gs.femto_ui.Toolbar;
import gs.femto_ui.Viewport;
import gs.femto_ui.Visel;
import gs.femto_ui.kha.Event;
import gs.utils.Util;
import gs.konsole.Konsole;
import gs.konsole.KonsoleConfig;
import gs.konsole.KonsoleView;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.input.KeyCode;
import kha.Assets;

//import kha.Color;

class Demo
{
	var color_bg_: Int = 0x223344;
	var v_: Visel;
	var al_: Label;
	var b_: Button;
	var tb_: Toolbar;
	var vp1_: Viewport;
	var vp2_: Viewport;
	var debug_counter_: Int = 0;
	var instance_: Konsole = null;

	public function new()
	{
		test1();
		// Avoid passing update/render directly,
		// so replacing them via code injection works
		Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
		System.notifyOnFrames(function (framebuffers) { render(framebuffers[0]); });
	}

	function test1()
	{
		Root.create(null);
		//var fnt = Assets.fonts.get("SourceSansPro_Regular");
		var fnt = Assets.fonts.get("SourceSansPro_Semibold");
		//trace("font=" + fnt);
		Root.instance.font_ = fnt;

#if flash
		//TODO review: why font is so small?
		Root.instance.def_font_size_ *= 1.5;
#end

		//test_Visel();

		add_Konsole();
		add_UI();

		//Keyboard.get().notify(on_Key_Down, on_Key_Up);
		Root.instance.stage_.add_Listener(on_Stage_Event);
	}

	function add_UI()
	{
		var r: Root = Root.instance;

		v_ = new Visel(r.stage_);
		v_.name = "v_";
		v_.dummy_color_ = 0xff0000;
		v_.dummy_alpha_ = 1;
		v_.x = 620;
		v_.y = 10;
		v_.resize_Visel(150, 100);

		var panel: Visel = new Visel(r.stage_);
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
				st.append_Text("#" + debug_counter_++ + "\n");
			});
			btn.on_Click(null);
			btn.dummy_color = 0x202040;
			btn.resize_Visel(60, 42);
			btn.alpha = .5;
			btn = new Button(tb_, "2_" + i, function(_)
			{
				st.append_Text("#" + debug_counter_++ + "______________ __________\n");
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

	function gen_Text1(idx: Int) : String
	{
		var s: StringBuf = new StringBuf();
		var k = 10;
		if (idx > 0)
			k = 30;
		if (idx > 1)
			k = 1024;
		for (i in 0...k)
		{
			s.add("#" + (i + 1));
			s.add(" 1bla 2bla 3bla 4bla 5bla 6bla!");
			s.add("\n");
		}
		if (idx >= 2)
			s.add("end.");
		return s.toString();
	}

	function gen_Text2(idx: Int) : String
	{
		var s: StringBuf = new StringBuf();
		var k = 40;
		for (i in 0...k)
		{
			s.add("0x" + Util.toHex(i, 2) + "________________");
		}
		s.add("\n");
		s.add("\n");
		for (i in 0...k)
		{
			s.add("0x" + Util.toHex(i, 2) + "================");
		}
		s.add(".");
		return s.toString();
	}

	function gen_Text(idx: Int) : String
	{
		var s: StringBuf = new StringBuf();
		var k = 10;
		for (i in 0...k)
		{
			s.add("0x" + Util.toHex(i, 2) + "________________");
		}
		return s.toString();
	}

	function on_Click(ev: InfoClick)
	{
		trace("click #" + debug_counter_++ + ", " + ev.global_x_ + ": " + ev.global_y_);
		trace(ev.local_x_ + ": " + ev.local_y_);
	}

	function on_Click1(ev: InfoClick)
	{
		//var r: Root = Root.instance;
		if (null == vp1_)
		{
			vp1_ = new Viewport();
			vp1_.dummy_color_ = 0x804040;
			vp1_.dummy_alpha_ = 1;// 0.75;
			vp1_.movesize(10, 20, 320, 200);
			//@:privateAccess vp1_.button_close_.tag_ = 101;
		}
		else
		{
			vp1_.visible = !vp1_.visible;
		}
	}

	function on_Click2(ev: InfoClick)
	{
		//var r: Root = Root.instance;
		if (null == vp2_)
		{
			vp2_ = new Viewport();
			vp2_.dummy_color_ = 0x608060;
			vp2_.dummy_alpha_ = 1;// 0.75;
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

	function on_Stage_Event(ev: Event): Void
	{
		//trace(ev.dump());
		switch(ev.type)
		{
		case Event.KEY_DOWN:
			//trace('DOWN keyCode: 0x' + StringTools.hex(ev.code, 2));
			on_Key_Down(ev);
		case Event.KEY_UP:
			on_Key_Up(ev);
		}
	}

    private function on_Key_Down(ev: Event) : Void
	{
		//trace("stage::on_Key_Down " + ev.code);
		var code: KeyCode = cast ev.code;
		switch(code)
		{
		case KeyCode.F1:
			on_Click1(null);
		case KeyCode.F2:
			on_Click2(null);
		case KeyCode.V:
			v_.visible = !v_.visible;
		case KeyCode.A:
			v_.dummy_alpha = if (v_.dummy_alpha < 0.5) 1. else 0.25;
		case KeyCode.R:
			v_.resize_Visel(200 - v_.width, 450 - v_.height);
		case KeyCode.C:
			v_.dummy_color = v_.dummy_color ^ 0xff00ff;
		case KeyCode.Delete:
			v_.destroy_Visel();
		case KeyCode.Q:
			al_.h_align =
			switch(al_.h_align)
			{
			case Align.NEAR:
				Align.CENTER;
			case Align.CENTER:
				Align.FAR;
			case Align.FAR:
				Align.NEAR;
			}
		case KeyCode.Z:
			al_.v_align =
			switch(al_.v_align)
			{
			case Align.NEAR:
				Align.CENTER;
			case Align.CENTER:
				Align.FAR;
			case Align.FAR:
				Align.NEAR;
			}
		default:
		}
		if (instance_ != null)
		{
			if (code == instance_.cfg_.toggle_key_)
			{
				ev.stop_propagation = true;
				toggle_Konsole();
			}
		}
	}

    private function on_Key_Up(ev: Event) : Void
	{}

	function test_Visel()
	{
		//Test1.run_All();
	}

	function add_Konsole()
	{
		var cfg: KonsoleConfig = new KonsoleConfig();
		//cfg.allow_command_line_ = false;
		cfg.con_font_size_ *= 1.5;
		var k: Konsole = new Konsole(cfg);
		instance_ = k;
		k.log("Hello,");
		trace("World!");
		trace("char by 0x60='" + String.fromCharCode(0x60) + "'");
		trace("char by 0xc0='" + String.fromCharCode(0xc0) + "'");
		trace("'`'.code=0x" + Util.toHex('`'.code));
		trace("'~'.code=0x" + Util.toHex('~'.code));
	}

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
					instance_.cfg_.init_View();
					//trace("*******");
					view_ = new KonsoleView(instance_, false);
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


	function update(): Void
	{

	}

	function render(framebuffer: Framebuffer): Void
	{
		var gr = framebuffer.g2;
		gr.begin(true, color_bg_);

		/**
		gr.color = Color.Magenta;
		gr.fillRect(300, 200, 128, 64);
		/**/

		Root.instance.render_To(gr);


		gr.end();
	}
}
