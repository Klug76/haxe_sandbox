package;

import com.gs.femto_ui.util.Signal;

class Root2
{
	public static var instance(get, never) : Root2;
	private static var instance_ : Root2 = null;

	public var frame_signal_ : Signal = new Signal();

	public function new()
	{

	}
//.............................................................................
	private static inline function get_instance() : Root2
	{
		return instance_;
	}
//.............................................................................
	public static function create() : Root2
	{
		if (null == instance_)
		{
			instance_ = new Root2();
		}
		return instance_;
	}

}