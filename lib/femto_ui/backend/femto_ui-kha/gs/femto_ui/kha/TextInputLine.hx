package gs.femto_ui.kha;

import gs.femto_ui.Visel;
import gs.femto_ui.Root;
import kha.graphics2.Graphics;
import kha.Scheduler;
import kha.Font;
import kha.input.KeyCode;

using gs.femto_ui.RootBase.NativeUIContainer;

/*
quick & dirty:
- single line only
- no selection
- no scroll
- no disabled state
- no key repeat (kha problem?)
- bad key_down/up handler
- no undo/redo
- hard-coded text/bg/caret colors
*/

class TextInputLine extends Visel
{
	public var text(get, set): String;
	public var restrict(default, default): String = null;//:simple, '-' not supported
	public var filter_key_: Array<Int> = [KeyCode.Escape, KeyCode.Tab, KeyCode.Return, KeyCode.Up, KeyCode.Down,
		KeyCode.Alt, KeyCode.AltGr, KeyCode.Control, KeyCode.Shift, KeyCode.Win];

	private var text_: String = "";
	private var tap_id_: Int;

	private var caret_task_id_: Int = -1;
	private var caret_visible_: Bool = false;
	private var caret_index_: Int = 0;
	private var caret_x_: Float = 0;

	public function new(owner: NativeUIContainer)
	{
		super(owner);
	}
//.............................................................................
	inline private function get_text(): String
	{
		return text_;
	}
//.............................................................................
	private function set_text(value: String): String
	{
		if (null == value)
			value = "";
		if (text_ != value)
		{
			text_ = value;
			caret_index_ = value.length;
			invalidate_Visel(Visel.INVALIDATION_FLAG_TEXT | Visel.INVALIDATION_FLAG_DATA);
		}
		return value;
	}
//.............................................................................
	public dynamic function on_Changed()
	{}
//.............................................................................
//.............................................................................
	override private function init_Base(): Void
	{
		super.init_Base();
		hit_test_bits = ViselBase.HIT_TEST_FUNC;//?
		add_Listener(on_Event);
	}
//.............................................................................
	override private function destroy_Base(): Void
	{
		super.destroy_Base();
		remove_Listener(on_Event);
		clear_Blink_Task();
	}
//.............................................................................
	private function on_Event(ev: Event): Void
	{
		switch(ev.type)
		{
		case Event.MOUSE_DOWN:
			on_Mouse_Down(ev);
		case Event.MOUSE_UP:
			on_Mouse_Up(ev);
		case Event.FOCUS_IN:
			on_Focus_In();
		case Event.FOCUS_OUT:
			on_Focus_Out();
		case Event.KEY_DOWN:
			on_Key_Down(ev);
		case Event.KEY_UP:
			on_Key_Up(ev);
		case Event.KEY_PRESS:
			on_Key_Press(ev);
		}
	}
//.............................................................................
	private function on_Mouse_Down(ev: Event): Void
	{
		ev.stop_propagation = true;
		if ((state_ & Visel.STATE_DOWN) != 0)
			return;
		state_ |= Visel.STATE_DOWN;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		tap_id_ = ev.input_id;
	}
//.............................................................................
	private function on_Mouse_Up(ev: Event): Void
	{
		if ((state_ & Visel.STATE_DOWN) == 0)
			return;
		if (tap_id_ != ev.input_id)
			return;
		state_ &= ~Visel.STATE_DOWN;
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);

		ev.stop_propagation = true;
		set_Cur_Focus();
	}
//.............................................................................
	private function set_Cur_Focus(): Void
	{
		var r: Root = Root.instance;
		r.stage_.set_Focus_To(this);
	}
//.............................................................................
//.............................................................................
	private function on_Focus_In(): Void
	{
		//flash.Lib.trace("textfield::set focus");
		caret_visible_ = true;
		caret_task_id_ = Scheduler.addTimeTask(blink_Caret, 0, .4);
	}
//.............................................................................
	private function on_Focus_Out(): Void
	{
		//flash.Lib.trace("textfield::kill focus");
		clear_Blink_Task();
		caret_visible_ = false;
	}
//.............................................................................
	private function clear_Blink_Task(): Void
	{
		if (caret_task_id_ != -1)
		{
			Scheduler.removeTimeTask(caret_task_id_);
			caret_task_id_ = -1;
		}
	}
//.............................................................................
	private function blink_Caret(): Void
	{
		caret_visible_ = !caret_visible_;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	private function on_Key_Down(ev : Event) : Void
	{
		if (!is_Allowed_Key(ev.code))
			return;
		//trace("edit::on_Key_Down " + ev.code);
		ev.stop_propagation = true;
		switch(ev.code)
		{
		case KeyCode.Left:
			move_Caret( -1);
		case KeyCode.Right:
			move_Caret( 1);
		case KeyCode.Home:
			move_Caret_To(0);
		case KeyCode.End:
			move_Caret_To(text_.length);
		case KeyCode.Backspace:
			handle_Backspace();
		case KeyCode.Delete:
			handle_Delete();
		}
	}
//.............................................................................
	private function on_Key_Up(ev : Event) : Void
	{
		if (!is_Allowed_Key(ev.code))
			return;
		//trace("edit::on_Key_Up " + ev.code);
		ev.stop_propagation = true;
	}
//.............................................................................
	private function on_Key_Press(ev : Event) : Void
	{
		//trace("edit::on_Key_Press " + ev.char_code);
		if (ev.char_code < 32)
			return;
		switch(ev.char_code)
		{
		case 127://:del
			return;
		}
		if (is_Restricted_Char(ev.char_code))
			return;

		ev.stop_propagation = true;
		var s: String = String.fromCharCode(ev.char_code);
		if (caret_index_ < text_.length)
		{
			var left_text: String  = text.substr(0, caret_index_);
			var right_text: String = text.substr(caret_index_);
			text_ = left_text + s +  right_text;
		}
		else
		{
			text_ += s;
		}
		++caret_index_;
		invalidate_Visel(Visel.INVALIDATION_FLAG_TEXT | Visel.INVALIDATION_FLAG_DATA);
		on_Changed();
	}
//.............................................................................
//.............................................................................
	private function is_Allowed_Key(code: Int): Bool
	{
		//TODO fix me: need valid event.charCode to kill this shit.
		if ((code >= cast KeyCode.F1) && (code <= cast KeyCode.F24))
			return false;
		if (filter_key_.indexOf(code) >= 0)
			return false;
		return true;
	}
//.............................................................................
	private function is_Restricted_Char(char_code: Int): Bool
	{
		if (null == restrict)
			return false;
		if ((restrict.length > 0) && (restrict.charCodeAt(0) == '^'.code))
		{//:invert logic
			for (i in 1...restrict.length)
			{
				var ch: Int = restrict.charCodeAt(i);
				if (ch == char_code)
					return true;
			}
			return false;
		}
		for (i in 0...restrict.length)
		{
			var ch: Int = restrict.charCodeAt(i);
			if (ch == char_code)
				return false;
		}
		return true;
	}
//.............................................................................
//.............................................................................
	inline private function move_Caret(dx: Int/*, dy: Int*/): Void
	{
		move_Caret_To(caret_index_ + dx);
	}
//.............................................................................
	public function move_Caret_To(nx: Int): Void
	{
		if (nx < 0)
			nx = 0;
		if (nx > text_.length)
			nx = text_.length;
		if (caret_index_ != nx)
		{
			caret_index_ = nx;
			invalidate_Visel(Visel.INVALIDATION_FLAG_DATA);
		}
	}
//.............................................................................
//.............................................................................
	private function handle_Backspace(): Void
	{
		if (caret_index_ > 0)
		{
			var left_text: String  = text.substr(0, caret_index_ - 1);
			var right_text: String = text.substr(caret_index_);
			text_ = left_text + right_text;
			--caret_index_;
			invalidate_Visel(Visel.INVALIDATION_FLAG_TEXT | Visel.INVALIDATION_FLAG_DATA);
			on_Changed();
		}
	}
//.............................................................................
	private function handle_Delete(): Void
	{
		if (caret_index_ < text_.length)
		{
			var left_text: String  = text.substr(0, caret_index_);
			var right_text: String = text.substr(caret_index_ + 1);
			text_ = left_text + right_text;
			invalidate_Visel(Visel.INVALIDATION_FLAG_TEXT);
			on_Changed();
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	override public function draw_Visel() : Void
	{
		super.draw_Visel();
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_TEXT | Visel.INVALIDATION_FLAG_DATA)) != 0)
		{
			caret_x_ = 0;
			if (caret_index_ > 0)
			{
				var r: Root = Root.instance;
				var font: Font = r.font_;
				var font_size: Int = Std.int(r.input_font_size_);

				var left_text: String = text_;
				if (caret_index_ < text_.length)
					left_text = text_.substr(0, caret_index_);
				var dx: Float = font.width(font_size, left_text);
				caret_x_ += dx;
			}
		}
	}
//.............................................................................
//.............................................................................
	override function render_Base(gr: Graphics, nx: Float, ny: Float): Void
	{
		render_Base_Background(gr, nx, ny);
		render_Text(gr, nx, ny);
		render_Children(gr, nx, ny);
	}
//.............................................................................
//.............................................................................
	private function render_Text(gr: Graphics, nx: Float, ny: Float): Void
	{
		var r: Root = Root.instance;
		var font: Font = r.font_;
		var font_size: Int = Std.int(r.input_font_size_);//TODO fix me
		var text_x: Float = r.spacing_;
		var text_y: Float = r.spacing_;
		text_x += nx;
		text_y += ny;
		if (text_.length > 0)
		{
			gr.font = font;
			gr.fontSize = font_size;
			gr.color = r.color_ui_text_ | 0xFF000000;
			gr.drawString(text_, Math.round(text_x), Math.round(text_y));
		}

		if (!caret_visible_)
			return;
		var caret_x: Float = text_x;
		var caret_y: Float = text_y;
		caret_x += caret_x_;
		gr.color = 0xFFff00ff;//TODO fix me
		gr.drawLine(caret_x, caret_y, caret_x, caret_y + font.height(font_size));
		//gr.fillRect(caret_x, caret_y, 1, font.height(font_size));
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
}