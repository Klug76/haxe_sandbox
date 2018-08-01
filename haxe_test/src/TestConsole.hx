package;

import com.gs.KonsoleDemo;
import com.gs.console.FpsMonitor;
import com.gs.console.Konsole;
import com.gs.console.KonsoleConfig;
import com.gs.console.KonsoleView;
import com.gs.console.LogLine;
import com.gs.femto_ui.Graph;
import com.gs.femto_ui.Root;
import flash.display.Stage;
import haxe.Timer;
import haxe.unit.TestCase;

class TestConsole extends TestCase
{
	var stage_: Stage;
	var k: Konsole;

	public function new(stage: Stage)
	{
		super();
		stage_ = stage;
		Root.create(stage);
	}

	public function test1()
	{
		//var f: Graph = new Graph(null);
		//var f: FpsMonitor = new FpsMonitor(null);
		{
			var a: LogLine = new LogLine();
			var t: String = "  foo\n\tbar > 0\nzoo < 1";
			a.text_ = t;
			assertEquals(t, a.get_Text());
			assertEquals("<p>&nbsp;&nbsp;foo<br>&nbsp;bar &gt; 0<br>zoo &lt; 1</p>", a.get_Html());
		}
		{
			var a: LogLine = new LogLine();
			var html: String = "pic<img src='foo'><br><p>coo</p>";
			a.html_ = html;
			assertEquals(html, a.get_Html());
			assertEquals("pic\ncoo", a.get_Text());
		}
	}

	public function test2()
	{
		k = new KonsoleDemo(stage_).k;
		assertTrue(k.cfg_.max_lines_ > 0);
	}

}