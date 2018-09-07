import com.gs.console.KonController;
import com.gs.console.KonsoleConfig;
import h2d.Bitmap;
import hxd.App;


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
		var cfg: KonsoleConfig = new KonsoleConfig();
		KonController.start(null, cfg);
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

        trace("LEAVE init");
    }

	function add_Text()
	{
        //var t = new h2d.HtmlText(hxd.res.DefaultFont.get(), s2d);
        var t = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
		t.maxWidth = 120;
        //t.scale(10);
        t.x = 20;
        t.y = 200;
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
				s.add("# <font color='#ff0000'>");
			else
				s.add("# <font color='#0000ff'>");
			s.add(i);
			s.add("</font>");
			//s.add("<br>");
			s.add("\n");
		}
		return s.toString();
	}

    override function update(dt: Float): Void
    {
        b.rotation += 0.01;

		Root2.instance.frame_signal_.fire();//TODO fix me
    }
}