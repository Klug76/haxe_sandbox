package;

import com.gs.console.KonController;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import format.agal.Tools;
import flash.display.Stage;

typedef K = flash.ui.Keyboard;


class Shader extends hxsl.Shader
{
	static var SRC =
	{
		var input :
		{
			pos : Float3,
		};
		var color : Float3;
		function vertex( mpos : M44, mproj : M44 )
		{
			out = input.pos.xyzw * mpos * mproj;
			color = input.pos;
		}
		function fragment()
		{
			out = color.xyzw;
		}
	};
}

class Scene3D
{
	var stage : flash.display.Stage;
	var s : flash.display.Stage3D;
	var c : flash.display3D.Context3D;
	var shader : Shader;
	var pol : Polygon;
	var t : Float;
	var keys : Array<Bool>;
	var camera : Camera;

	var aux_rc_: Rectangle = new Rectangle();
	var aux_pt_: Point = new Point();

	public function new()
	{
		t = 0;
		keys = [];
		stage = flash.Lib.current.stage;
		s = stage.stage3Ds[0];
		s.addEventListener( Event.CONTEXT3D_CREATE, onReady );
		stage.addEventListener( KeyboardEvent.KEY_DOWN, onKey.bind(true) );
		stage.addEventListener( KeyboardEvent.KEY_UP, onKey.bind(false) );
		flash.Lib.current.addEventListener(Event.ENTER_FRAME, update);
		s.requestContext3D();
	}

	function onKey( down, e : KeyboardEvent )
	{
		keys[e.keyCode] = down;
	}

	function onReady( _ )
	{
		c = s.context3D;
		c.enableErrorChecking = true;
		c.configureBackBuffer( stage.stageWidth, stage.stageHeight, 0, true, true );

		shader = new Shader();
		camera = new Camera();

		pol = new Cube();
		pol.alloc(c);
	}

	function update(_)
	{
		if ( c == null )
			return;

		//t += 0.01;

		c.clear(0, 0.1, 0, 1);
		c.setDepthTest( true, flash.display3D.Context3DCompareMode.LESS_EQUAL );
		c.setCulling(flash.display3D.Context3DTriangleFace.BACK);

		if( keys[K.UP] )
			camera.moveAxis(0,-0.1);
		if( keys[K.DOWN] )
			camera.moveAxis(0,0.1);
		if( keys[K.LEFT] )
			camera.moveAxis(-0.1,0);
		if( keys[K.RIGHT] )
			camera.moveAxis(0.1, 0);
		if( keys[109] )//+
			camera.zoom /= 1.05;
		if( keys[107] )//-
			camera.zoom *= 1.05;
		camera.update();

		var project = camera.m.toMatrix();

		var mpos = new flash.geom.Matrix3D();
		mpos.appendRotation(t * 10, flash.geom.Vector3D.Z_AXIS);

		shader.mpos = mpos;
		shader.mproj = project;
		shader.bind(c, pol.vbuf);
		c.drawTriangles(pol.ibuf);

		if (KonController.is_Zoom_Visible())
		{
			if (KonController.prepare_Zoom_Paint())
			{
				paint_Zoom();
			}
			KonController.paint_Zoom_Crosshair();
		}

		c.present();
	}

	private function paint_Zoom() : Void
	{
		var bd: BitmapData = KonController.get_Zoom_BitmapData();
		var src_rc: Rectangle = KonController.get_Zoom_Src_Rect();
		var dst_pt: Point = KonController.get_Zoom_Dst_Pt();
		c.drawToBitmapData(bd, src_rc, dst_pt);//:need 4 air 25+
	}

}