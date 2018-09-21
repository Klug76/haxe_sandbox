package gs.femto_ui;

import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;

class Viewport extends Visel
{
	public var content(get, set) : Visel;

	private var button_close_ : Button;
	private var mover_ : Mover;
	private var resizer_ : Resizer;
	private var content_ : Visel;
	private var min_content_width_ : Float;
	private var min_content_height_ : Float;
	static private var layer_: Sprite = null;

	public function new(stg : Stage)
	{
		if (null == layer_)
		{
			layer_ = new Sprite();
			stg.addChild(layer_);
		}
		super(layer_);
		create_Children();
#if debug
		name = "view";
#end
	}
//.............................................................................
	private function create_Children() : Void
	{
		var r : Root = Root.instance;

		mover_ = new Mover(this);

		mover_.resize_Visel(r.tool_width_, r.tool_height_);
		mover_.dummy_color = r.color_movesize_;

		resizer_ = new Resizer(this);
		resizer_.dummy_color = r.color_movesize_;
		resizer_.resize_Visel(r.small_tool_width_, r.small_tool_height_);

		min_content_width_ = r.small_tool_width_;
		min_content_height_ = r.small_tool_height_;

		button_close_ = new Button(this, "x", on_Close_Click);
		button_close_.dummy_color = r.color_close_;
		button_close_.resize_Visel(r.small_tool_width_, r.small_tool_height_);

		if (visible)
			add_Listeners();
	}
//.............................................................................
	override public function destroy_Visel() : Void
	{
		if (stage != null)
			remove_Listeners();
		super.destroy_Visel();
	}
//.............................................................................
	private function on_Close_Click(_) : Void
	{
		visible = false;
	}
//.............................................................................
//.............................................................................
	private function add_Listeners() : Void
	{
		stage.addEventListener(Event.RESIZE, on_Stage_Resize);
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down_Phase0, true, 100);
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
	}
//.............................................................................
	private function remove_Listeners() : Void
	{
		stage.removeEventListener(Event.RESIZE, on_Stage_Resize);
		removeEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down_Phase0, true);
		removeEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down);
	}
//.............................................................................
	private function on_Mouse_Down_Phase0(ev: Event): Void
	{
		//trace("Viewport::on_Mouse_Down_Phase0, target=" + ev.target);
		activate();
	}
//.............................................................................
	private function on_Mouse_Down(ev: MouseEvent): Void
	{
		//trace("Viewport::on_Mouse_Down, target=" + ev.target);
		ev.stopPropagation();
	}
//.............................................................................
//.............................................................................
	private function on_Stage_Resize(ev: Event): Void
	{
		//?if (StageScaleMode.NO_SCALE == stage.scaleMode)
		invalidate_Visel(Visel.INVALIDATION_FLAG_STAGE_SIZE);
	}
//.............................................................................
	private function safe_Position() : Void
	{
		var min_w: Float = min_content_width_ + Root.instance.small_tool_width_;
		var min_h: Float = min_content_height_;
		var stage_x: Float = stage.x;
		var stage_y: Float = stage.y;
		var stage_w: Float = stage.stageWidth;
		var stage_h: Float = stage.stageHeight;
		var nx: Float = x;
		var ny: Float = y;
		var nw: Float = width_;
		var nh: Float = height_;
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
		movesize(nx, ny, nw, nh);
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	public function activate() : Void
	{
		//:some sort of bring_To_Top()
		if (stage != null)
		{
			stage.addChild(layer_);
		}
	}
//.............................................................................
//.............................................................................
//.............................................................................
	override public function on_Show() : Void
	{
		add_Listeners();
		safe_Position();
		activate();
		if (content_ != null)
			content_.visible = true;
	}
//.............................................................................
	override public function on_Hide() : Void
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
			safe_Position();
		}
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_SIZE | Visel.INVALIDATION_FLAG_DATA)) != 0)
		{
			resizer_.x = width_ - resizer_.width;
			resizer_.y = height_ - resizer_.height;
			//trace("vp::resizer::pos=" + resizer_.x + ":" + resizer_.y + ";size=" + resizer_.width + "x" + resizer_.height);

			button_close_.x = width_ - button_close_.width;
			if (content_ != null)
			{
				var nw : Float = width_ - button_close_.width;
				if (nw < min_content_width_)
				{
					nw = min_content_width_;
				}
				var nh : Float = height_;
				if (nh < min_content_height_)
				{
					nh = min_content_height_;
				}
				content_.resize_Visel(nw, nh);
				mover_.resize_Visel(nw, nh);
			}
		}
		super.draw_Visel();
	}
//.............................................................................
	private function get_content() : Visel
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
		content_ = value;
		content_.visible = true;
		min_content_width_ = value.width;
		min_content_height_ = value.height;
		mover_.dummy_alpha = 0;
		resizer_.min_width_ = min_content_width_ + Root.instance.small_tool_width_;
		resizer_.min_height_ = min_content_height_;
		invalidate_Visel(Visel.INVALIDATION_FLAG_DATA);
		return value;
	}
}
