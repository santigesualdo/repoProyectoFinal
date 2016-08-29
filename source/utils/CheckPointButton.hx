package utils;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.addons.text.FlxTextField;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author s
 */
class CheckPointButton extends FlxSprite
{
	var sprite:FlxSprite;
	var text:FlxTextField;
	private var accion:Void->Void;
	
	var pathOver:String = "";
	var pathOut:String = "";
	
	public function new(X:Float=0, Y:Float=0, id: Int, _accion:Void->Void) 
	{
		super(X, Y,null);
		
		text = new FlxTextField(this.x + 20 , this.y + 15, 30, Std.string(id), 12, true);

		pathOut = AssetPaths.arma0;
		pathOver = AssetPaths.arma0Over;
		
		sprite = new FlxSprite(this.x, this.y, pathOut);
		loadGraphicFromSprite(sprite);
		accion = _accion;
					
		addMouseEvents();		
	}
	
	function addMouseEvents() 
	{
		FlxMouseEventManager.add(sprite, onClick, onClickUp, onMouseOver, onMouseOut);
	}
	
	function onClickUp(sprite:FlxSprite):Void {
		accion();
	}
	
	function onMouseOut(sprite:FlxSprite) :Void{
		var _sprite = new FlxSprite(sprite.x, sprite.y, pathOut);
		loadGraphicFromSprite(_sprite);	
	}
	function onMouseOver(sprite:FlxSprite):Void{
		var _sprite = new FlxSprite(sprite.x, sprite.y, pathOver);
		loadGraphicFromSprite(_sprite);	
	}
	function onClick(sprite:FlxSprite) {}
	
	override public function draw():Void {
		super.draw();
		sprite.draw();
		text.draw();
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		sprite.update(elapsed);
		text.update(elapsed);
	}
	
	override public function destroy():Void {
		FlxMouseEventManager.remove(this);
		FlxMouseEventManager.remove(sprite);
		sprite.destroy();
		text.destroy();
		super.destroy();
	}
	

}