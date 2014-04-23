package fr.utc.ic06;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.Sprite;

/**
 * ...
 * @author Robi
 */

class PageHome extends Sprite
{
	public var btnCredits:Sprite;
	public var btnPlay:Sprite;
	public var btnTuto:Sprite;
	public function new() 
	{
		super();
		addChild(new Bitmap(Assets.getBitmapData("img/PageHome.jpg")));
		
		addChild(btnCredits = new Sprite());
		btnCredits.addChild(new Bitmap(Assets.getBitmapData("img/creditsbon.png")));
		addChild(btnPlay = new Sprite());
		btnPlay.addChild(new Bitmap(Assets.getBitmapData("img/jouerbon.png")));
		addChild(btnTuto = new Sprite());
		btnTuto.addChild(new Bitmap(Assets.getBitmapData("img/tutobon.png")));
		
		btnCredits.x = btnPlay.x = btnTuto.x = 550;
		btnTuto.y = 250;
		btnPlay.y = btnTuto.y + 55;
		btnCredits.y = btnPlay.y + 55;
		
	}
	
}