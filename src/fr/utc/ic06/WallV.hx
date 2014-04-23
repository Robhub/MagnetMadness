package fr.utc.ic06;
import nape.space.Space;

/**
 * ...
 * @author Robi
 */

class WallV extends Wall
{

	public function new(cfg:Hash<Float>, sp:Space, x:Float, y:Float, len:Float) 
	{
		super(sp, Std.int(x * cfg.get("width")), Std.int(y * cfg.get("height")), 2, Std.int(len * cfg.get("height")));
	}
	
}