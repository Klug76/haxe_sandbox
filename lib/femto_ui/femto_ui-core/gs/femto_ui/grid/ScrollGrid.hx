package gs.femto_ui.grid;

using gs.femto_ui.RootBase.NativeUIContainer;

@:allow(gs.femto_ui.ScrollGridBase)
class ScrollGrid extends ScrollGridBase
{
	public static inline var AUTO_FIT: Int = 0;

	public var x_spacing_					: Int = 0;
	public var y_spacing_					: Int = 0;
	public var x_border_					: Int = 0;
	public var y_border_					: Int = 0;
	public var user_item_width_				: Int;//:may be AUTO_FIT
	public var user_item_height_			: Int;//:may be AUTO_FIT
	public var user_cols_					: Int = AUTO_FIT;//:may be set exactly
	public var user_rows_					: Int = AUTO_FIT;//:may be set exactly
	public var item_x_align_				: Align = CENTER;
	public var item_y_align_				: Align = CENTER;
	public var align_						: Align = CENTER;
	public var dummy_item_count_			: Int = 0;//:e.g. 'add friend' item
	public var drag_disabled_				: Bool = false;
	public var vertical_					: Bool = false;

	public var item_list_					: IGridCollection = null;

	//:calculated
	private var cols_						: Int = 0;
	private var rows_						: Int = 0;
	private var num_cells_					: Int = 0;
	private var item_width_					: Float = 0;
	private var item_height_				: Float = 0;
	private var total_pix_size_				: Float = 0;
	private var overdrag_limit_				: Float = 0;

	private var view_						: Visel;

	private var is_dragged_					: Bool = false;
	private var start_x_					: Float = 0;
	private var start_y_					: Float = 0;

	private var diff_pos_					: Float = 0;
	private var prev_pos_					: Float = 0;
	private var diff_time_					: Float = 0;
	private var prev_time_					: Float = 0;
	private var anim_time_					: Float = 0;

	public function new(owner : NativeUIContainer)
	{
		super(owner);
#if debug
		name = "grid";
#end
		var r: Root = Root.instance;
		user_item_width_ =
			user_item_height_ = Std.int(128 * r.ui_factor_);
		on_Resize = update;
		view_ = new Visel(this);
	}
//.............................................................................
	public function get_Item_Count(): Int
	{
		return if (item_list_ != null) item_list_.get_Count(); else 0;
	}
//.............................................................................
	public function update()
	{
		if (null == item_list_)
			return;
		update_Size();
		calc_Item_Pix_Size();
		update_Item_Count();
		if (!is_dragged_)
			fix_Scroll_Pos();
		update_View();
	}
//.............................................................................
	public function refresh_Visible_Items()
	{
		for (i in 0...num_cells_)
		{
			var child: IGridItemView = cast view_.get_Child_At(i);
			child.update_Item(item_list_, -1);//:sic
		}
	}
//.............................................................................
	function fix_Scroll_Pos()
	{
		var threshold: Float = Root.instance.drag_threshold_;
		if (!vertical_)
		{
			var newX: Float = scroll_rect_x;
			var maxX: Float = Math.max(0, total_pix_size_ - width_);
			if (newX < threshold)
				newX = 0;
			else if (newX + threshold > maxX)
				newX = maxX;
			scroll_rect_x = newX;
		}
		else
		{
			var newY: Float = scroll_rect_y;
			var maxY: Float = Math.max(0, total_pix_size_ - height_);
			if (newY < threshold)
				newY = 0;
			else if (newY + threshold > maxY)
				newY = maxY;
			scroll_rect_y = newY;
		}
	}
//.............................................................................
	function update_Item_Count()
	{
		var num_cells: Int = rows_ * cols_;
		if (num_cells_ == num_cells)
			return;
		num_cells_ = num_cells;
		//Log("grid::num_cells_=" + num_cells_);
		var nc: Int = view_.num_Children;
		if (nc < num_cells)
		{//:create
			for (_ in 0...(num_cells - nc))
			{
				view_.add_Child(item_list_.spawn_Item());
			}
		}
		else if (nc > num_cells)
		{//:hide
			for (i in num_cells...nc)
			{
				var v = view_.get_Child_At(i);
				var child: IGridItemView = cast v;
				child.update_Item(null, 0);
			}
		}
	}
//.............................................................................
	function calc_Item_Pix_Size()
	{
		total_pix_size_ = 0;
		item_width_  = 0;
		item_height_ = 0;
		cols_ = user_cols_;
		rows_ = user_rows_;

		var count: Int = get_Item_Count() + dummy_item_count_;
		if (count <= 0)
		{
			//trace("grid is empty");
			return;
		}

		var w: Float = width_ - x_border_ * 2;
		if (w < 1)
			w = 1;
		var h: Float = height_ - y_border_ * 2;
		if (h < 1)
			h = 1;

		if (AUTO_FIT == cols_)
		{
			if (user_item_width_ > 0)
			{
				cols_ = Math.floor(w / (user_item_width_ + x_spacing_));
				if (cols_ <= 0)
					cols_ = 1;
			}
#if debug
			else
			{
				throw "AUTO_FIT conflict on x";
			}
#end
		}
		if (AUTO_FIT == rows_)
		{
			if (user_item_height_ > 0)
			{
				rows_ = Math.floor(h / (user_item_height_ + y_spacing_));
				if (rows_ <= 0)
					rows_ = 1;
			}
#if debug
			else
			{
				throw "AUTO_FIT conflict on y";
			}
#end
		}
		if (cols_ <= 0 || rows_ <= 0)
		{
			//Log("grid::rows_=" + rows_ + "; cols_=" + cols_);
			return;
		}
		item_width_ = w / cols_;
		item_height_ = h / rows_;

//===============================================================

		var num_cells: Int = rows_ * cols_;
		if (!vertical_)
		{
			if (num_cells < count)//:adjust count for drag
				++cols_;
			overdrag_limit_ = Math.max(50, item_width_ * 0.75);
			var total_col_count: Int = Math.floor(count / rows_);
			if ((count % rows_) != 0)
				++total_col_count;
			if (total_col_count < user_cols_)
				total_col_count = user_cols_;
			total_pix_size_ = item_width_ * total_col_count;
		}
		else
		{
			if (num_cells < count)//:adjust count for drag
				++rows_;
			overdrag_limit_ = Math.max(50, item_height_ * 0.75);
			var total_row_count: Int = Math.floor(count / cols_);
			if ((count % cols_) != 0)
				++total_row_count;
			if (total_row_count < user_rows_)
				total_row_count = user_rows_;
			total_pix_size_ = item_height_ * total_row_count;
		}
		//trace("grid::size=" + w +"x" + h + "; rows_=" + rows_ + "; cols_=" + cols_);
	}
//.............................................................................
	function update_View()
	{
		place_Items();
		update_Scroll_Rect();
		update_Track();
		update_Arrows();
	}
//.............................................................................
	function update_Track()
	{

	}
//.............................................................................
	function update_Arrows()
	{

	}
//.............................................................................
	function place_Items()
	{
		var k: Int = 0;
		var idx: Int;
		var nx: Float;
		var ny: Float;

		if (!vertical_)
		{
			var cx: Float = scroll_rect_x;
			if (cx < 0)
				cx = 0;
			var first_col: Int = Math.floor(cx / item_width_);
			var col_d: Int = (Math.floor(cx / (item_width_ * cols_)) * cols_) - first_col + cols_;
			var add_x: Float = 0;
			if (total_pix_size_ < width_)
			{
				switch(align_)
				{
				case CENTER:
					add_x = (width_ - total_pix_size_) * .5;
				case FAR:
					add_x = width_ - total_pix_size_;
				case NEAR:
					//:nop
				}
			}
			for (i in 0...cols_)
			{
				var ix : Int = first_col + (col_d + i) % cols_;
				nx = ix * item_width_ + x_border_ + add_x;
				for (j in 0...rows_)
				{
					ny = j * item_height_ + y_border_;
					//Log("new idx=" + new_idx);
					idx = ix * rows_ + j;
					place_Item(idx, nx, ny, k);
					++k;
				}
			}
		}
		else
		{
			var cy: Float = scroll_rect_y;
			if (cy < 0)
				cy = 0;
			var first_row: Int = Math.floor(cy / item_height_);
			var row_d: Int = (Math.floor(cy / (item_height_ * rows_)) * rows_) - first_row + rows_;
			var add_y: Float = 0;
			if (total_pix_size_ < height_)
			{
				switch(align_)
				{
				case CENTER:
					add_y = (height_ - total_pix_size_) * .5;
				case FAR:
					add_y = height_ - total_pix_size_;
				case NEAR:
					//:nop
				}
			}
			for (j in 0...rows_)
			{
				var iy : Int = first_row + (row_d + j) % rows_;
				ny = iy * item_height_ + y_border_ + add_y;
				for (i in 0...cols_)
				{
					nx = i * item_width_ + x_border_;
					idx = iy * cols_ + i;
					place_Item(idx, nx, ny, k);
					++k;
				}
			}
		}
	}
//.............................................................................
	function place_Item(idx: Int, nx: Float, ny: Float, k: Int)
	{
		if (k >= num_cells_)
			return;
		var nw: Float = user_item_width_;
		var nh: Float = user_item_height_;
		if (AUTO_FIT == user_item_width_)
			nw = item_width_ - x_spacing_;
		if (AUTO_FIT == user_item_height_)
			nh = item_height_ - y_spacing_;

		switch(item_x_align_)
		{
		case CENTER:
			nx += (item_width_ - nw) * .5;
		case FAR:
			nx += item_width_ - nw;
		case NEAR:
			//:nop
		}
		switch(item_y_align_)
		{
		case CENTER:
			ny += (item_height_ - nh) * .5;
		case FAR:
			ny += item_height_ - nh;
		case NEAR:
			//:nop
		}

		var child: IGridItemView = cast view_.get_Child_At(k);
		child.resize_Item(nx, ny, nw, nh);//:must be above
		child.update_Item(item_list_, idx);//:update may calc text size using nw, nh
		//trace('place item[' +idx +'] at ' + nx + ":" + ny + "; " + nw + "x" + nh);
	}
//.............................................................................
//.............................................................................
	var tap_id(default, null): Int = 0;
	function handle_Tap(tapId: Int, mx: Float, my: Float, time: Float)
	{
		tap_id = tapId;
		start_x_ = mx;
		start_y_ = my;
		//trace("tap " + mx + ":" + my);
	}
//.............................................................................
	function handle_Tap_End(tapId: Int, mx: Float, my: Float, time: Float)
	{
		if (is_dragged_)
		{
			is_dragged_ = false;
			do_Drag(mx, my, time, false);
			fix_Scroll_Pos();
			update_View();
		}
	}
//.............................................................................
	function handle_Move(tapId: Int, mx: Float, my: Float, time: Float)
	{
		if (tap_id != tapId)
			return;
		//trace("move " + mx + ":" + my);
		if (!is_dragged_)
		{
			var nx: Float = Math.abs(start_x_ - mx);
			var ny: Float = Math.abs(start_y_ - my);
			if (!can_Start_Drag(nx, ny))
				return;
			is_dragged_ = true;
			prev_time_ = time;
			if (!vertical_)
				prev_pos_ = mx;
			else
				prev_pos_ = my;
			diff_pos_ = 0;
			diff_time_ = 0;
			update_Track();
			update_Arrows();
		}
		do_Drag(mx, my, time, true);
	}
//.............................................................................
	function can_Start_Drag(nx: Float, ny: Float) : Bool
	{
		if (drag_disabled_)
			return false;
		var r: Root = Root.instance;
		if (!vertical_)
		{
			return nx > r.drag_threshold_;
		}
		return ny > r.drag_threshold_;
	}
//.............................................................................
	function do_Drag(mX: Float, mY: Float, time: Float, calcDiff: Bool)
	{
		//trace("do_Drag " + mX + ":" + mY);
		if (!vertical_)
		{
			var dx: Float = prev_pos_ - mX;
			if (calcDiff)
			{
				diff_pos_  = (diff_pos_ + dx) * .5;
				diff_time_ = (diff_time_ + time - prev_time_) * .5;
				anim_time_ = time;
			}
			prev_pos_ = mX;
			prev_time_ = time;
			var newX: Float = scroll_rect_x + dx;
			var maxX: Float = Math.max(0, total_pix_size_ - width_);
			if (newX < -overdrag_limit_)
				newX = -overdrag_limit_;
			else if (newX > maxX + overdrag_limit_)
				newX = maxX + overdrag_limit_;
			scroll_rect_x = newX;
		}
		else
		{
			var dy: Float = prev_pos_ - mY;
			if (calcDiff)
			{
				diff_pos_  = (diff_pos_ + dy) * .5;
				diff_time_ = (diff_time_  + time - prev_time_) * .5;
				anim_time_ = time;
			}
			prev_pos_ = mY;
			prev_time_ = time;
			var newY: Float = scroll_rect_y + dy;
			var maxY: Float = Math.max(0, total_pix_size_ - height_);
			if (newY < -overdrag_limit_)
				newY = -overdrag_limit_;
			else if (newY > maxY + overdrag_limit_)
				newY = maxY + overdrag_limit_;
			scroll_rect_y = newY;
		}
		update_View();
	}
//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
}