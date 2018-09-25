package;

import buddy.SuitesRunner;
import buddy.reporting.ConsoleReporter;
import buddy.reporting.TraceReporter;
import buddy.BuddySuite;
import gs.femto_ui.Root;
import gs.femto_ui.Visel;
using buddy.Should;

class Test1 extends BuddySuite
{

	public function new()
	{
        describe("test visel",
		{
			var N: Int = 10;
			var v: Visel = null;
			var dcount: Int = Visel.debug_counter_;

            beforeAll(function(done)
			{
				v = new Visel(null);
				v.dummy_color = 0xc0c0c0;
				v.resize_Visel(32, 32);
                haxe.Timer.delay(function()
				{

                    done(); // Call the done() function when the async operation is complete.
                }, 100);
            });

            it("test children",
			{
	            v.num_Children.should.be(0);
				for (i in 0...N)
				{
					var cv = new Visel(null);
					var av = v.add_Child(cv);
					av.should.be(cv);
				}
                v.num_Children.should.be(N);
				{
					var cv: Visel = new Visel(null);
					var av = v.add_Child_At(cv, 0);
					av.should.be(cv);
					v.get_Child_Index(cv).should.be(0);
				}
	            v.num_Children.should.be(N + 1);
				{
					var cv = v.get_Child_At(1);
					v.remove_Child(cv);
					cv.parent.should.be(null);
				}
	            v.num_Children.should.be(N);
				{
					var cv = v.get_Child_At(2);
					v.remove_Child_At(2);
					cv.parent.should.be(null);
				}
				{
					var cv: Visel = v.get_Child_As(3, Visel);
					cv.bring_To_Top();
					v.get_Child_Index(cv).should.be(v.num_Children - 1);
					var av: Visel = v.get_Child_As(1, Visel);
					av.bring_To_Top();
					v.get_Child_Index(cv).should.be(v.num_Children - 2);
				}
				v.remove_Children();
	            v.num_Children.should.be(0);
				v.destroy_Visel();

				Visel.debug_counter_.should.be(dcount);
            });

        });
	}

	static public function run_All()
	{
		#if flash
		var reporter = new TraceReporter();
		#else
		var reporter = new ConsoleReporter();
		#end
		var runner = new SuitesRunner([
										  new Test1()
									  ], reporter);

		runner.run();
	}

}