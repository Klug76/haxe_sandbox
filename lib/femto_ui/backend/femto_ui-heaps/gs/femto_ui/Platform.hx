package gs.femto_ui;
import haxe.Timer;

class Platform
{
	inline static public function get_Timer() : Int
	{
		return Timer.stamp();
	}

}