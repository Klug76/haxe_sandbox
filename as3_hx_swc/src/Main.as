package
{
	import com.gs.console.KonController;
	import com.gs.console.KonsoleConfig;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.ui.Keyboard;

	public class Main extends MovieClip
	{

		public function Main()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

//:magic call
//:sources here:
//:\HaxeToolkit\haxe\std\flash\Boot.hx
//:\HaxeToolkit\haxe\std\flash\Lib.hx
//:\HaxeToolkit\haxe\std\haxe\Log.hx

			haxe.initSwc(this);

			var cfg: KonsoleConfig = new KonsoleConfig();
			KonController.start(stage, cfg);

			var f: Number = 0.2 + 0.1;
			Log(f.toPrecision(4));

			foo(Keyboard.ESCAPE);
			foo(Keyboard.BACK);
		}

		private function foo(u: uint): void
		{
			Log("u=" + u);
			switch(u)
			{
			case Keyboard.ESCAPE:
				Log("Esc");
				break;
			case Keyboard.BACK:
				Log("Back");
				break;
			}
		}
	}

}