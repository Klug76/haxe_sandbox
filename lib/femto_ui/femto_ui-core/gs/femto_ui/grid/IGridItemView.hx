package gs.femto_ui.grid;

interface IGridItemView
{
	function resize_Item(nx: Float, ny: Float, nw: Float, nh: Float): Void;
	function update_Item(v: IGridCollection, idx: Int): Void;
}