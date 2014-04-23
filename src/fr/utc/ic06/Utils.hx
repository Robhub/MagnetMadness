package fr.utc.ic06;
import haxe.FastList;
import nape.geom.AABB;
import nape.geom.GeomPoly;
import nape.geom.GeomPolyList;
import nape.geom.MarchingSquares;
import nape.geom.Vec2;
import nape.shape.Polygon;
import nme.display.BitmapData;

/**
 * ...
 * @author Robi
 */

class Utils 
{

	public function new() 
	{
		
	}
	public static function getPolys(bitmapData:BitmapData):FastList<GeomPoly>
	{
		var liste = new FastList<GeomPoly>();
		/*
		function iso(x:Float, y:Float):Float
		{
			
			var ix = Std.int(x); if(ix<0) ix = 0; else if(ix>=bitmapData.width)  ix = bitmapData.width -1;
			var iy = Std.int(y); if (iy<0) iy = 0; else if(iy>=bitmapData.height) iy = bitmapData.height-1;
			
			var fx = x - ix; if(fx<0) fx = 0; else if(fx>1) fx = 1;
			var fy = y - iy; if(fy<0) fy = 0; else if(fy>1) fy = 1;
			var gx = 1-fx;
			var gy = 1-fy;
			var a00 = bitmapData.getPixel32(ix,iy)>>>24;
			var a01 = bitmapData.getPixel32(ix,iy+1)>>>24;
			var a10 = bitmapData.getPixel32(ix+1,iy)>>>24;
			var a11 = bitmapData.getPixel32(ix+1,iy+1)>>>24;
			var ret = gx * gy * a00 + fx * gy * a10 + gx * fy * a01 + fx * fy * a11;
			var ret = gx * gy * a00;
			return 0x80-ret;
		}*/
		var bounds = new AABB(0,0,bitmapData.width,bitmapData.height);
		var cellsize = new Vec2(2, 2);
		for (p in MarchingSquares.run(new BitmapDataIso(bitmapData, 0x80), bounds, cellsize, 2))
		{
			for (q in p.simplify(2).convexDecomposition()) liste.add(q);//p.simplify(1)
			//convex_decomposition
		}
		return liste;
	}
	
}