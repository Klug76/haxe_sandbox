package;

import com.gs.console.KonController;
import com.gs.console.KonsoleConfig;
import flash.Lib;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;

class Main extends Sprite
{

	public function new()
	{
		super();
		if (null == stage)
			addEventListener(Event.ADDED_TO_STAGE, on_Added_To_Stage);
		else
			on_Added_To_Stage(null);
	}

	private function on_Added_To_Stage(_): Void
	{
		stage.scaleMode = StageScaleMode.NO_SCALE;//AIR doesn’t like using anything besides StageScaleMode.NO_SCALE,
			//and Adobe’s documentation discourages using any other scaling mode.
		stage.align = StageAlign.TOP_LEFT;

		var cfg: KonsoleConfig = new KonsoleConfig();

		cfg.con_bg_color_ = 0xFF000000;
		cfg.con_text_color_ = 0x77BB77;
		cfg.con_text_size_ = 18;
		cfg.custom_zoom_draw_ = true;

		KonController.start(stage, cfg);

		KonController.add("Hello");

		new Scene3D();
	}

	static function main()
	{
		Lib.current.addChild(new Main());
	}

}