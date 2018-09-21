package gs.femto_ui.util;

#if (flash)
import flash.Vector;
typedef VectorF = Vector<Void->Void>;
#else
typedef VectorF = Array<Void->Void>;
#end

class Signal
{
	private var fn_ : VectorF = new VectorF();
	private var fn_temp_ : VectorF = new VectorF();
	private var used_ : Int = 0;
	private var state_ : Int = 0;

	private static inline var ACTIVE : Int = 1;
	private static inline var FIRE : Int = 2;

	public function new()
	{}

	private function start() : Void
	{
		if ((state_ & Signal.ACTIVE) != 0)
		{
			return;
		}
		state_ |= Signal.ACTIVE;
		on_Start();
	}

	private function on_Start() : Void
	{}

	private function stop() : Void
	{
		if ((state_ & Signal.ACTIVE) == 0)
		{
			return;
		}
		state_ &= ~Signal.ACTIVE;
		on_Stop();
	}

	private function on_Stop() : Void
	{}

	public function fire() : Void
	{
		if ((state_ & FIRE) != 0)
			return;
		var count : Int = used_;
		if (0 == count)
			return;
		state_ |= FIRE;
		var i : Int;
		var fn : Void->Void;
		//:make copy
		for (i in 0...count)
		{
			fn = fn_[i];
			fn_temp_[i] = fn;//:https://haxe.org/manual/std-Array.html: write access in Haxe is unbounded
		}
		for (i in 0...count)
		{
			fn = fn_temp_[i];
			fn();
		}
		state_ &= ~FIRE;
	}

	/*
	* add once
	*/
	public function add(fn : Void->Void) : Void
	{
		if (fn_.indexOf(fn) < 0)
		{
			fn_[used_++] = fn;//:see below
		}
		start();
	}

	/*
	* remove if have
	*/
	public function remove(fn : Void->Void) : Void
	{
		var i : Int = fn_.indexOf(fn);
		if (i >= 0)
		{
			//:swap with last.. may cause re-order.. beware..
			fn_[i] = fn_[--used_];
			fn_[used_] = null;
		}
		if (used_ <= 0)
		{
			stop();
		}
	}
}