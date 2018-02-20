package com.gs.console;

import haxe.ds.Vector;

@:generic
class RingBuf<T>
{
    public var head(default, null) : Int;
    public var tail(default, null) : Int;
    public var capacity(default, null) : Int;

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
        capacity = size;
        and_mask_ = size - 1;
        data_ = new Vector(size);
        clear();
    }
    //.............................................................................
    //.............................................................................
    public function clear() : Void
    {
        head = tail;
    }
    //.............................................................................
    public function push(n : T) : Void
    {
        if (length == capacity)
		{//:full
            ++head;
        }
        var idx : Int = tail++ & and_mask_;
        data_[idx] = n;
    }
    //.............................................................................
    //.............................................................................
    //.............................................................................
	public var length(get, never) : Int;
    public inline function get_length() : Int
    {
        return tail - head;
    }
    //public inline function get_capacity() : Int
    //{
        //return capacity;
    //}
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
        for (i in head...tail)
        {
            var idx: Int = i & and_mask_;
            arr.push("" + data_[idx]);
        }
        return arr.join(",");
    }
}