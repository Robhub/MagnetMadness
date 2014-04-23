package fr.utc.ic06;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.display.Sprite;

/**
 * ...
 * @author Robi
 */

class PageCredits extends Sprite
{
	public var btnHome:Sprite;
	public function new() 
	{
		super();
		addChild(new Bitmap(Assets.getBitmapData("img/PageCredits.jpg")));
		
		addChild(btnHome = new Sprite());
		btnHome.addChild(new Bitmap(Assets.getBitmapData("img/accueiltouchebon.png")));
		
		btnHome.x = 550;
		btnHome.y = 330;
	}
	
}