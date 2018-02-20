package com.gs.console;

import haxe.ds.Vector;

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
        clear();
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
    //.............................................................................
	public var length(get, never) : Int;
    public inline function get_length() : Int
    {
        return tail_ - head_;
    }
    //.............................................................................
    public function item(id : Int) : T
    {
        return data_[id & and_mask_];
    }
    //.............................................................................
    //.............................................................................
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
}