package
{
	import flash.events.KeyboardEvent;
	import gs.konsole.KonController;
	import gs.konsole.KonsoleConfig;
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
			cfg.con_font_size_ = 18;
			cfg.zoom_root_ = this;
			cfg.redirect_trace_ = false;
			cfg.preload_ = true;

			KonController.start(this, cfg);

			add_Box();

			Log("Hello,");
			trace("World!");

			stage.addEventListener(KeyboardEvent.KEY_DOWN, on_Key);
		}

		private function on_Key(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
			case Keyboard.F1:
				Log("<F1>");
				for (var i: int = 0; i < 2000; ++i)
				{
					Log("[" + i + "] bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla.");
				}
				break;
			case Keyboard.F2:
				Log("<F2>");
				break;
			}
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