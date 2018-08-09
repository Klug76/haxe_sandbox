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

//:why is MovieClip? used stage property only

			haxe.initSwc(this);

			var cfg: KonsoleConfig = new KonsoleConfig();

			cfg.con_bg_color_ = 0xFF000000;
			cfg.con_text_color_ = 0x77BB77;
			cfg.con_text_size_ = 18;

			KonController.start(this, cfg);

			var f: Number = 0.2 + 0.1;
			Log(f.toPrecision(4));

			foo(Keyboard.ESCAPE);
			foo(Keyboard.BACK);
			var b: Boolean = KonController.visible;
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