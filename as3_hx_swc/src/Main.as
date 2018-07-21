package
{
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
			// entry point
			haxe.initSwc(this);

			trace(Foo.foo());
			var f: Number = 0.2 + 0.1;
			trace(f.toPrecision(4));

			foo(Keyboard.ESCAPE);
			foo(Keyboard.BACK);
		}

		private function foo(u: uint): void
		{
			trace(u);
			switch(u)
			{
			case Keyboard.ESCAPE:
				trace("Esc");
				break;
			case Keyboard.BACK:
				trace("Back");
				break;
			}
		}
	}

}