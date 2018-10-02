package gs.femto_ui.kha;

class Event
{
	public var type(default, default): Int;
	public var target(default, default): Visel;
	public var stop_propagation(default, default): Bool;
	public var phase(default, default): Int;
	public var inputId(default, default): Int;
	public var globalX(default, default): Float;
	public var globalY(default, default): Float;

	private static var pool_: Array<Event> = [];

	public static inline var FLAG_CAPTURING: Int		= 0x10000;

	public static inline var MOUSE_DOWN: Int			= 1;
	public static inline var MOUSE_UP: Int				= 2;
	public static inline var MOUSE_MOVE: Int			= 3;
	public static inline var MOUSE_IN: Int				= 4;
	public static inline var MOUSE_OUT: Int				= 5;

	public static inline var MOUSE_DOWN_CAPTURING: Int	= MOUSE_DOWN | FLAG_CAPTURING;
	public static inline var MOUSE_UP_CAPTURING: Int	= MOUSE_UP | FLAG_CAPTURING;


	public static inline var PHASE_AT_TARGET: Int		= 0;
	public static inline var PHASE_CAPTURING: Int		= 1;//:from root to target.parent
	public static inline var PHASE_BUBBLING: Int		= 2;//:from target.parent to root

	private function new()
	{}
//.............................................................................
	inline function reset(ev_type: Int): Event
	{
		type = ev_type;
		stop_propagation = false;
		target = null;
		phase = PHASE_AT_TARGET;
		return this;
	}
//.............................................................................
	public static function alloc(ev_type: Int): Event
	{
        return (if (pool_.length > 0)
			pool_.pop();
				else
			new Event()).reset(ev_type);
	}
//.............................................................................
	public static function dispose(ev: Event): Void
	{
        ev.target = null;
		pool_.push(ev);
	}
//.............................................................................
	public function dump() : String
	{
		switch(type & ~FLAG_CAPTURING)
		{
		case MOUSE_DOWN:
			return "MOUSE_DOWN";
		case MOUSE_UP:
			return "MOUSE_UP";
		case MOUSE_MOVE:
			return "MOUSE_MOVE";
		case MOUSE_IN:
			return "MOUSE_IN";
		case MOUSE_OUT:
			return "MOUSE_OUT";
		default:
			return "?";
		}
	}
//.............................................................................
	public function dump_Phase() : String
	{
		switch(phase)
		{
		case PHASE_AT_TARGET:
			return "AT_TARGET";
		case PHASE_CAPTURING:
			return "CAPTURING";
		case PHASE_BUBBLING:
			return "BUBBLING";
		default:
			return "?";
		}
	}

}