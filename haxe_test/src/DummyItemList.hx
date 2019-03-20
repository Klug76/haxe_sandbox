package;

import gs.femto_ui.grid.IGridCollection;
import gs.femto_ui.Visel;

class DummyItemList implements IGridCollection
{
	public var item_count_: Int = 0;

	public function new()
	{}


	/* INTERFACE gs.femto_ui.IGridCollection */

	public function get_Count(): Int
	{
		return item_count_;
	}

	public function spawn_Item(): Visel
	{
		return new DummyItemView(null);
	}

}