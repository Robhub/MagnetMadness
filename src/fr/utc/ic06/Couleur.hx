package fr.utc.ic06;
import nme.geom.ColorTransform;

/**
 * ...
 * @author Robi
 */

class Couleur 
{
	public var r:Int;
	public var g:Int;
	public var b:Int;
	public var cT:ColorTransform;
	public var rgb:Int;
	public function new(cr:Int,cg:Int,cb:Int) 
	{
		r = cr;
		g = cg;
		b = cb;
		rgb = r*65536+g*256+b;
		cT = new ColorTransform(1, 1, 1, 1, r, g, b, 0);
	}
}