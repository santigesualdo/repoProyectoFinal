package utils;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.addons.text.FlxTextField;
import flixel.util.FlxColor;
import states.PlayState;

/**
 * ...
 * @author s
 */
class ButtonLevel extends FlxSprite
{

	var text:FlxText;
	
	var outPath:String;
	var overPath:String;
	
	var levelName:String;
	
	var clicked: Bool;
	
	public function new(X:Float = 0, Y:Float = 0, _levelName:String)	{

		levelName = _levelName;
		
		outPath = AssetPaths.butLevelOut;
		overPath = AssetPaths.butLevelOver;
		
		clicked = false;
			
		super(X, Y, outPath);
		setPosition(this.x - this.width * 0.5, this.y - this.height * 0.5);
		
		text = new FlxText(this.x, this.y, this.width, levelName);
		text.setFormat(AssetPaths.font_kreon, 28, FlxColor.BLACK, "center");		
		
		addMouseEvents();
		
	}
	
	public function getClicked():Bool {
		return clicked;
	}
	
	public function getLevelName():String {
		return levelName;
	}
	
	public function addMouseEvents():Void{
		FlxMouseEventManager.add(cast(this,FlxSprite), onClick, onClickUp, onMouseOver, onMouseOut);
	}
			
	function onClickUp(sprite:FlxSprite):Void {	
		clicked = true;
	}
	
	function onClick(sprite:FlxSprite):Void	{ 
		// FlxG.log.add("nada");	
	}
	
	function onMouseOver(sprite:FlxSprite):Void {
		var _sprite:FlxSprite = new FlxSprite(this.x, this.y, overPath);
		this.loadGraphicFromSprite(_sprite);
	}
	
	function onMouseOut(sprite:FlxSprite) :Void	{
		var _sprite:FlxSprite = new FlxSprite(this.x, this.y, outPath);
		this.loadGraphicFromSprite(_sprite);
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		text.update(elapsed);
		
	}
	
	override public function destroy():Void {
		FlxMouseEventManager.remove(cast(this, FlxSprite));
		super.destroy();
	}
	
	override public function draw():Void {
		super.draw();
		
		text.draw();
	}
	
}