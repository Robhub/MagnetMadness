package fr.utc.ic06;
import nape.dynamics.InteractionGroup;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.space.Space;
import nme.display.Sprite;
import nme.filters.GlowFilter;

/**
 * ...
 * @author Robi
 */

class Objet extends Sprite
{
	public var body:Body;
	public var type:String;
	public var couleur:Couleur;
	public var duree:Float = 0;
	private var prevPos:Vec2;
	private var prevRot:Float;
	public function getVal():Int
	{
		var val:Float = 5 - Math.sqrt(Math.max(duree,2)-2);
		val = Math.max(1, val);
		return Std.int(val);
	}
	public function getGlow():GlowFilter
	{
		return new GlowFilter(couleur.rgb, 1, getVal()*3, getVal()*3, 2, 1);
	}
	public function new(space:Space, ot:ObjectType, c:Couleur, cursor:Bool = false) 
	{
		super();
		type = ot.getPath();
		couleur = c;
		body = new Body(BodyType.DYNAMIC);
		if (cursor) body.cbTypes.add(Main.CBCUR);
		else body.cbTypes.add(Main.CBOBJ);
		body.userData.self = this;
		body.userData.cursor = cursor;

		for (p in ot.getPolygons())
		{
			var poly:Polygon = new Polygon(p, Material.wood());//new Material(0,1,2)
			body.shapes.add(poly);
		}
		var disp = ot.getDisplayObject();
		
		if (couleur != null) disp.transform.colorTransform = couleur.cT;
		//addChild(body.graphic = disp);
		addChild(disp);
		
		var anchor = body.localCOM.mul( -1);
		body.translateShapes(anchor);
		disp.x = anchor.x;
		disp.y = anchor.y;
		body.velocity = new Vec2(0.1, 0);
		//body.position.setxy(Math.random() * stage.stageWidth, Math.random() * stage.stageHeight);
		body.rotation = Math.random()*Math.PI*2;
		body.space = space;
	}
	private function getPosition():Vec2
	{
		//return body.localPointToWorld(body.graphicOffset);
		return body.position.copy();
	}
	private function normRotation(rot:Float):Float
	{
		return (rot * 180 / Math.PI) % 360;
	}
	public function reset()
	{
		prevPos = getPosition().copy();
		prevRot = body.rotation;
	}
	public function smooth(ratio:Float)
	{
		var pos = getPosition();
		var smoo = true;
		if (smoo && prevPos != null)
		{
			x = prevPos.x + (pos.x - prevPos.x) * ratio;
			y = prevPos.y + (pos.y - prevPos.y) * ratio;
			rotation = normRotation(prevRot + (body.rotation - prevRot) * ratio);
		}
		else
		{
			x = pos.x;
			y = pos.y;
			rotation = normRotation(body.rotation);
		}
	}
}