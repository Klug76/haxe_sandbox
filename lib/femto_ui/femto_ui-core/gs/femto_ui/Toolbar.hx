package gs.femto_ui;

using gs.femto_ui.RootBase.NativeUIContainer;

class Toolbar extends Visel
{
	public var spacing_ : Float = 0;
	public var x_border_ : Float = 0;
	public var y_border_ : Float = 0;
	public var align_ : Int = Align.NEAR;

	public function new(owner : NativeUIContainer)
	{
		super(owner);
#if debug
		name = "toolbar";
#end
		on_Resize = update_Layout;
	}
//.............................................................................
//.............................................................................
	public function update_Layout() : Void
	{
		//trace("hbox::height=" + height_);
		var count : Int = num_Children;
		if (count <= 0)
		{
			return;
		}
		var nx : Float = x_border_;
		var ny : Float = y_border_;
		var nw : Float;
		var pw : Float = width_ - x_border_ * 2;
		var nh : Float = height_ - y_border_ * 2;
		var child : Visel;
		var total_w : Float = 0;
		var dx : Float = spacing_;
		if (Align.NEAR != align_)
		{
			for (i in 0...count)
			{
				child = get_Child_As(i, Visel);
				if (null == child)
					continue;
				nw = child.width;
				if (nw > 0)
				{
					if (total_w > 0)
					{
						total_w += spacing_;
					}
					total_w += nw;
				}
			}
			switch (align_)
			{
				case Align.CENTER:
					nx += (pw - total_w) * 0.5;
				case Align.FAR:
					nx += pw - total_w;
			}
		}
		for (i in 0...count)
		{
			child = get_Child_As(i, Visel);
			if (null == child)
				continue;
			nw = child.width;
			child.visible = nx + nw <= width_ - x_border_;
			child.movesize(nx, ny, nw, nh);
			//trace("hbox::child " + i + " mov(" + nx + ", " + ny + "," + nw + ", " + nh + ")");
			nx += nw + dx;
		}
	}
}

