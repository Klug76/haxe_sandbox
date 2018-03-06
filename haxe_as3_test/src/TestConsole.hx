package;

import com.gs.console.FpsMonitor;
import com.gs.console.LogLine;
import com.gs.femto_ui.Graph;
import flash.display.Stage;
import haxe.unit.TestCase;

class TestConsole extends TestCase
{
	var stage_: Stage;

	public function new(stage: Stage)
	{
		super();
		stage_ = stage;
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
}