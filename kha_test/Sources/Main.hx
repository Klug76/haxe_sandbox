package;

import kha.System;
import kha.Assets;

#if kha_html5
import js.html.CanvasElement;
import js.Browser.document;
import js.Browser.window;
#end

class Main
{
	public static function main()
	{
		setFullWindowCanvas();//TODO how to emulate StageScaleMode.NO_SCALE ?

		System.start({title: "Kha-test", width: 1200, height: 800}, function (_)
		{
			// Just loading everything is ok for small projects
			Assets.loadEverything(function ()
			{
				new Demo();
			});
		});
	}

	private static function setFullWindowCanvas(): Void
	{
#if kha_html5
		//make html5 canvas resizable
		document.documentElement.style.padding = "0";
		document.documentElement.style.margin = "0";
		document.body.style.padding = "0";
		document.body.style.margin = "0";
		var canvas = cast(document.getElementById("khanvas"), CanvasElement);
		canvas.style.display = "block";

		var resize = function()
		{
			canvas.width = Std.int(window.innerWidth * window.devicePixelRatio);
			canvas.height = Std.int(window.innerHeight * window.devicePixelRatio);
			canvas.style.width = document.documentElement.clientWidth + "px";
			canvas.style.height = document.documentElement.clientHeight + "px";
		}
		window.onresize = resize;
		resize();
#end
	}

}
