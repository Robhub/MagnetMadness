package fr.utc.ic06;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.space.Space;
import nme.display.Sprite;
import nme.filters.GlowFilter;

/**
 * ...
 * @author Robi
 */

class Wall extends Sprite
{
	public var body:Body;
	public function new(sp:Space, x:Int, y:Int, w:Int, h:Int) 
	{
		super();
		body = new Body(BodyType.STATIC);
		body.userData.self = this;
		body.shapes.add(new Polygon(Polygon.rect(x, y, w, h)));
		body.space = sp;
		graphics.beginFill(0xFFFFFF, 1);
		graphics.drawRect(x-1, y-1, w+2, h+2);
		graphics.beginFill(0x000000, 1);
		graphics.drawRect(x, y, w, h);
		//filters = [new GlowFilter(0xFFFFFF, 1, 8, 8, 2, 1)];
	}
}