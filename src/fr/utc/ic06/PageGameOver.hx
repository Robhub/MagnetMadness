package fr.utc.ic06;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.text.Font;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;

/**
 * ...
 * @author Robi
 */

class PageGameOver extends Sprite
{
	public var txtScore:TextField;
	public var btnHome:Sprite;
	public var btnReplay:Sprite;
	public function new() 
	{
		super();
		addChild(new Bitmap(Assets.getBitmapData("img/PageGameOver.jpg")));
		
		addChild(btnHome = new Sprite());
		btnHome.addChild(new Bitmap(Assets.getBitmapData("img/accueiltouchebon.png")));
		
		addChild(btnReplay = new Sprite());
		btnReplay.addChild(new Bitmap(Assets.getBitmapData("img/rejouerbon.png")));
		
		btnHome.x = btnReplay.x = 550;
		btnReplay.y = 305;
		btnHome.y = btnReplay.y + 55;
		txtScore = new TextField();
		txtScore.textColor = 0xFFFFFF;
		txtScore.selectable = false;
		txtScore.y = 315;
		txtScore.x = 110;
		txtScore.width = 280;
		
		var format = new TextFormat(Main.FONT.fontName, 42, 0xFFFFFF, true);
		format.align = TextFormatAlign.CENTER;
		txtScore.defaultTextFormat = format;
		txtScore.embedFonts = true;
		addChild(txtScore);
	}
	
}