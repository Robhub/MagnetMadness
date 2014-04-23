package fr.utc.ic06;
import nape.space.Space;

/**
 * ...
 * @author Robi
 */

class WallH extends Wall
{

	public function new(cfg:Hash<Float>, sp:Space, x:Float, y:Float, len:Float) 
	{
		super(sp, Std.int(x * cfg.get("width")), Std.int(y * cfg.get("height")), Std.int(len * cfg.get("width")), 2);
	}
	
}