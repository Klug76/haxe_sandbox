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
import gs.femto_ui.Toolbar;
import gs.femto_ui.Viewport;
import gs.femto_ui.Visel;
import gs.femto_ui.kha.Event;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.input.Keyboard;
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
		Root.instance.def_text_size_ *= 1.5;

		//test_Visel();

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

		var sc: Scrollbar = new Scrollbar(panel, function(v: Int): Void
		{
			trace("Scrollbar::scroll " + v);
		});
		sc.movesize(panel.width - r.small_tool_width_, 10, r.small_tool_width_, panel.height - 100);
		sc.reset(1, 15, 1);

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
			on_Key_Down(ev);
		case Event.KEY_UP:
			on_Key_Up(ev);
		}
	}

    private function on_Key_Down(ev: Event) : Void
	{
		trace("stage::on_Key_Down " + ev.code);
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
	}

    private function on_Key_Up(ev: Event) : Void
	{}

	function test_Visel()
	{
		Test1.run_All();
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
