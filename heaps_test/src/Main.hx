import com.gs.console.KonsoleConfig;
import h2d.Bitmap;
import hxd.App;

#if flash
import com.gs.console.KonController;
#end

class Main extends App
{
	var b: h2d.Bitmap;

	static function main()
	{
		init_Console();
		new Main();
	}

	static function init_Console()
	{
#if flash
		var cfg: KonsoleConfig = new KonsoleConfig();
		KonController.start(null, cfg);
#end
	}

	override function init(): Void
	{
		trace("ENTER init");

		engine.backgroundColor = 0x4A4137;

		b = new h2d.Bitmap(h2d.Tile.fromColor(0xff0000, 60, 60), s2d);
		b.x = 50;
		b.y = 100;

		b.tile = b.tile.center();
		b.rotation = Math.PI / 4;

		Root2.create();
		var v = new Visel2(s2d);
		v.dummy_color_ = 0xff00ff;
		v.dummy_alpha_ = .75;
		v.x = 200;
		v.y = 100;
		v.resize(150, 100);

		add_Text();

		hxd.Stage.getInstance().addEventTarget(onEvent);

		trace("LEAVE init");
	}

	function onEvent(event : hxd.Event)
	{
		switch(event.kind)
		{
			case EKeyDown: trace('DOWN keyCode: 0x${StringTools.hex(event.keyCode, 2)}');
			case EKeyUp: trace('UP keyCode: 0x${StringTools.hex(event.keyCode, 2)}');
			case _:
		}
	}

	function add_Text()
	{
		var maxw = 220;
		var mask = new h2d.Mask(maxw, 260, s2d);
		mask.x = 120;
		mask.y = 200;
		var t = new h2d.HtmlText(hxd.res.DefaultFont.get(), mask);
		//var t = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
		t.maxWidth = maxw;
		//t.
		//t.scale(10);
		t.x = 10;
		t.y = 10;
		//var s = "Haxe <font color='#ff0000'>Rocks!!!</font>";
		var s = gen_Text();
		t.text = s;
	}

	function gen_Text() : String
	{
		var s: StringBuf = new StringBuf();
		for (i in 0...2048)
		{
			if ((i & 1) != 0)
				s.add("#<font color='#ff0000'>");
			else
				s.add("#<font color='#0000ff'>");
			s.add(i);
			s.add("</font>");
			s.add(" bla bla bla bla bla bla bla bla bla bla bla!");
			s.add("<br/>");
			//s.add("\n");
		}
		return s.toString();
	}

	override function update(dt: Float): Void
	{
		b.rotation += 0.01;

		Root2.instance.frame_signal_.fire();//TODO fix me
	}
}