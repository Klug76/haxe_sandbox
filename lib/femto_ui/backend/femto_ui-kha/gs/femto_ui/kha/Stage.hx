package gs.femto_ui.kha;

import gs.femto_ui.Visel;
import kha.System;
//import kha.Window;
import kha.input.Mouse;
import kha.input.Keyboard;
import kha.input.KeyCode;

class Stage extends Visel
{
	private var current_hover_: Visel = null;
	private var current_focus_: Visel = null;

	public function new()
	{
		super(null);
		hit_test_bits = ViselBase.HIT_TEST_CHILDREN;
#if debug
		name = "stage";
#end
	}
//.............................................................................
	override private function init_Base(): Void
	{
		super.init_Base();
		Mouse.get().notify(on_Mouse_Down, on_Mouse_Up, on_Mouse_Move, on_Mouse_Wheel);
		Keyboard.get().notify(on_Key_Down, on_Key_Up, on_Key_Press);
		resize_(System.windowWidth(), System.windowHeight());
		//Window.get(0).notifyOnResize(on_Window_Resize);
		//TODO fix me: how to handle resize event?
	}
//.............................................................................
	//function on_Window_Resize(w: Int, h: Int): Void
	//{
		//trace("********** on_Window_Resize: " + w + "x" + h);
	//}
//.............................................................................
	override private function destroy_Base(): Void
	{
		Mouse.get().remove(on_Mouse_Down, on_Mouse_Up, on_Mouse_Move, on_Mouse_Wheel);
		Keyboard.get().remove(on_Key_Down, on_Key_Up, on_Key_Press);
		super.destroy_Base();
	}
//.............................................................................
	private function on_Mouse_Down(buttonId: Int, mouseX: Int, mouseY: Int): Void
	{
		bubble_Event_By_XY(Event.MOUSE_DOWN + buttonId, buttonId, mouseX, mouseY);
	}
//.............................................................................
	private function on_Mouse_Up(buttonId: Int, mouseX: Int, mouseY: Int): Void
	{
		bubble_Event_By_XY(Event.MOUSE_UP + buttonId, buttonId, mouseX, mouseY);
	}
//.............................................................................
	private function on_Mouse_Move(mouseX: Int, mouseY: Int, mx: Int, my: Int): Void
	{
		bubble_Event_By_XY(Event.MOUSE_MOVE, 0,//TODO fix me: refactor kha.Mouse to get buttonId
			mouseX, mouseY);
	}
//.............................................................................
	private function on_Mouse_Wheel(delta: Int): Void
	{
		var ev: Event = Event.alloc();
		ev.code = delta;
		bubble_Event_To(current_hover_, Event.MOUSE_WHEEL, ev);
		Event.dispose(ev);//:wanted: RAII :(
	}
//.............................................................................
//.............................................................................
	inline private function bubble_Event_By_XY(ev_type: Int, inputId: Int, mX: Int, mY: Int): Void
	{
		var ev: Event = Event.alloc();
		ev.input_id = inputId;
		ev.targetX =
		ev.globalX = mX;
		ev.targetY =
		ev.globalY = mY;
		var t: Visel = find_Event_Target(ev, 0, 0);
		switch(ev_type)
		{
		case Event.MOUSE_DOWN, Event.RIGHT_MOUSE_DOWN:
			if (t != current_focus_)
				update_Focus(null, ev);
		case Event.MOUSE_MOVE:
			if (t != current_hover_)
				update_Hover(t, ev);
		}
		bubble_Event_To(t, ev_type, ev);
		Event.dispose(ev);
	}
//.............................................................................
	private function bubble_Event_To(t: Visel, ev_type: Int, ev: Event): Void
	{
		ev.reset(ev_type | Event.FLAG_CAPTURING);
		if (null == t)
			t = this;
		ev.target = t;
		var bc: BubbleChain = BubbleChain.alloc();
		bc.build(t);//:[t, t.parent, ..., root]
		ev.phase = Event.PHASE_CAPTURING;
		for (j in 0...bc.count_ - 1)
		{
			var i: Int = bc.count_ - j - 1;
			if (ev.stop_propagation)
				break;
			var v: Visel = bc.chain_[i];//:from root to t.parent - capturing
			if (v.disposed)
				continue;
			v.dispatch_Event(ev);
		}
		ev.type &= ~Event.FLAG_CAPTURING;
		for (i in 0...bc.count_)
		{
			if (ev.stop_propagation)
				break;
			var v: Visel = bc.chain_[i];//:t && from t.parent to root - bubbling
			if (v.disposed)
				continue;
			ev.phase = if (0 == i) Event.PHASE_AT_TARGET else Event.PHASE_BUBBLING;
			v.dispatch_Event(ev);
		}
		BubbleChain.dispose(bc);
	}
//.............................................................................
	private function update_Hover(t: Visel, ev: Event): Void
	{
		var old: Visel = current_hover_;
		current_hover_ = t;
		ev.target = t;
		if (old != null)
		{
			ev.reset(Event.MOUSE_OUT);
			old.dispatch_Event(ev);
		}
		if (t != null)
		{
			ev.reset(Event.MOUSE_IN);
			t.dispatch_Event(ev);
		}
	}
//.............................................................................
//.............................................................................
	private function update_Focus(t: Visel, ev: Event): Void
	{
		if (current_focus_ == t)
			return;
		var old: Visel = current_focus_;
		current_focus_ = t;
		ev.target = t;
		if (old != null)
		{
			ev.reset(Event.FOCUS_OUT);
			old.dispatch_Event(ev);
		}
		if (t != null)
		{
			ev.reset(Event.FOCUS_IN);
			t.dispatch_Event(ev);
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
	private function on_Key_Down(code: KeyCode): Void
	{
		on_Key(Event.KEY_DOWN, code, 0);//TODO need charCode, too
	}
//.............................................................................
	private function on_Key_Up(code: KeyCode): Void
	{
		on_Key(Event.KEY_UP, code, 0);//TODO need charCode, too
	}
//.............................................................................
	private function on_Key_Press(chr: String): Void
	{
		on_Key(Event.KEY_PRESS, 0, chr.charCodeAt(0));//TODO refactor arg to Int
	}
//.............................................................................
	private function on_Key(ev_type: Int, code: Int, charCode: Int): Void
	{
		var ev: Event = Event.alloc();
		validate_Focus(ev);
		ev.code = code;
		ev.char_code = charCode;
		bubble_Event_To(current_focus_, ev_type, ev);
		Event.dispose(ev);//:wanted: RAII :(
		//TODO how to call preventDefault e.g. for "back" key in Android?
	}
//.............................................................................
	private function validate_Focus(ev: Event): Void
	{
		if (null == current_focus_)
			return;
		if (!is_Valid_Focus(current_focus_))
			update_Focus(null, ev);
	}
//.............................................................................
	private function is_Valid_Focus(t: Visel): Bool
	{
		while (true)
		{
			if (null == t)
				return false;
			if (!t.visible || !t.enabled)
				return false;
			if (t == this)
				return true;
			t = t.parent;
		}
	}
//.............................................................................
	public function set_Focus_To(v: Visel)
	{
		if (current_focus_ == v)
			return;
		var ev: Event = Event.alloc();
		update_Focus(v, ev);
		Event.dispose(ev);//:wanted: RAII :(
	}
//.............................................................................
//.............................................................................
}