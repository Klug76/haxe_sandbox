package gs.femto_ui;

import gs.femto_ui.util.Signal;
import kha.Font;

import kha.graphics2.Graphics;
import kha.System;

typedef NativeUIContainer = Visel;//:nope

class RootBase
{
	public var frame_signal_ : Signal = new Signal();

	public var is_touch_supported_ : Bool = false;
	public var platform_: String = null;

	public var root_: Visel = null;
	public var font_: Font = null;

	public function new(owner: NativeUIContainer)
	{
		init();
	}
//.............................................................................
	private function init() : Void
	{
		//is_touch_supported_ = ?;//TODO fix me
		platform_ = "PC";//TODO fix me
		var r: Root = cast this;
		r.init_Ex(System.windowWidth(), System.windowHeight());
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public function render_To(gr: Graphics) : Void
	{
		frame_signal_.fire();
		if (root_ != null)
			root_.render_To(gr, 0, 0);
	}

}