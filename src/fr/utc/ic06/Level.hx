package fr.utc.ic06;
import haxe.FastList;

/**
 * ...
 * @author Robi
 */

class Level 
{
	public var background:String = "1.jpg";
	public var objSpeed:Int = 0;
	public var numGoodObjects:Int = 1;
	public var numBadObjects:Int = 0;
	public var numShapes:Int = 1;
	public var numColors:Int = 1;
	public var percentLife:Int = -1;
	public var walls:FastList<LevelWall>;
	public function new() 
	{
		walls = new FastList<LevelWall>();
	}
	
}