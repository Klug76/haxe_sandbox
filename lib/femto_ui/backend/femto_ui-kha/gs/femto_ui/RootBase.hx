package gs.femto_ui;

import gs.femto_ui.kha.Stage;
import gs.femto_ui.util.Signal;
import kha.Font;

import kha.graphics2.Graphics;
import kha.System;

typedef NativeUIContainer = Visel;//:nope

class RootBase
{
	public var frame_signal_ : Signal = new Signal();

	//:public var owner_: NativeUIContainer;
	public var stage_: Stage = null;

	public var font_: Font = null;//TODO fix me: need 4 font mapper

	public function new(owner: NativeUIContainer)
	{
		init();
	}
//.............................................................................
	private function init() : Void
	{
		var r: Root = cast this;
		stage_ = new Stage();
		//is_touch_supported_ = ?;//TODO fix me
		r.init_Ex();
	}
//.............................................................................
	public var stage_x(get, never): Float;
	inline private function get_stage_x(): Float
	{
		return stage_.x;
	}
//.............................................................................
	public var stage_y(get, never): Float;
	inline private function get_stage_y(): Float
	{
		return stage_.y;
	}
//.............................................................................
	public var stage_width(get, never): Float;
	inline private function get_stage_width(): Float
	{
		return stage_.width;
	}
//.............................................................................
	public var stage_height(get, never): Float;
	inline private function get_stage_height(): Float
	{
		return stage_.height;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public function render_To(gr: Graphics) : Void
	{
		frame_signal_.fire();
		if (stage_ != null)
		{
			gr.opacity = 1;
			stage_.render_To(gr, 0, 0);
		}
	}

}