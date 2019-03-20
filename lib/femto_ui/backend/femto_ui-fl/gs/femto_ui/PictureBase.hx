package gs.femto_ui;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;

using gs.femto_ui.RootBase.NativeUIContainer;

class PictureBase extends Visel
{
	static private var mat_: Matrix = null;

	public function new(owner : NativeUIContainer)
	{
		super(owner);
		mouseEnabled = mouseChildren = false;
		tabEnabled = false;
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
	override public function draw_Visel() : Void
	{
		super.draw_Visel();
		if ((invalid_flags_ & (Visel.INVALIDATION_FLAG_DATA | Visel.INVALIDATION_FLAG_STATE)) == 0)
			return;
		var pic: Picture = cast this;
		if (null == pic.bitmap)
			return;
		var mode: PictureMode = pic.mode;
		var smooth: Bool = true;

		var data: BitmapData = pic.bitmap.bitmapData;
		var src_w: Float = data.width;
		var src_h: Float = data.height;
		if ((src_w < 1) || (src_h < 1))
			return;
		var dst_w: Float = width_;
		var dst_h: Float = height_;
		switch(mode)
		{
		case CENTER:
			dst_w = src_w;
			dst_h = src_h;
		case CROP_TO_FIT:
			//: try stretch by height
			dst_h = width_ * src_h / src_w;
			if(dst_h < height_)
			{
				//: stretch by width
				dst_w = height_ * src_w / src_h;
				dst_h = height_;
			}
		case KEEP_SIZE_THEN_ASPECT:
			if (src_w <= width_ && src_h <= height_)
			{
				dst_w = src_w;
				dst_h = src_h;
			}
			else//fall thru PictureMode.KEEP_ASPECT
			{//:haxe suxx
				dst_h = width_ * src_h / src_w;
				if(dst_h > height_)
				{
					//: stretch by width
					dst_w = height_ * src_w / src_h;
					dst_h = height_;
				}
			}
		case KEEP_ASPECT:
			//: try stretch by height
			dst_h = width_ * src_h / src_w;
			if(dst_h > height_)
			{
				//: stretch by width
				dst_w = height_ * src_w / src_h;
				dst_h = height_;
			}
		case KEEP_WIDTH:
			dst_w = width_;
			dst_h = width_ * src_h / src_w;
		case KEEP_HEIGHT:
			dst_w = height_ * src_w / src_h;
			dst_h = height_;
		case DEFAULT:
			//:nop
		}
		var tex_x: Float = (width_ - dst_w) * 0.5;
		var tex_y: Float = (height_ - dst_h) * 0.5;

		if (null == mat_)
			mat_ = new Matrix();
		else
			mat_.identity();
		mat_.scale(dst_w / src_w, dst_h / src_h);
		mat_.translate(tex_x, tex_y);

		//:clip rect
		if (tex_x < 0)
			tex_x = 0;
		if (tex_y < 0)
			tex_y = 0;
		if (tex_x + dst_w > width_)
			dst_w = width_ - tex_x;
		if (tex_y + dst_h > height_)
			dst_h = height_ - tex_y;

		var gr = graphics;
		gr.beginBitmapFill(data, mat_, false, smooth);
		gr.drawRect(tex_x, tex_y, dst_w, dst_h);
		gr.endFill();
	}
}