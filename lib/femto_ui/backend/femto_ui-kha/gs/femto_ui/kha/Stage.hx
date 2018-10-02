package gs.femto_ui.kha;

import gs.femto_ui.Visel;
import kha.System;
//import kha.Window;
import kha.input.Mouse;

class Stage extends Visel
{
	private var mouse_target_: Visel = null;

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
		Mouse.get().notify(on_Mouse_Down, on_Mouse_Up, on_Mouse_Move, null);
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
		Mouse.get().remove(on_Mouse_Down, on_Mouse_Up, on_Mouse_Move, null);
		super.destroy_Base();
	}
//.............................................................................
	private function on_Mouse_Down(buttonId: Int, mouseX: Int, mouseY: Int): Void
	{
		bubble_Event_By_XY(Event.MOUSE_DOWN, buttonId, mouseX, mouseY);
	}
//.............................................................................
	private function on_Mouse_Up(buttonId: Int, mouseX: Int, mouseY: Int): Void
	{
		bubble_Event_By_XY(Event.MOUSE_UP, buttonId, mouseX, mouseY);
	}
//.............................................................................
	private function on_Mouse_Move(mouseX: Int, mouseY: Int, mx: Int, my: Int): Void
	{
		dispatch_Mouse_Move_By_XY(Event.MOUSE_MOVE, 0, mouseX, mouseY);
	}
//.............................................................................
	inline private function dispatch_Mouse_Move_By_XY(ev_type: Int, inputId: Int, mX: Int, mY: Int): Void
	{
		var t: Visel = find_Event_Target(mX, mY, 0, 0);
		handle_Mouse_In_Out(t, mX, mY);
		bubble_Event_To(t, ev_type, inputId, mX, mY);
	}
//.............................................................................
	inline private function bubble_Event_By_XY(ev_type: Int, inputId: Int, mX: Int, mY: Int): Void
	{
		var t: Visel = find_Event_Target(mX, mY, 0, 0);
		bubble_Event_To(t, ev_type, inputId, mX, mY);
	}
//.............................................................................
	private function bubble_Event_To(t: Visel, ev_type: Int, inputId: Int, mX: Int, mY: Int): Void
	{
		if (null == t)
			t = this;
		var bc: BubbleChain = BubbleChain.alloc();
		bc.build(t);//:[t, t.parent, ..., root]
		var ev: Event = Event.alloc(ev_type | Event.FLAG_CAPTURING);
		ev.inputId = inputId;
		ev.globalX = mX;
		ev.globalY = mY;
		ev.target = t;
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
		Event.dispose(ev);
		BubbleChain.dispose(bc);
	}
//.............................................................................
	private function handle_Mouse_In_Out(value: Visel, mX: Int, mY: Int): Void
	{
		if (value == this)
			value = null;
		if (mouse_target_ == value)
			return;
		if ((mouse_target_ != null) && !mouse_target_.disposed)
		{
			var ev: Event = Event.alloc(Event.MOUSE_OUT);
			ev.globalX = mX;
			ev.globalY = mY;
			ev.target = mouse_target_;
			mouse_target_.dispatch_Event(ev);
			Event.dispose(ev);
		}
		mouse_target_ = value;
		if (mouse_target_ != null)
		{
			var ev: Event = Event.alloc(Event.MOUSE_IN);
			ev.globalX = mX;
			ev.globalY = mY;
			ev.target = mouse_target_;
			mouse_target_.dispatch_Event(ev);
			Event.dispose(ev);
		}
	}
}