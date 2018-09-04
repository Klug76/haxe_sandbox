//import h2d.Bitmap;
//import hxd.App;

import com.gs.con_test.TestConsole;
import com.gs.con_test.TestSignal;
import com.gs.con_test.TestNumUtils;
import com.gs.con_test.TestStrUtils;
import com.gs.con_test.TestEval;
import haxe.unit.TestRunner;
import com.gs.con_test.TestRingBuf;

class Main// extends App
{
    static function main(): Void
    {
        trace("ENTER main");
		var tr = new TestRunner();
		tr.add(new TestRingBuf());
		tr.add(new TestNumUtils());
		tr.add(new TestStrUtils());
		tr.add(new TestSignal());
		tr.add(new TestEval());
		tr.add(new TestConsole());
		tr.run();
        //new Main();
        trace("LEAVE main");
    }
/*
    var b: h2d.Bitmap;

    override function init(): Void
    {
        trace("ENTER init");

		engine.backgroundColor = 0x4A4137;

        b = new h2d.Bitmap(h2d.Tile.fromColor(0xff0000, 60, 60), s2d);
        b.x = 50;
        b.y = 100;

        b.tile = b.tile.center();
        b.rotation = Math.PI / 4;

        trace("LEAVE init");
    }

    override function update(dt: Float): Void
    {
        b.rotation += 0.01;
    }
	*/
}