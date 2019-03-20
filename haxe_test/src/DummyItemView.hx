package;

import gs.femto_ui.grid.IGridCollection;
import gs.femto_ui.grid.IGridItemView;
import gs.femto_ui.Label;
import gs.femto_ui.Root;
import gs.femto_ui.Visel;

class DummyItemView extends Visel implements IGridItemView
{
	static var debug_counter_: Int = 0;

	var dbg_idx_: Int = 0;
	var idx_: Int = 0;
	var label_: Label = null;

	public function new(owner: Visel)
	{
		super(owner);
		dbg_idx_ = ++debug_counter_;
		label_ = new Label(this, "zzz");
		var r: Root = Root.instance;
		label_.set_Text_Format(r.font_, Std.int(r.def_font_size_), 0x000000);
		dummy_color = 0xc4c400;
	}

	/* INTERFACE gs.femto_ui.IGridItemView */

	public function resize_Item(nx: Float, ny: Float, nw: Float, nh: Float): Void
	{
		movesize(nx, ny, nw, nh);
		label_.movesize(0, 0, nw, nh);
	}

	public function update_Item(v: IGridCollection, idx: Int): Void
	{
		if (null != v)
		{
			if (idx < 0)
			{
				refresh();
				return;
			}
			if ((idx >= 0) && (idx < v.get_Count()))
			{
				idx_ = idx;
				refresh();
				visible = true;
				return;
			}
		}
		visible = false;
	}

	function refresh()
	{
		label_.text = "id:" + idx_ + ", counter:" + dbg_idx_;
	}

}