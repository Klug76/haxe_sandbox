package;

import com.gs.con_test.TestConsole;
import com.gs.con_test.TestSignal;
import com.gs.con_test.TestNumUtils;
import com.gs.con_test.TestStrUtils;
import com.gs.con_test.TestEval;
import haxe.unit.TestRunner;
import com.gs.con_test.TestRingBuf;

class TestAll
{

	public static function main(): Void
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

		trace("LEAVE main");
	}

}