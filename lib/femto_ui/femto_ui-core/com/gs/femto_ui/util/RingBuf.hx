package com.gs.femto_ui.util;

#if (flash)
import flash.Vector;//:faster, no casting
#else
import haxe.ds.Vector;
#end

@:generic
class RingBuf<T>
{
	private var head_: Int;
	public var head(get, null) : Int;
	public inline function get_head() : Int
	{
		return head_;
	}

	private var tail_: Int;
	public var tail(get, null) : Int;
	public inline function get_tail() : Int
	{
		return tail_;
	}

	private var capacity_: Int;
	public var capacity(get, null) : Int;
	public inline function get_capacity() : Int
	{
		return capacity_;
	}

	private var data_ : Vector<T>;
	private var and_mask_ : Int;

	public function new(size : Int)
	{
		init(size);
	}
//.............................................................................
	private function init(size : Int) : Void
	{
		size = Util.next_Power_Of_2(size);
		capacity_ = size;
		and_mask_ = size - 1;
		data_ = new Vector(size);
		head_ = tail_ = 0;
	}
//.............................................................................
//.............................................................................
	public function clear() : Void
	{
		head_ = tail_;
	}
//.............................................................................
	public function push(n : T) : Void
	{
		if (length == capacity_)
		{//:full
			++head_;
		}
		var idx : Int = tail_++ & and_mask_;
		data_[idx] = n;
	}
//.............................................................................
//.............................................................................
	public inline function is_Empty(): Bool
	{
		return head_ == tail_;
	}
//.............................................................................
	public var length(get, never) : Int;
	public inline function get_length() : Int
	{
		return tail_ - head_;
	}
//.............................................................................
	public inline function item(id : Int) : T
	{
		return data_[id & and_mask_];
	}
//.............................................................................
	public var front(get, never) : T;
	public function get_front(): T
	{//:assume tail_ > head_
		return data_[head_ & and_mask_];
	}
//.............................................................................
	public var back(get, never) : T;
	public function get_back(): T
	{//:assume tail_ > head_
		return data_[(tail_ - 1) & and_mask_];
	}
//.............................................................................
	public #if flash inline #end function have(v: T): Bool
	{
#if flash
		return data_.indexOf(v) >= 0;
#else
		for (i in head_...tail_)
		{
			var idx: Int = i & and_mask_;
			if (data_[idx] == v)
				return true;
		}
		return false;
#end
	}
//.............................................................................
#if debug
	public function dump() : String
	{
		var arr : Array<String> = [];
		for (i in head_...tail_)
		{
			var idx: Int = i & and_mask_;
			arr.push(Std.string(data_[idx]));
		}
		return arr.join(",");
	}
#end
}