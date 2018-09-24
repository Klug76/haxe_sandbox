package;

import kha.System;
import kha.Assets;

class Main
{
	public static function main()
	{
		System.start({title: "Kha-test", width: 1200, height: 800}, function (_)
		{
			// Just loading everything is ok for small projects
			Assets.loadEverything(function ()
			{
				new Demo();
			});
		});
	}
}
