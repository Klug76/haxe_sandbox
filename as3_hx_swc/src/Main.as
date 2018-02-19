package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

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
		}

	}

}