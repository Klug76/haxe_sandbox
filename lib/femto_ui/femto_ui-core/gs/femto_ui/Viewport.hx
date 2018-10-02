package gs.femto_ui;


class Viewport extends ViewportBase
{
	public var content(get, set) : Visel;

	private var button_close_ : Button;
	private var mover_ : Mover;
	private var resizer_ : Resizer;
	private var content_ : Visel = null;
	private var min_content_width_ : Float = 0;
	private var min_content_height_ : Float = 0;

	public function new()
	{
		super();
#if debug
		name = "viewport";
#end
		create_Children();
	}
//.............................................................................
	private function create_Children() : Void
	{
		var r : Root = Root.instance;

		min_content_width_ = r.tool_width_ + r.small_tool_width_;//:mover + close
		min_content_height_ = r.small_tool_height_ * 2;//:close + resizer

		mover_ = new Mover(this);

		mover_.resize_Visel(r.tool_width_, r.tool_height_);
		mover_.dummy_color = r.color_movesize_;

		resizer_ = new Resizer(this);
		resizer_.dummy_color = r.color_movesize_;
		resizer_.min_width_ = min_content_width_;
		resizer_.min_height_ = min_content_height_;
		resizer_.resize_Visel(r.small_tool_width_, r.small_tool_height_);

		button_close_ = new Button(this, "x", on_Close_Click);
		button_close_.dummy_color = r.color_close_;
		button_close_.resize_Visel(r.small_tool_width_, r.small_tool_height_);

		on_Show = resume;
		on_Hide = suspend;
		if (visible)
		{
			add_Listeners();
			validate_Position();
		}
	}
//.............................................................................
//.............................................................................
	private function on_Close_Click(_) : Void
	{
		visible = false;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	private function validate_Position() : Void
	{
		var nw: Float = explicit_width_;
		var nh: Float = explicit_height_;
		if ((nw <= 0) || (nh <= 0))
			return;
		var r: Root = Root.instance;
		var nx: Float = explicit_x_;
		var ny: Float = explicit_y_;
		var min_w: Float = min_content_width_;
		var min_h: Float = min_content_height_;
		var stage_x: Float = r.stage_x;
		var stage_y: Float = r.stage_y;
		var stage_w: Float = r.stage_width;
		var stage_h: Float = r.stage_height;

		if (nw > stage_w)
			nw = stage_w;
		if (nh > stage_h)
			nh = stage_h;
		if (nx < stage_x)
			nx = stage_x;
		else if (nx + min_w > stage_x + stage_w)
			nx = stage_x + stage_w - min_w;
		if (ny < stage_y)
			ny = stage_y;
		else if (ny + min_h > stage_y + stage_h)
			ny = stage_y + stage_h - min_h;
		movesize_Base(nx, ny, nw, nh);
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	private function resume() : Void
	{
		add_Listeners();
		validate_Position();
		activate();
		if (content_ != null)
			content_.visible = true;
	}
//.............................................................................
	private function suspend() : Void
	{
		remove_Listeners();
		if (content_ != null)
			content_.visible = false;
	}
//.............................................................................
	override public function draw_Visel() : Void
	{
		if ((invalid_flags_ & Visel.INVALIDATION_FLAG_STAGE_SIZE) != 0)
		{
			validate_Position();
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_DATA)) != 0)
		{
			resizer_.x = width_ - resizer_.width;
			resizer_.y = height_ - resizer_.height;
			//trace("vp::resizer::pos=" + resizer_.x + ":" + resizer_.y + ";size=" + resizer_.width + "x" + resizer_.height);

			button_close_.x = width_ - button_close_.width;
			if (content_ != null)
			{
				var nw : Float = width_;
				if (nw < min_content_width_)
					nw = min_content_width_;
				var nh : Float = height_;
				if (nh < min_content_height_)
					nh = min_content_height_;
				nw -= button_close_.width;
				content_.resize_Visel(nw, nh);
				mover_.resize_Visel(nw, nh);
			}
		}
		super.draw_Visel();
	}
//.............................................................................
	inline private function get_content() : Visel
	{
		return content_;
	}
//.............................................................................
	private function set_content(value : Visel) : Visel
	{
		if (content_ != null)
		{//:one-shoot
			#if debug
				throw "Viewport::content is already set";
			#end
			return value;
		}
		var r: Root = Root.instance;
		content_ = value;
		content_.visible = visible;
		min_content_width_ = value.width;
		min_content_height_ = value.height;
		mover_.dummy_alpha = 0;
		resizer_.min_width_ = min_content_width_ + r.small_tool_width_;
		resizer_.min_height_ = min_content_height_;
		invalidate_Visel(Visel.INVALIDATION_FLAG_DATA);
		return value;
	}
}
