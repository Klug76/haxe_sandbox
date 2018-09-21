package gs.femto_ui;
import haxe.Timer;

using gs.femto_ui.RootBase.NativeUIContainer;
//:________________________________________________________________________________________________
@:allow(gs.femto_ui.ButtonBase)
class Button extends ButtonBase
{
	public var label(get, never) : Label;
	public var auto_repeat(get, set) : Bool;

	private var label_ : Label = null;
	private var on_click_ : InfoClick->Void = null;
	private var auto_repeat_ : Bool = false;
	private var repeat_time_ : Float = 0;
	private var repeat_event_ : InfoClick = null;
	private var click_event_ : InfoClick = null;
	private var repeat_count_ : Int = 0;
	private var hover_inflation_: Float = 0;

	private static var repeat_button_ : Button = null;

	public var repeat_delay_ : Float = 400 / 1000;//:s

	public function new(owner : NativeUIContainer, txt : String, on_Click : InfoClick->Void)
	{
		super(owner);
		init_Ex(txt, on_Click);
	}
//.............................................................................
	private function init_Ex(txt : String, on_Click : InfoClick->Void) : Void
	{
		init_Base();

		hover_inflation_ = Root.instance.hover_inflation_;

		label_ = new Label(this, txt);
		label_.h_align =
		label_.v_align = Align.CENTER;
		//label_.dummy_color = 0xff00ff;
		add_Child(label_);

		on_click_ = on_Click;

		add_Mouse_Listeners();
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
	}
//.............................................................................
//.............................................................................
//.............................................................................
	private inline function get_label() : Label
	{
		return label_;
	}
//.............................................................................
//.............................................................................
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
	private function handle_Tap(mx: Float, my: Float): Void
	{
		invalidate_Visel(Visel.INVALIDATION_FLAG_STATE);
		if (auto_repeat_)
		{
			if (repeat_button_ != this)
			{
				repeat_count_ = 0;
				repeat_time_ = Timer.stamp() + repeat_delay_;
				if (null == repeat_event_)
					repeat_event_ = new InfoClick();
				repeat_event_.mx_ = mx;
				repeat_event_.my_ = my;
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
	private function handle_Click(mx: Float, my: Float): Void
	{
		if (null == click_event_)
			click_event_ = new InfoClick();
		click_event_.mx_ = mx;
		click_event_.my_ = my;
		if (on_click_ != null)
			on_click_(click_event_);
	}
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
				if (delay < 50 / 1000)
				{
					delay = 50 / 1000;//:s
				}
				repeat_time_ = time + delay;
				if (on_click_ != null)
					on_click_(repeat_event_);
			}
			return;
		}
		if (this == repeat_button_)
			repeat_button_ = null;//:clear static var
		Root.instance.frame_signal_.remove(on_Enter_Frame);
	}
}

