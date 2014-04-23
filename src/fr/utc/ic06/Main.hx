package fr.utc.ic06;

import format.SWF;
import haxe.FastList;
import haxe.xml.Fast;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.callbacks.Listener;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.space.Space;
import nape.util.ShapeDebug;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.FPS;
import nme.display.Loader;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.filters.GlowFilter;
import nme.geom.Rectangle;
import nme.Lib;
import nme.media.SoundChannel;
import nme.media.SoundTransform;
import nme.net.SharedObject;
import nme.net.URLLoader;
import nme.net.URLRequest;
import nme.text.Font;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;


/**
 * ...
 * @author Robi
 */

class Main extends Sprite 
{
	// PHYSICS
	private static var MSTEP:Int = 25; // en millisecondes : 20ms=50FPS, 25ms=40FPS, 40ms=25FPS, 50ms=20FPS
	private static var STEP:Float = MSTEP / 1000; // en secondes
	private static var VELO_ITER:Int = 8;
	private static var POSI_ITER:Int = 3;
	private var tick:Int;
	
	public static var CBCUR:CbType;
	public static var CBOBJ:CbType;
	public static var FONT:Font;
	
	private var storage:SharedObject;
	
	// CONFIG
	private var configOptions:Hash<Float>;
	private var configColors:Array<Couleur>;
	private var configShapes:Array<ObjectType>;
	private var configLevels:Hash<Array<Level>>;
	
	// LOADERS
	private var backgrounds:Hash<Loader>;
	//private var musics:Hash<Loader>;
	
	// GAME
	private var repulsing:Bool = false;
	private var energy:Float = 1.0;
	private var invincible:Bool = true;
	private var gameType:String;
	private var gameStarted:Bool = false;
	private var gamePaused:Bool = false;
	private var levels:Array<Level>;
	private var level:Int;
	private var attract:Bool;
	private var repulse:Bool;
	private var score:Int;
	private var lives:Int;
	private var timeOfDeath:Int;
	private var bodiesToEat:FastList<Body>;
	private var bodiesToEatLater:FastList<Body>;
	
	private var filterA:GlowFilter;
	private var filterB:GlowFilter;
	
	// CONTAINERS
	private var background:Sprite;
	private var hud:Sprite;
	private var game:Sprite;
	private var page:Sprite;
	
	// PAGES
	private var pageHome:PageHome;
	private var pageCredits:PageCredits;
	private var pageGameOver:PageGameOver;
	
	// HUD
	
	private var hudLives:Array<Sprite>;
	private var lifeType:ObjectType;
	private var skullType:ObjectType;
	private var unkType:ObjectType;
	private var curseur:Objet;
	private var space:Space;
	private var debug:ShapeDebug;
	private var music:SoundChannel;
	private var music1:SoundChannel;
	private var music2:SoundChannel;
	private var attractSound:SoundChannel;
	private var repulseSound:SoundChannel;
	
	private var jauge:Sprite;
	private var nb:Int = 0;
	private var txtGoal:TextField;
	private var txtLevel:TextField;
	private var txtScore:TextField;
	private var txtHighScore:TextField;
	
	private var btnMusic:Sprite;
	private var btnSound:Sprite;
	static public function main()
	{
		CBCUR = new CbType();
		CBOBJ = new CbType();
		FONT = Assets.getFont("fonts/RollingNoOne-ExtraBold.ttf");
		Lib.current.addChild(new Main());
	}
	public function new() 
	{
		super();
		lifeType = new ObjectType("swf/vieseule.svg.swf");
		skullType = new ObjectType("img/tetedemort.png", "IMG");
		unkType = new ObjectType("img/pointinterro.png", "IMG");
		
		bodiesToEat = new FastList<Body>();
		bodiesToEatLater = new FastList<Body>();
		
		storage = SharedObject.getLocal("storage");
		if (!storage.data.highscore) storage.data.highscore = 0;
		if (storage.data.sound == null) storage.data.sound = 1;
		if (storage.data.music == null) storage.data.music = 1;
		
		// Background
		addChild(background = new Sprite());
		
		// Game
		addChild(game = new Sprite());
		game.y = 80;
		
		// HUD
		addChild(hud = new Sprite());
		
		// FPS
		addChild(new FPS(730, 46, 0xCCCCCC));
		
		// Pages
		addChild(page = new Sprite());
		pageHome = new PageHome();
		buttonOverOut(pageHome.btnTuto).addEventListener(MouseEvent.CLICK, clickTuto);
		buttonOverOut(pageHome.btnPlay).addEventListener(MouseEvent.CLICK, clickPlay);
		buttonOverOut(pageHome.btnCredits).addEventListener(MouseEvent.CLICK, clickCredits);
		pageGameOver = new PageGameOver();
		buttonOverOut(pageGameOver.btnHome).addEventListener(MouseEvent.CLICK, clickHome);
		buttonOverOut(pageGameOver.btnReplay).addEventListener(MouseEvent.CLICK, clickReplay);
		pageCredits = new PageCredits();
		buttonOverOut(pageCredits.btnHome).addEventListener(MouseEvent.CLICK, clickHome);
		
		
		addChild(btnMusic = new Sprite());
		addChild(btnSound = new Sprite());
		btnMusic.x = 720;
		btnMusic.y = 8;
		btnSound.x = 760;
		btnSound.y = 8;
		btnMusic.addEventListener(MouseEvent.CLICK, clickMusic);
		btnSound.addEventListener(MouseEvent.CLICK, clickSound);
		btnMusic.addChild(new Bitmap(Assets.getBitmapData("img/Musicoff1.png")));
		btnMusic.addChild(new Bitmap(Assets.getBitmapData("img/Musicon1.png")));
		btnSound.addChild(new Bitmap(Assets.getBitmapData("img/sound-off1.png")));
		btnSound.addChild(new Bitmap(Assets.getBitmapData("img/sound-on1.png")));
		setMute(btnMusic, storage.data.music);
		setMute(btnSound, storage.data.sound);
		
		
		var hudCadre = new Bitmap(Assets.getBitmapData("img/cadre.png"));
		hud.addChild(hudCadre);
		
		
		hud.addChild(jauge = new Sprite());
		jauge.addChild(new Bitmap(Assets.getBitmapData("img/barrepouvoir.png")));
		jauge.addChild(new Bitmap(Assets.getBitmapData("img/barrepouvoirinterieur.png")));
		jauge.getChildAt(1).x = 5;
		jauge.getChildAt(1).y = 6;
		jauge.x = 240;
		jauge.y = 38;
		
		var format:TextFormat = new TextFormat(FONT.fontName, 24, 0xFFFFFF, true);
		format.align = TextFormatAlign.CENTER;
		
		hud.addChild(makeTextField(10, 8, 100,"Niveau", format));
		hud.addChild(makeTextField(110, 8, 100, "Objectif", format));
		hud.addChild(makeTextField(240, 8, 100, "Pouvoir", format));
		hud.addChild(makeTextField(380, 8, 100, "Vies", format));
		hud.addChild(makeTextField(510, 8, 100, "Score", format));
		hud.addChild(makeTextField(610, 8, 100, "Record", format));
		
		
		hud.addChild(txtLevel = makeTextField(10, 38, 100, "", format));
		hud.addChild(txtGoal = makeTextField(110, 38, 100, "", format));
		hud.addChild(txtScore = makeTextField(510, 38, 100, "", format));
		hud.addChild(txtHighScore = makeTextField(610, 38, 100, "", format));
		

		
		attractSound = Assets.getSound("snd/attract.wav").play(0, 999999);
		setVolume(attractSound, 0);
		
		
		repulseSound = Assets.getSound("snd/repulse.wav").play(0, 999999);
		setVolume(repulseSound, 0);
		
		space = new Space();
		space.listeners.add(new PreListener(InteractionType.COLLISION, CBCUR, CBOBJ, function(cb:PreCallback) {
			//var b1 = cb.int1.castBody;
			//var b2 = cb.int2.castBody;
			//if (!invincible) bodiesToEat.add(b2);
			//else bodiesToEatLater.add(b2);
			return PreFlag.IGNORE;
			
		}));
		space.listeners.add(new InteractionListener(CbEvent.ONGOING, InteractionType.COLLISION, CBCUR, CBOBJ, function(cb:InteractionCallback) {
			var b1 = cb.int1.castBody;
			var b2 = cb.int2.castBody;
			if (!invincible) bodiesToEat.add(b2);
			
		}));
		addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		
		var loadConfig = new URLLoader();
		loadConfig.addEventListener(Event.COMPLETE, configLoaded);
		loadConfig.load(new URLRequest("config.xml"));
	}
	private function clickMusic(e:MouseEvent)
	{
		storage.setProperty("music", (storage.data.music + 1) % 2);
		setMute(btnMusic, storage.data.music);
		setMusicVolume();
	}
	private function playSound(snd:String, vol:Float)
	{
		if (storage.data.sound == 0) return;
		setVolume(Assets.getSound("snd/" + snd).play(), vol);
	}
	private function clickSound(e:MouseEvent)
	{
		storage.setProperty("sound", (storage.data.sound + 1) % 2);
		setMute(btnSound, storage.data.sound);
	}
	private function setMute(sprite:Sprite, x:Int)
	{
		for (i in 0...sprite.numChildren) { sprite.getChildAt(i).visible = false; }
		sprite.getChildAt(x).visible = true;
		storage.flush();
	}
	private function makeTextField(x:Int, y:Int, w:Int, txt:String, format:TextFormat):TextField
	{
		var tf:TextField = new TextField();
		//tf.antiAliasType = AntiAliasType.ADVANCED;
		tf.selectable = false;
		tf.x = x;
		tf.y = y;
		tf.defaultTextFormat = format;
		tf.text = txt;
		return tf;
	}
	private function buttonOverOut(s:Sprite):Sprite
	{
		s.addEventListener(MouseEvent.MOUSE_OVER, buttonOver);
		s.addEventListener(MouseEvent.MOUSE_OUT, buttonOut);
		return s;
	}
	private function buttonOver(e:MouseEvent)
	{
		playSound("snap.wav", 0.3);
		e.target.filters = [new GlowFilter(0xFFFFFF, 1, 8, 8, 2, 1)];
	}
	private function buttonOut(e:MouseEvent)
	{
		e.target.filters = null;
	}
	private function setMusicVolume()
	{
		setVolume(music1, 0);
		setVolume(music2, 0);
		setVolume(music, storage.data.music * 0.1);
	}
	private function setVolume(sc:SoundChannel, vol:Float)
	{
		var sT = sc.soundTransform;
		sT.volume = vol;
		sc.soundTransform = sT;
	}
	private function addedToStage(e:Event)
	{
		stage.addEventListener(Event.ENTER_FRAME, enterFrame);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		stage.align = nme.display.StageAlign.TOP;
		
		/* DEBUG *
		debug = new ShapeDebug(stage.stageWidth, stage.stageHeight, 0x333333);
		addChild(debug.display);
		/**/
	}
	private function configLoaded(e:Event)
	{
		var config = new Fast(Xml.parse(e.target.data)).node.config;
		
		configOptions = new Hash<Float>();
		for (o in config.node.options.elements)
		{
			configOptions.set(o.name, Std.parseFloat(o.innerData));
		}
		
		configColors = new Array<Couleur>();
		for (o in config.node.colors.nodes.color)
		{
			if (!o.has.r || !o.has.g || !o.has.b) continue;
			configColors.push(new Couleur(Std.parseInt(o.att.r), Std.parseInt(o.att.g), Std.parseInt(o.att.b)));
		}
		
		configShapes = new Array<ObjectType>();
		for (o in config.node.shapes.nodes.shape)
		{
			configShapes.push(new ObjectType("swf/"+o.innerData+".svg.swf"));
		}
		
		backgrounds = new Hash<Loader>();
		configLevels = new Hash<Array<Level>>();
		for (o in config.nodes.levels)
		{
			if (!o.has.name) continue;
			var lvls = new Array<Level>();
			for (l in o.nodes.level)
			{
				if (!backgrounds.exists(l.node.background.innerData))
				{
					var backgroundLoader = new Loader();
					backgroundLoader.load(new URLRequest("backgrounds/" + l.node.background.innerData));
					backgrounds.set(l.node.background.innerData, backgroundLoader);
				}
				var level:Level = new Level();
				if (l.hasNode.background) level.background = l.node.background.innerData;
				if (l.hasNode.objSpeed) level.objSpeed = Std.parseInt(l.node.objSpeed.innerData);
				if (l.hasNode.numGoodObjects) level.numGoodObjects = Std.parseInt(l.node.numGoodObjects.innerData);
				if (l.hasNode.numBadObjects) level.numBadObjects = Std.parseInt(l.node.numBadObjects.innerData);
				
				if (l.hasNode.numColors) level.numColors = Std.parseInt(l.node.numColors.innerData);
				if (l.hasNode.numShapes) level.numShapes = Std.parseInt(l.node.numShapes.innerData);
				
				if (l.hasNode.percentLife) level.percentLife = Std.parseInt(l.node.percentLife.innerData);
				
				for (w in l.nodes.wall)
				{
					if (w.has.type && w.has.x && w.has.y && w.has.len)
					{
						var lw:LevelWall = new LevelWall();
						lw.type = w.att.type;
						lw.x = Std.parseFloat(w.att.x);
						lw.y = Std.parseFloat(w.att.y);
						lw.len = Std.parseFloat(w.att.len);
						level.walls.add(lw);
					}
				}
				
				lvls.push(level);
			}
			configLevels.set(o.att.name, lvls);
		}
		handleConfig();
		setPage(pageHome);
	}
	private function setMusic(mus:SoundChannel)
	{
		music = mus;
		setMusicVolume();
	}
	private function handleConfig()
	{
		var mutedST:SoundTransform = new SoundTransform(0);
		music1 = Assets.getSound("mus/music.mp3").play(0, 999999, mutedST);
		music2 = Assets.getSound("mus/future.mp3").play(0, 999999, mutedST);
		setMusic(music1);
		
		scrollRect = new Rectangle(0, 0, configOptions.get("width"), configOptions.get("height"));
		configOptions.set("height", configOptions.get("height") - 80); // 80 du HUD
		
		hudLives = new Array<Sprite>();
		var hudVie = new SWF(Assets.getBytes("swf/vieseule.svg.swf"));
		for (i in 0...Std.int(configOptions.get("lives")))
		{
			var vie = hudVie.createMovieClip("");
			hudLives.push(vie);
			vie.y = 40;
			vie.x = 380 + 34 * i;
			vie.width = 32;
			vie.height = 32;
			hud.addChild(vie);
		}
	}
	private function startGame()
	{
		energy = 1;
		setMusic(music2);
		setPage(); // On affiche que le jeu, pas d'écran
		gameStarted = true;
		levels = configLevels.get(gameType);
		level = 0;
		score = 0;
		lives = Std.int(configOptions.get("lives"));
		attract = false;
		repulse = false;
		loadLevel();
		resumeGame();
	}
	private function gameOver()
	{
		playSound("gameover.mp3", 0.5);
		if (gameType == "game" && score > storage.data.highscore)
		{
			storage.setProperty("highscore", score);
			storage.flush();
		}
		stopGame();
		pageGameOver.txtScore.text = "" + score;
		setPage(pageGameOver);
	}
	private function stopGame()
	{
		while (space.bodies.length > 0) removeBody(space.bodies.at(0)); // On enlève tous les body de l'espace
		gameStarted = false;
	}
	private function pauseGame()
	{
		gamePaused = true;
	}
	private function resumeGame()
	{
		gamePaused = false;
		tick = Lib.getTimer();
	}
	private function randomShape():ObjectType
	{
		var rnd:Int = Std.int(Math.random() * levels[level].numShapes);
		return configShapes[rnd];
	}
	private function randomColor():Couleur
	{
		var rnd:Int = Std.int(Math.random() * levels[level].numColors);
		return configColors[rnd];
	}
	private function updateInterface()
	{
		game.visible = gameStarted;
		hud.visible = gameStarted;
		
		// SOUNDS
		if (!gameStarted)
		{
			setVolume(attractSound, 0);
			setVolume(repulseSound, 0);
			return;
		}
		if (attract && !repulse && storage.data.sound != 0) setVolume(attractSound, 0.5);
		else setVolume(attractSound, 0);
		if (repulsing && storage.data.sound != 0) setVolume(repulseSound, 0.5);
		else setVolume(repulseSound, 0);
		
		// HUD
		var txt:String;
		txt = "" + nb + "/" + levels[level].numGoodObjects;
		if (txtGoal.text != txt) txtGoal.text = txt;
		txt = "" + score;
		if (txtScore.text != txt) txtScore.text = txt;
		txt = "" + storage.data.highscore;
		if (txtHighScore.text != txt) txtHighScore.text = txt;
		txt = "" + (level + 1) + "/" + levels.length;
		if (txtLevel.text != txt) txtLevel.text = txt;
		for (i in 0...hudLives.length)
		{
			hudLives[i].visible = i < lives;
		}
		jauge.getChildAt(1).width = 110 - 110 * energy;
		jauge.getChildAt(1).x = 5 + 110 * energy;
		
	}
	private function loadLevel()
	{
		//timeOfDeath = Lib.getTimer();
		while (space.bodies.length > 0) removeBody(space.bodies.at(0)); // On enlève tous les body de l'espace

		// Background
		while (background.numChildren > 0) background.removeChildAt(0);
		background.addChild(backgrounds.get(levels[level].background));
		
		// Walls
		game.addChild(new WallV(configOptions, space, 0, 0, 1));
		game.addChild(new WallV(configOptions, space, 1, 0, 1));
		game.addChild(new WallH(configOptions, space, 0, 0, 1));
		game.addChild(new WallH(configOptions, space, 0, 1, 1));
		
		for (w in levels[level].walls)
		{
			if (w.type == "h") game.addChild(new WallH(configOptions, space, w.x, w.y, w.len));
			if (w.type == "v") game.addChild(new WallV(configOptions, space, w.x, w.y, w.len));
		}
		
		
		//== Curseur
		var goodShape = randomShape();
		var goodColor = randomColor();
		curseur = new Objet(space, goodShape, goodColor, true);
		
		var margin:Float = 16;
		var cx:Float = game.mouseX;
		var cy:Float = game.mouseY;
		if (cx < margin) cx = margin;
		if (cy < margin) cy = margin;
		if (cx > configOptions.get("width") - margin) cx = configOptions.get("width") - margin;
		if (cy > configOptions.get("height") - margin) cy = configOptions.get("height") - margin;
		
		//curseur.body.position.setxy(, game.mouseY);
		
		filterA = new GlowFilter(0xFFFFFF, 1, 12, 12, 4, 1);
		filterB = new GlowFilter(0xFFFFFF, 1, 6, 6, 2, 1);
		curseur.body.position.setxy(cx, cy);
		curseur.filters = [filterA];
		
		/*
		var cercle:Sprite = new Sprite();
		cercle.graphics.lineStyle(2, 0xFFFFFF, 0.8);
		cercle.graphics.drawCircle(0, 0, 24);
		curseur.addChild(cercle);
		*/
		game.addChild(curseur);
		//Mouse.hide();
		
		if (gameType == "game" && Math.random() * 100 < levels[level].percentLife && lives < Std.int(configOptions.get("lives")))
		{
			var objet = new Objet(space, lifeType, null);
			game.addChild(objet);
			setRandomPosition(objet.body);
		}
		if (gameType == "game" && Math.random() * 100 < configOptions.get("percentSkull"))
		{
			var skull = new Objet(space, skullType, null);
			game.addChild(skull);
			setRandomPosition(skull.body);
		}
		
		//== Ajout d'objets
		nb = 0;
		for (i in 0...levels[level].numGoodObjects)
		{
			var objet = new Objet(space, goodShape, goodColor);
			game.addChild(objet);
			setRandomPosition(objet.body);
		}
		for (i in 0...levels[level].numBadObjects)
		{
			var badShape:ObjectType;
			var badColor:Couleur;
			do
			{
				badShape = randomShape();
				badColor = randomColor();
			} while (badShape == goodShape && badColor == goodColor);
			var objet = new Objet(space, badShape, badColor);
			game.addChild(objet);
			setRandomPosition(objet.body);
		}
	}
	private function setRandomPosition(b:Body)
	{
		do
		{
			var secu:Float = 32;
			b.position.setxy(secu + Math.random() * (configOptions.get("width") - 2 * secu), secu + Math.random() * (configOptions.get("height") - 2 * secu));
		} while (b.position.copy().sub(curseur.body.position).length < configOptions.get("safeDist"));
	}
	private function setPage(p:Sprite = null)
	{
		while (page.numChildren > 0) page.removeChildAt(0);
		if (p != null) page.addChild(p);
	}
	private function clickHome(e:MouseEvent)
	{
		clickButtonSound();
		setPage(pageHome);
		setMusic(music1);
	}
	private function clickCredits(e:MouseEvent)
	{
		clickButtonSound();
		setPage(pageCredits);
	}
	private function clickTuto(e:MouseEvent)
	{
		clickButtonSound();
		gameType = "tuto";
		startGame();
	}
	private function clickPlay(e:MouseEvent)
	{
		clickButtonSound();
		gameType = "game";
		startGame();
	}
	private function clickReplay(e:MouseEvent)
	{
		clickButtonSound();
		startGame();
	}
	private function clickButtonSound()
	{
		playSound("clic.wav", 0.3);
	}
	
	private function keyDown(e:KeyboardEvent)
	{
		if (e.keyCode == 32 && !gameStarted) 
		{
			gameType = "game";
			startGame();
		}
		if (e.keyCode == 65) attract = true;
		if (e.keyCode == 69) repulse = true;
		if (e.keyCode == 80)
		{
			if (gamePaused) resumeGame();
			else pauseGame();
		}
	}
	private function keyUp(e:KeyboardEvent)
	{
		if (e.keyCode == 65) attract = false;
		if (e.keyCode == 69) repulse = false;
	}
	private function mouseDown(e:MouseEvent)
	{
	}
	private function mouseUp(e:MouseEvent)
	{
	}
	private function enterFrame(e:Event)
	{
		if (gameStarted && !gamePaused) gameLoop();
		updateInterface();
		if (gameStarted && lives <= 0) gameOver();
	}
	private function gameLoop()
	{
		var t = Lib.getTimer();
		while (tick + MSTEP < t)
		{
			tick += MSTEP;
			update();
		}
		var ratio = (t - tick) / MSTEP;
		smooth(ratio);
		var timeSinceDeath = t - timeOfDeath;
		curseur.alpha = 1;
		//if (lives == 1) curseur.alpha = 0.75;
		var blinking = 50;
		if (timeSinceDeath < 2000)
		{
			invincible = true;
			
			if (timeSinceDeath % (blinking*2) > blinking) curseur.alpha = 0.1;
		}
		else invincible = false;
		if (lives == 1)
		{
			if (t % (blinking*2) > blinking) curseur.filters = [filterA];
			else curseur.filters = [];
		}
	}
	private function smooth(ratio:Float)
	{
		var bodies = space.bodies;
		for (i in 0...bodies.length)
		{
			var body = bodies.at(i);
			if (Std.is(body.userData.self, Objet))
			{
				body.userData.self.smooth(ratio);
			}
		}
	}
	private function update()
	{
		var bodies = space.bodies;
		var vel:Vec2 = Vec2.get(game.mouseX, game.mouseY).sub(curseur.body.position).mul(15);
		var len:Float = Math.min(1000, vel.length);
		if (vel.length != 0) vel = vel.normalise();
		curseur.body.velocity = vel.mul(len);
		
		energy += 0.001;
		repulsing = false;
		if (repulse && !attract && energy >= 0.005)
		{
			energy -= 0.005;
			repulsing = true;
		}
		if (attract && !repulse) energy += 0.010;
		if (energy > 1) energy = 1;
		for (i in 0...bodies.length)
		{
			var body = bodies.at(i);
			if (Std.is(body.userData.self, Objet))
			{
				body.userData.self.reset();
			}
			if (body.type == BodyType.DYNAMIC)
			{
				if (body.userData.cursor == true)
				{
					body.angularVel = 5;
				}
				else
				{
					body.userData.self.duree += STEP;
					
					//if (body.userData.self.couleur != null) body.userData.self.filters = [body.userData.self.getGlow()];
					
					body.velocity = body.velocity.mul(0.99);
					body.angularVel = body.angularVel * 0.99;
					
					var objSpeed = levels[level].objSpeed;
					
					body.velocity = body.velocity.add(Vec2.get(Math.random() * objSpeed - objSpeed/2, Math.random() * objSpeed - objSpeed/2));
					
					var difference = body.position.copy().sub(curseur.body.position);
					
					//if (difference.length < 38) bodiesToEat.add(body);
					if (difference.length < configOptions.get("range"))
					{
						if (attract && !repulse) body.applyImpulse(difference.mul(-configOptions.get("power")), body.position);
						if (repulsing) body.applyImpulse(difference.mul(configOptions.get("power")), body.position);//body.mass * 
					}
				}
			}
		}
		if (nb == levels[level].numGoodObjects)
		{
			playSound("newlevel.mp3", 0.5);
			level++;
			if (level >= levels.length)
			{
				if (gameType == "tuto")// fin du tuto
				{
					stopGame();
					setPage(pageHome);
					setMusic(music1);
				}
				level = levels.length - 1;
			}
			loadLevel();
		}
		else
		{
			for (body in bodiesToEat)
			{
				if (body.userData.self.type == curseur.type && body.userData.self.couleur.rgb == curseur.couleur.rgb)
				{
					nb++;
					score += body.userData.self.getVal();
					playSound("good.wav", 1);
				}
				else if (body.userData.self.type == "swf/vieseule.svg.swf")
				{
					lives++;
				}
				else
				{
					if (body.userData.self.type == "img/tetedemort.png") lives = 0;
					else lives--;
					timeOfDeath = tick;
					playSound("bad.wav", 1);
				}
				removeBody(body);
			}
			bodiesToEat = new FastList<Body>();
		}
		space.step(STEP, VELO_ITER, POSI_ITER);
	}
	private function removeBody(body:Body)
	{
		if (body.userData.self && body.userData.self.parent) body.userData.self.parent.removeChild(body.userData.self);
		space.bodies.remove(body);
	}
}
