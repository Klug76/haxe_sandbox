package gs.femto_ui;

@:enum
abstract PictureMode(Int) from Int to Int
{
	var DEFAULT					= 0;
	var CENTER					= 1;
	var KEEP_ASPECT				= 2;
	var KEEP_SIZE_THEN_ASPECT	= 3;
	var KEEP_WIDTH				= 4;
	var KEEP_HEIGHT				= 5;
	var CROP_TO_FIT				= 6;
}
