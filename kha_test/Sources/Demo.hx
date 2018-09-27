package;

import gs.femto_ui.Align;
import gs.femto_ui.Button;
import gs.femto_ui.InfoClick;
import gs.femto_ui.Label;
import gs.femto_ui.Mover;
import gs.femto_ui.Resizer;
import gs.femto_ui.Root;
import gs.femto_ui.Toolbar;
import gs.femto_ui.Visel;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Color;
import kha.input.Keyboard;
import kha.input.KeyCode;
import kha.Assets;

class Demo
{
	var color_bg_: Int = 0x223344;
	var root_: Visel;
	var v_: Visel;
	var al_: Label;
	var b_: Button;
	var tb_: Toolbar;
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

		Keyboard.get().notify(on_Key_Down, on_Key_Up);
	}

	function add_UI()
	{
		var r: Root = Root.instance;

		root_ = new Visel(null);
		root_.x = 0;
		root_.y = 0;
		root_.resize_Visel(System.windowWidth(), System.windowHeight());
		r.root_ = root_;//TODO how to avoid this?

		v_ = new Visel(root_);
		v_.dummy_color_ = 0xff0000;
		v_.dummy_alpha_ = 1;
		v_.x = 220;
		v_.y = 310;
		v_.resize_Visel(150, 100);

		var panel: Visel = new Visel(root_);
		panel.move_Visel(220, 40);
		panel.resize_Visel(root_.width - 230, root_.height - 60);
		panel.dummy_color_ = 0x443322;
		panel.dummy_alpha_ = 0.25;

		al_ = new Label(panel, "Foo");
		al_.dummy_color_ = 0x8f008f;
		al_.dummy_alpha_ = 0.5;
		al_.movesize(120, 20, 220, 60);

		b_ = new Button(panel, "Click me!", on_Click);
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

		var btn = new Button(tb_, "1", on_Click);
		btn.dummy_color = 0xc02040;
		btn.resize_Visel(120, 42);
		btn = new Button(tb_, "2", on_Click);
		btn.dummy_color = 0x202040;
		btn.resize_Visel(120, 42);

		var m: Mover = new Mover(panel);
		m.resize_Visel(64, 64);
		m.dummy_color = r.color_movesize_;

		var rz: Resizer = new Resizer(panel);
		rz.dummy_color = r.color_movesize_;

		panel.on_Resize = function()
		{
			rz.movesize(panel.width - 64, panel.height - 64, 64, 64);
		};
	}

	function on_Click(ev: InfoClick)
	{
		trace("click #" + debug_counter_++ + ", " + ev.mx_ + ": " + ev.my_);
	}

    private function on_Key_Down(code: KeyCode) : Void
	{
		switch(code)
		{
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

    private function on_Key_Up(code: KeyCode) : Void
	{

	}

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
