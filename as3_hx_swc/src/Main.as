package
{
	import com.gs.console.KonController;
	import com.gs.console.KonsoleConfig;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
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
			cfg.zoom_root_ = this;

			KonController.start(this, cfg);

			add_Box();

			Log("Hello!");
		}

		private function add_Box(): void
		{
			var sp: Shape = new Shape();
			var gr: Graphics = sp.graphics;
			gr.clear();
			gr.beginFill(0x0000ff, 1);
			gr.drawRect(0, 0, 10, 20);
			gr.endFill();
			sp.x = 100;
			sp.y = 100;
			addChild(sp);
		}

	}

}