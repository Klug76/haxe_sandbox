package;

import kha.System;
import kha.Assets;

class Main
{
	public static function main()
	{
		System.start({title: "Kha-test", width: 800, height: 600}, function (_)
		{
			// Just loading everything is ok for small projects
			Assets.loadEverything(function ()
			{
				new Demo();
			});
		});
	}
}
