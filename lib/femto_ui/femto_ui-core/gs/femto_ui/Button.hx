package gs.femto_ui;

import haxe.Timer;

using gs.femto_ui.RootBase.NativeUIContainer;

@:allow(gs.femto_ui.ButtonBase)
class Button extends ButtonBase
{
	public var label(get, never) : Label;
	public var auto_repeat(get, set) : Bool;
	public var text(default, set) : String = null;

	private var label_ : Label = null;
	private var auto_repeat_ : Bool = false;
	private var repeat_time_ : Float = 0;
	private var repeat_event_ : InfoClick = null;
	private var click_event_ : InfoClick = null;
	private var repeat_count_ : Int = 0;
	private var hover_inflation_: Float = 0;

	private static var repeat_button_ : Button = null;

	public var repeat_delay_ : Float = 400 / 1000;//:s
	public var min_repeat_delay_ : Float = 50 / 1000;//:s

	public function new(owner : NativeUIContainer, txt : String, handler_click : InfoClick->Void)
	{
		super(owner);
#if debug
		name = "button";
#end
		init_Ex(txt, handler_click);
	}
//.............................................................................
	private function init_Ex(txt : String, handler_click : InfoClick->Void) : Void
	{
		hover_inflation_ = Root.instance.hover_inflation_;

		text = txt;
		if (txt != null)
			alloc_Label();

		if (handler_click != null)
			on_Click = handler_click;

		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
	}
//.............................................................................
//.............................................................................
	private function alloc_Label() : Label
	{
		if (label_ != null)
			return label_;
		label_ = new Label(this, text);
		label_.h_align =
		label_.v_align = Align.CENTER;
		//label_.dummy_color = 0xff00ff;
		add_Child(label_);
		return label_;
	}
//.............................................................................
//.............................................................................
	private inline function set_text(value: String): String
	{
		if (text != value)
		{
			text = value;
			if (value != null)
				alloc_Label();
			invalidate_Visel(Visel.INVALIDATION_FLAG_TEXT);
		}
		return value;
	}
//.............................................................................
//.............................................................................
	private inline function get_label() : Label
	{
		return label_;
	}
//.............................................................................
//.............................................................................
	override public function draw_Visel() : Void
	{
		super.draw_Visel();
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_STATE)) != 0)
		{
			var al: Label = label;
			if (al != null)
			{
				var r: Root = Root.instance;
				if ((state_ & Visel.STATE_DOWN) != 0)
				{
					al.movesize_(r.content_down_offset_x_, r.content_down_offset_y_,
							width_ + r.content_down_offset_x_, height_ + r.content_down_offset_y_);
				}
				else
				{
					al.movesize_(0, 0, width_, height_);
				}
				al.draw_Visel();
				al.validate_Visel();
			}
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	private function get_auto_repeat() : Bool
	{
		return auto_repeat_;
	}
//.............................................................................
	private function set_auto_repeat(value : Bool) : Bool
	{
		auto_repeat_ = value;
		return value;
	}
//.............................................................................
//.............................................................................
	private var tap_id(default, null): Int = 0;
	private function handle_Tap(tapId: Int, globalX: Float, globalY: Float, localX: Float, localY: Float): Void
	{
		//trace("button::tap " + tapId + ":" + mx + ":" + my);
		tap_id = tapId;
		if (auto_repeat_)
		{
			if (repeat_button_ != this)
			{
				repeat_count_ = 0;
				repeat_time_ = Timer.stamp() + repeat_delay_;
				if (null == repeat_event_)
					repeat_event_ = new InfoClick();
				repeat_event_.global_x_ = globalX;
				repeat_event_.global_y_ = globalY;
				repeat_event_.local_x_ = localX;
				repeat_event_.local_y_ = localY;
				repeat_button_ = this;
				Root.instance.frame_signal_.add(on_Enter_Frame);
			}
		}
		else
		{//:replace anyway
			repeat_button_ = null;
		}
	}
//.............................................................................
	private function handle_Click(globalX: Float, globalY: Float, localX: Float, localY: Float): Void
	{
		if (null == click_event_)
			click_event_ = new InfoClick();
		click_event_.global_x_ = globalX;
		click_event_.global_y_ = globalY;
		click_event_.local_x_ = localX;
		click_event_.local_y_ = localY;
		on_Click(click_event_);
	}
//.............................................................................
	public dynamic function on_Click(click_event: InfoClick)
	{}
//.............................................................................
	private function on_Enter_Frame() : Void
	{
		if (auto_repeat_ && ((state_ & (Visel.STATE_DOWN | Visel.STATE_HOVER | Visel.STATE_DISPOSED | Visel.STATE_DISABLED)) ==
			(Visel.STATE_DOWN | Visel.STATE_HOVER)) &&
			(this == repeat_button_))
		{
			var time : Float = Timer.stamp();
			if (time - repeat_time_ >= 0)
			{
				++repeat_count_;
				var delay : Float = repeat_delay_;
				delay = delay / repeat_count_;
				if (delay < min_repeat_delay_)
					delay = min_repeat_delay_;
				repeat_time_ = time + delay;
				on_Click(repeat_event_);
			}
			return;
		}
		if (this == repeat_button_)
			repeat_button_ = null;//:clear static var
		Root.instance.frame_signal_.remove(on_Enter_Frame);
	}
}

