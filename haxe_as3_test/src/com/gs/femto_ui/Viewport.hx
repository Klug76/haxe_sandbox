package com.gs.femto_ui;

import flash.Lib;
import flash.display.DisplayObjectContainer;
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

	public function new(st : Stage)
	{
		if (null == layer_)
		{
			layer_ = new Sprite();
			st.addChild(layer_);
		}
		super(layer_);
		create_Children();
	}
//.............................................................................
	private function create_Children() : Void
	{
		var r : Root = Root.instance;

		mover_ = new Mover(this);

		mover_.resize(r.tool_width_, r.tool_height_);
		mover_.dummy_color = r.color_movesize_;

		resizer_ = new Resizer(this);
		resizer_.dummy_color = r.color_movesize_;
		resizer_.resize(r.small_tool_width_, r.small_tool_height_);

		min_content_width_ = r.small_tool_width_;
		min_content_height_ = r.small_tool_height_;

		button_close_ = new Button(this, "x", on_Close_Click);
		button_close_.dummy_color = r.color_close_;
		button_close_.resize(r.small_tool_width_, r.small_tool_height_);

		if (visible)
			add_Listeners();
	}
//.............................................................................
	override public function destroy() : Void
	{
		if (stage != null)
			remove_Listeners();
		super.destroy();
	}
//.............................................................................
	private function on_Close_Click(e : Event) : Void
	{
		visible = false;
	}
//.............................................................................
//.............................................................................
	private function add_Listeners() : Void
	{
		stage.addEventListener(Event.RESIZE, on_Stage_Resize);
		addEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down, true, 100);
	}
//.............................................................................
	private function remove_Listeners() : Void
	{
		stage.removeEventListener(Event.RESIZE, on_Stage_Resize);
		removeEventListener(MouseEvent.MOUSE_DOWN, on_Mouse_Down, true);
	}
//.............................................................................
	private function on_Mouse_Down(e: Event): Void
	{
		activate();
	}
//.............................................................................
	private function on_Stage_Resize(e: Event): Void
	{
		safe_Position();
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
		if (x < stage_x)
			x = stage_x;
		else if (x + min_w > stage_x + stage_w)
			x = stage_x + stage_w - min_w;
		if (y < stage_y)
			y = stage_y;
		else if (y + min_h > stage_y + stage_h)
			y = stage_y + stage_h - min_h;
		if (width_ > stage_w)
			width = stage_w;
		if (height_ > stage_h)
			height = stage_h;
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
	override public function draw() : Void
	{
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
				content_.resize(nw, nh);
				mover_.resize(nw, nh);
			}
		}
		super.draw();
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
