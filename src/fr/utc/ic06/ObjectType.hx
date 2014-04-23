package fr.utc.ic06;
import flash.display.Sprite;
import format.SWF;
import haxe.FastList;
import nape.geom.GeomPoly;
import nape.shape.Polygon;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObject;

/**
 * ...
 * @author Robi
 */

class ObjectType 
{
	private var path:String;
	private var swf:SWF;
	private var type:String;
	private var polygons:FastList<GeomPoly>;
	private var data:BitmapData;
	public function new(path:String, type:String = "SWF")
	{
		this.type = type;
		this.path = path;
		var bd:BitmapData = null;
		var disp:DisplayObject;
		if (type == "SWF")
		{
			swf = new SWF(Assets.getBytes(path));
			disp = getDisplayObject();
			bd = new BitmapData(Math.round(disp.width), Math.round(disp.height));
		}
		else
		{
			data = Assets.getBitmapData(path);
			bd = data;
			disp = getDisplayObject();
		}
		bd.draw(disp, null, null, null, null, true);
		polygons = Utils.getPolys(bd);
	}
	public function getPath():String
	{
		return path;
	}
	public function getDisplayObject():DisplayObject
	{
		if (type == "SWF") return swf.createMovieClip("").getChildAt(1);
		else if (type == "IMG") return new Bitmap(data);
		else return new Sprite();
	}
	public function getPolygons():FastList<GeomPoly>
	{
		return polygons;
	}
}