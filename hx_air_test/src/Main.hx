package;

import gs.konsole.KonController;
import flash.Lib;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

class Main extends Sprite
{

	public function new()
	{
		super();
		add_Box();
	}

	private function add_Box(): Void
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

	static function main()
	{
		var m = new Main();
		KonController.start(m, null);//:no stage yet
		Lib.current.addChild(m);
		KonController.get_Config().zoom_root_ = m;
		trace("Hello!");
	}

}