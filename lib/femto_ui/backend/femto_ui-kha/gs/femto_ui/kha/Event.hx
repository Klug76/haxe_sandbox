package gs.femto_ui.kha;
import gs.femto_ui.Visel;
import gs.femto_ui.util.Util;

class Event
{
	public var type(default, default): Int;
	public var target(default, default): Visel;
	public var stop_propagation(default, default): Bool;
	public var phase(default, default): Int;
	public var input_id(default, default): Int;
	public var globalX(default, default): Float;
	public var globalY(default, default): Float;
	public var targetX(default, default): Float;
	public var targetY(default, default): Float;
	public var code(default, default): Int;
	public var char_code(default, default): Int;

	private static var pool_: Array<Event> = [];

	public static inline var FLAG_CAPTURING: Int				= 0x10000;

	public static inline var MOUSE_DOWN: Int					= 0;
	public static inline var RIGHT_MOUSE_DOWN: Int				= 1;
	public static inline var MOUSE_UP: Int						= 10;
	public static inline var RIGHT_MOUSE_UP: Int				= 11;
	public static inline var MOUSE_MOVE: Int					= 20;
	public static inline var MOUSE_IN: Int						= 21;
	public static inline var MOUSE_OUT: Int						= 22;
	public static inline var MOUSE_WHEEL: Int					= 23;

	public static inline var KEY_DOWN: Int						= 100;
	public static inline var KEY_UP: Int						= 101;
	public static inline var KEY_PRESS: Int						= 102;

	public static inline var FOCUS_IN: Int						= 200;
	public static inline var FOCUS_OUT: Int						= 201;

	public static inline var MOUSE_DOWN_CAPTURING: Int			= MOUSE_DOWN | FLAG_CAPTURING;
	public static inline var MOUSE_UP_CAPTURING: Int			= MOUSE_UP | FLAG_CAPTURING;
	public static inline var RIGHT_MOUSE_DOWN_CAPTURING: Int	= RIGHT_MOUSE_DOWN | FLAG_CAPTURING;
	public static inline var RIGHT_MOUSE_UP_CAPTURING: Int		= RIGHT_MOUSE_UP | FLAG_CAPTURING;

	public static inline var PHASE_AT_TARGET: Int				= 0;
	public static inline var PHASE_CAPTURING: Int				= 1;//:from root to target.parent
	public static inline var PHASE_BUBBLING: Int				= 2;//:from target.parent to root

	private function new()
	{}
//.............................................................................
	public function reset(ev_type: Int): Void
	{
		type = ev_type;
		stop_propagation = false;
		phase = PHASE_AT_TARGET;
	}
//.............................................................................
	public static function alloc(): Event
	{
        if (pool_.length > 0)
			return pool_.pop();
		return new Event();
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
		case KEY_DOWN:
			return "KEY_DOWN";
		case KEY_UP:
			return "KEY_UP";
		case KEY_PRESS:
			return "KEY_PRESS";
		case x:
			return "0x" + Util.toHex(x);
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